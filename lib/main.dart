import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/models/navigation_shell.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/locator.service.dart';
import 'package:vmodel/src/pushnotification.helper.dart';
import 'package:vmodel/src/res/app_go_router.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'firebase_options.dart';
import 'src/core/cache/credentials.dart';
import 'src/core/cache/hive_provider.dart';
import 'src/core/cache/local_storage.dart';
import 'src/core/controller/user_prefs_controller.dart';
import 'src/core/utils/enum/vmodel_app_themes.dart';
import 'src/res/res.dart';
import 'src/vmodel.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> handleDynamicLink() async {
  await FirebaseDynamicLinks.instance.getInitialLink();
  FirebaseDynamicLinks.instance.onLink.listen((result) {}).onError((error) {});
}

class NavigationPayload {
  Map<String, dynamic>? _payload;

  Map<String, dynamic>? get payload {
    return _payload;
  }

  set payload(Map<String, dynamic>? p) {
    _payload = p;
  }
}

final NavigationModel navigationModel = NavigationModel();

NavigationPayload navigationPayload = NavigationPayload();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  //removes the native white splashscreen that comes with the flutter sdk [a better way than tweaking the AndroidManifest file]
  WidgetsBinding widgetFlutterBinding =
      WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await setUpLocator();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: Platform.isIOS ? 'ios' : "android");

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      if (message.notification != null) {
        if (message.data.isNotEmpty) {
          navigationPayload.payload = message.data;
        }
      }
    }
  });

  /// stripe publishable key
  Stripe.publishableKey =
      'pk_test_51MUB2yBHdb5MeEk7eRdKhqG5CZSExTI1ChtUs6vCkGyWod8Jw6weYt1jeSMDJ2xD4m79Dj62aA3YELPAuuqyxFyV000cHayfJo';

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      if (message.data.isNotEmpty) {
        navigationPayload.payload = message.data;
      }
    }
  });

  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await Hive.initFlutter();

  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Splash screen preservation
  FlutterNativeSplash.preserve(widgetsBinding: widgetFlutterBinding);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  if (Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(375, 812));
    await DesktopWindow.setMinWindowSize(const Size(375, 812));
    await DesktopWindow.setMaxWindowSize(const Size(375, 812));
  }
  handleDynamicLink();

  // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  //   if (result != ConnectivityResult.none) {
  //     refreshPages();
  //   }
  // });

  // Flutter downloader initializer
  await FlutterDownloader.initialize(
      debug:
          kDebugMode, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );

  runApp(const ProviderScope(child: VAppProduction()));
}

class VAppProduction extends ConsumerStatefulWidget {
  const VAppProduction({super.key});

  @override
  ConsumerState<VAppProduction> createState() => _VAppProductionState();
}

class _VAppProductionState extends ConsumerState<VAppProduction> {
  @override
  void initState() {
    runInit();
    super.initState();
  }

  runInit() async {
    await FirebaseApi().initNotification(context);
    getUserProfileDetails(onComplete: (token, username) {
      globalUsername = username;
    }).whenComplete(() async {
      ref.watch(hiveStoreProvider);
    });
  }

  Future<void> clearCache() async {
    userIDPk = null;
    globalUsername = null;
    final storeUsername =
        VModelSharedPrefStorage().putString(VSecureKeys.username, null);

    // Commenting this out. Token shouldn't be stored in SharedPreferences
    final storeToken =
        VModelSharedPrefStorage().putString(VSecureKeys.userTokenKey, null);
    await VCredentials.inst.storeUserCredentials(null);

    await Future.wait([storeToken, storeUsername]);
    await VModelSharedPrefStorage().clearObject(VSecureKeys.userTokenKey);
    await VModelSharedPrefStorage().clearObject(VSecureKeys.username);
    await VCredentials.inst.deleteAll();

    await VModelSharedPrefStorage().clearObject(VSecureKeys.userTokenKey);
    await VModelSharedPrefStorage().clearObject(VSecureKeys.username);

    VWidgetShowResponse.showToast(ResponseEnum.warning,
        message: "Cleared prefs and credentials");
  }

  final scrollKey = GlobalKey<NavigatorState>(debugLabel: 'main');

  @override
  Widget build(BuildContext context) {
    final prefsConfigs = ref.watch(userPrefsProvider);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    FlutterNativeSplash.remove();
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        return Sizer(builder: (context, orientation, deviceType) {
          return prefsConfigs.maybeWhen(
              data: (items) => MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    builder: (context, child) {
                      return ScrollConfiguration(
                          key: scrollKey,
                          behavior: MyBehavior(),
                          child: RefreshConfiguration(
                            headerBuilder: () => defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? ClassicHeader(
                                    failedIcon: Icon(Icons.error,
                                        color: Theme.of(context).primaryColor),
                                    completeIcon: Icon(Icons.done,
                                        color: Theme.of(context).primaryColor),
                                    idleIcon: Icon(Icons.arrow_downward,
                                        color: Theme.of(context).primaryColor),
                                    releaseIcon: Icon(Icons.refresh,
                                        color:
                                            (Theme.of(context).primaryColor)),
                                    textStyle: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  )
                                : MaterialClassicHeader(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                  textScaler: const TextScaler.linear(0.85)),
                              child: child!,
                            ),
                          ));
                    },
                    title: VMString.appName,
                    //navigatorKey: AppNavigatorKeys.instance.navigatorKey,
                    scaffoldMessengerKey: AppNavigatorKeys.instance.scaffoldKey,
                    themeMode: items.themeMode,
                    theme: getSelectedTheme(items.preferredLightTheme),
                    darkTheme:
                        ref.read(userPrefsProvider.notifier).preferredDarkTheme,
                    routerConfig: router,
                  ),
              orElse: () {
                return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    builder: (context, child) {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: child!,
                      );
                    },
                    title: VMString.appName,
                    //navigatorKey: AppNavigatorKeys.instance.navigatorKey,
                    scaffoldMessengerKey: AppNavigatorKeys.instance.scaffoldKey,
                    theme: VModelTheme.lightMode,
                    darkTheme: VModelTheme.darkTheme,
                    routerConfig: router);
              });
        });
      });
    });
  }

  ThemeData getSelectedTheme(VModelAppThemes theme) {
    switch (theme) {
      // case VModelAppThemes.pink:
      //   return VModelTheme.pinkMode;
      case VModelAppThemes.grey:
        return VModelTheme.darkTheme;
      default:
        return VModelTheme.lightMode;
    }
  }

// Create a provider for the theme mode
  // final themeProvider = StateProvider<bool>((ref) {
  //   // You can set an initial value here, e.g., based on user preferences.
  //   return false; // Use 'false' for light mode and 'true' for dark mode.
  // });
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class AppConnection {
  bool? _refreshMainFeedProvider;
  int _instance = 0;

  bool? get refreshMainFeedProvider => this._refreshMainFeedProvider;
  int get instance => this._instance;

  set refreshMainFeedProvider(bool? _) {
    _refreshMainFeedProvider = _;
  }

  set instance(int _) {
    _instance = _;
  }
}

AppConnection appConnection = AppConnection();

class VWidgetRef {
  WidgetRef? _ref;
  BuildContext? _context;

  WidgetRef? get ref => this._ref;
  BuildContext? get context => this._context;

  set ref(WidgetRef? _) {
    _ref = _;
  }

  set context(BuildContext? _) {
    _context = _;
  }
}

final VWidgetRef vRef = VWidgetRef();
