import 'dart:async';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/main.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/explore_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_home_view.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/pop_scope_to_background_wrapper.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/core/network/websocket.dart';

import '../../../../core/notification/redirect.dart';
import '../../../saved/views/delte_ml/views/example_del_ml_posts.dart';
import '../../dash/controller.dart';
import '../controller/feed_provider.dart';
import '../controller/new_feed_provider.dart';

class FeedMainUI extends ConsumerStatefulWidget {
  const FeedMainUI({
    Key? key,
  }) : super(key: key);

  static const routeName = 'feed';

  @override
  ConsumerState<FeedMainUI> createState() => _FeedHomeUIState();
}

class _FeedHomeUIState extends ConsumerState<FeedMainUI> with TickerProviderStateMixin, WidgetsBindingObserver {
  final homeCtrl = Get.put<HomeController>(HomeController());
  String feedTitle = "Feed";

  bool isLoading = VUrls.shouldLoadSomefeatures;
  bool issearching = false;

void message() {
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
}

@override
  void initState() {
    super.initState();
    message();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showMessage();
    });
  }

  void initWS() {
    var vcred = VCredentials.inst;
    var token = vcred.getRestToken();
    var username = vcred.getUsername();
    VWebsocket().connectToWebSocket(username, token, ref);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        {}
        break;
      case AppLifecycleState.paused:
        {}
        break;
      case AppLifecycleState.resumed:
        {
          try {
            redirectNotificationScreen(ref, context, false);
          } catch (e) {}
        }
        break;
      default:
        {}
    }
  }

  Widget recommended() {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(08),
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme?.background, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            addHorizontalSpacing(10),
            Text(
              'Tap on',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            addHorizontalSpacing(10),
            Align(
              alignment: Alignment.bottomLeft,
              child: Center(
                child: RenderSvg(
                  svgPath: VIcons.colorFilter,
                  color: Colors.white,
                ),
              ),
            ),
            addHorizontalSpacing(10),
            Expanded(
              child: Text(
                'to view recommended posts.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget discover() {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(08),
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme?.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            addHorizontalSpacing(10),
            Text(
              'Tap on',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            addHorizontalSpacing(10),
            Align(
              alignment: Alignment.bottomLeft,
              child: Center(
                child: RenderSvg(
                  svgPath: VIcons.discoverFeedActionIcon,
                  color: Colors.white,
                ),
              ),
            ),
            addHorizontalSpacing(10),
            Text(
              'to visit the discover page.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).buttonTheme.colorScheme!.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void showMessage() async {
    await Future.delayed(1.seconds);
    bool random = Random().nextBool();
    var flushbar = Flushbar(
      messageText: random ? recommended() : discover(),
      duration: 4.seconds,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
    flushbar.show(context);
  }

  @override
  Widget build(BuildContext context) {
    initWS();
    Timer(Duration(seconds: 1), () {
      if (!mounted) return;
      ref.read(contextProvider.notifier).state = context;
    });

    final fProvider = ref.watch(feedProvider.notifier);
    final isProView = ref.watch(isProViewProvider);
    final isRecommendedView = ref.watch(isRecommendedViewNotifier);
    final recommendedViewNotifier = ref.read(isRecommendedViewNotifier.notifier);
    feedTitle = isRecommendedView ? 'Recommended' : 'Feed';
    //print('isRecommendedView: ${isRecommendedView}');

    return PopToBackgroundWrapper(
      child: GestureDetector(
        onTap: () {
          closeAnySnack();
        },
        child: AnimatedSwitcher(
            switchInCurve: Curves.bounceInOut,
            switchOutCurve: Curves.easeOutCirc,
            duration: const Duration(seconds: 5),
            reverseDuration: const Duration(seconds: 1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                key: Key('feedScaffold'),
                // backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
                appBar: VWidgetsAppBar(
                  // backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : null,
                  isFeedScreen: false,
                  centerTitle: false,
                  appbarTitle: fProvider.isFeed ? feedTitle : "",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),

                  trailingIcon: [
                    ///Navigates to contentView page
                    IconButton(
                      onPressed: () {
                        ref.read(exploreProvider.notifier).isExplorePage(isExploreOnly: false);

                        ref.read(dashTabProvider.notifier).colorsChangeBackGround(1);
                        ref.read(inContentView.notifier).state = true;
                        ref.read(playVideoProvider.notifier).state = true;
                        ref.read(inContentScreen.notifier).state = true;
                        VMHapticsFeedback.lightImpact();
                        context.push('/contentView');
                        // navigationModel.navigationModel?.goBranch(4, initialLocation: true);
                      },
                      icon: RenderSvg(
                        svgPath: ref.watch(inContentView) ? VIcons.homeLiveFilled : VIcons.homeLiveOutlineIcon,
                        color: ref.watch(inContentView) ? Colors.white : Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                    IconButton(
                      icon: RenderSvg(
                        svgPath: VIcons.liveClassCreateIcon,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      onPressed: () {
                        VMHapticsFeedback.lightImpact();
                        ref.read(inLiveClass.notifier).state = false;
                        // ref.read(isGoToDiscover.notifier).state = true;
                        context.push(Routes.liveClassesMarketplacePage);
                      },
                    ),
                    Consumer(
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 0, right: 0),
                          child: Row(
                            children: [
                              if (fProvider.isFeed)
                                GestureDetector(
                                  onTap: () {
                                    VMHapticsFeedback.lightImpact();

                                    recommendedViewNotifier.setRecommended(!isRecommendedView);

                                    if (!isRecommendedView) {
                                      setState(() {
                                        feedTitle = "Recommended";
                                        //feedTitle = "Feed";
                                      });
                                    } else {
                                      setState(() {
                                        //feedTitle = "Recommended";
                                        feedTitle = "Feed";
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 13),
                                    child: RenderSvg(
                                      svgPath: VIcons.colorFilter,
                                      color: isRecommendedView ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () {
                                  if (!isProView) {
                                    Future.delayed(Duration(seconds: 3), () {
                                      showAnimatedDialog(
                                        context: context,
                                        child: AlertDialog(
                                          insetPadding: EdgeInsets.symmetric(horizontal: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                          contentPadding: EdgeInsets.zero,
                                          content: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.asset(
                                                  'assets/images/discover_images/Group 1171275244.jpg',
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  height: 40,
                                                  // width: 150,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  }
                                  VMHapticsFeedback.lightImpact();
                                  final current = ref.read(isProViewProvider.notifier).state;
                                  ref.read(isProViewProvider.notifier).state = !current;
                                  setState(
                                    () {
                                      isProView
                                          ? isRecommendedView
                                              ? feedTitle = "Recommended"
                                              : feedTitle = "Feed"
                                          : feedTitle = "Slides";
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 13),
                                  child: isProView
                                      ? RenderSvg(
                                          svgPath: VIcons.videoFilmIcon,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : RenderSvg(
                                          svgPath: VIcons.videoFilmIcon,
                                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                body: switch (isRecommendedView) {
                  true => Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: RecommendedFeed(
                        key: Key(
                          'recommendedPage',
                        ),
                      )),
                  false => Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FeedHomeView(
                          key: Key(
                        'feedPage',
                      )),
                    )
                },
              ),
            )),
      ),
    );
  }
}
