import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/models/user.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/authentication/login/models/device_info_model.dart';
import 'package:vmodel/src/features/authentication/login/models/login_res_model.dart';
import 'package:vmodel/src/features/authentication/login/repository/login_repo.dart';
import 'package:vmodel/src/pushnotification.helper.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/controller/user_prefs_controller.dart';
import '../../../../core/network/graphql_confiq.dart';
import '../../../../core/utils/enum/auth_enum.dart';
import '../../../../res/colors.dart';
import '../../../dashboard/dash/controller.dart';
import '../../controller/auth_status_provider.dart';
import '../../register/provider/user_types_controller.dart';

final loginProvider = StateNotifierProvider((ref) {
  return LoginProvider(ref);
});

final deviceInfoProvider = FutureProvider<DeviceInfoModel>((ref) async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    return DeviceInfoModel(
        OS: 'Android ${androidInfo.version.release}',
        deviceName: '${androidInfo.manufacturer} ${androidInfo.model}');
  } else {
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    return DeviceInfoModel(
        OS: '${iosInfo.systemName} ${iosInfo.systemVersion}',
        deviceName: '${iosInfo.name} ${iosInfo.model}');
  }
});

class LoginProvider extends StateNotifier<LoginStateModel>
    with VValidatorsMixin {
  LoginProvider(this.ref) : super(LoginStateModel());

  final Ref ref;

  /// username or email variable depending on the used
  /// login process, this is likely used in [verify2FACode] for OTP verification
  String _emailOrUsername = '';
//to run on login init
  runInit() {}

//to get provider state
  LoginStateModel get getState => state;

  // getter an variable for password obscure
  static bool obscure = true;
  bool get getPasswordObscure => obscure;

//logic for login session start
  Future<bool> startLoginSession(
      String userName, String password, BuildContext context,
      {bool isSignUp = false, bool isResending = false , required String location}) async {
    dismissKeyboard();
    await ref.read(deviceInfoProvider.future);
    final deviceInfo = ref.read(deviceInfoProvider).requireValue;

    // assigns the entered username
    _emailOrUsername = userName;

//make request based on check
    final makeLoginRequest = //check == false
        await loginRepoInstance.loginWithUserName(
      userName,
      password,
      deviceInfo,
    );
    makeLoginRequest.fold((onLeft) {
      if (onLeft.message.contains('limit')) {
        // responseDialog(context,
        //     "Too many sign-in attempts. Please try again in 5 minutes");
        SnackBarService().showSnackBar(
            message: "Too many sign-in attempts. Please try again in 5 minutes",
            context: context);
      } else {
        // responseDialog(context, "Incorrect username or password");
        SnackBarService().showSnackBar(
            icon: VIcons.emptyIcon,
            message: "Incorrect username or password",
            context: context);
      }

      return false;

      //run this block when you have error
    }, (onRight) async {
      //if the success field in the mutation response is true
      final success = onRight['success'] ?? false;
      final isUse2FA = onRight['use2fa'] ?? false;
      if (success && isUse2FA) {
        context.push('/verify_2fa_otp');
        return false;
      }

      if (success) {
        await VCredentials.inst.storeUserCredentials(json.encode({
          'username': userName,
          'password': password,
        }));

        final restToken = onRight['restToken'] ?? '';

        //run this block when you have data
        LoginResponsModel responsModel = LoginResponsModel.fromJson(onRight);
        state = state.copyWith(
          loginResponse: responsModel,
        );
        state = state.copyWith(
            vuser: VUser(
          username: state.loginResponse?.username,
          firstName: state.loginResponse?.firstName,
          lastName: state.loginResponse?.lastName,
          bio: state.loginResponse?.bio,
          pk: state.loginResponse?.pk,
          token: state.loginResponse?.token,
        ));

        userIDPk = state.loginResponse?.pk;
        VConstants.logggedInUser = state.vuser;
        // userIDPk = state.loginResponse?.pk;
        globalUsername = state.loginResponse?.username;
        GraphQlConfig.instance.updateToken(state.loginResponse?.token);
        GraphQlConfig.instance.updateRestToken(restToken);
        final storeUsername = VModelSharedPrefStorage()
            .putString(VSecureKeys.username, state.loginResponse?.username);

        // Commenting this out. Token shouldn't be stored in SharedPreferences
        final storeToken = VModelSharedPrefStorage()
            .putString(VSecureKeys.userTokenKey, state.loginResponse?.token);
        await VCredentials.inst
            .storeUserCredentials(state.loginResponse?.token);

        await Future.wait([storeToken, storeUsername]);

        ref.invalidate(appUserProvider);

        ref.watch(dashTabProvider.notifier).initFCM(context, ref);

        if (isSignUp) {
          final userConfigs = ref.read(userPrefsProvider).value!;
          ref
              .read(userPrefsProvider.notifier)
              .addOrUpdatePrefsEntry(userConfigs.copyWith(
                savedAuthStatus: AuthStatus.firstLogin,
                // preferredLightTheme: _preferredTheme,
              ));
          ref
              .read(authenticationStatusProvider.notifier)
              .updateStatus(AuthStatus.firstLogin);
        } else {
          ref
              .read(authenticationStatusProvider.notifier)
              .updateStatus(AuthStatus.authenticated);
        }
        if (context.mounted) {
          if (!isResending) {
            context.push('/UserVerificationScreen', extra: location);
          }
        }
        return true;
      } else {
        VLoader.changeLoadingState(false);
        VWidgetShowResponse.showToast(ResponseEnum.failed,
            message: onRight['errors']);

        ref
            .read(authenticationStatusProvider.notifier)
            .updateStatus(AuthStatus.unauthenticated);
        if (context.mounted) {
          if (!isResending) {
            context.go('/auth_widget');
          }
        }
        return false;
      }
    });
    return false;
  }

  /// verification process done for 2FA especially when logging in with a new device
  Future<bool> verify2FACode(BuildContext context,
      {required String code}) async {
    dismissKeyboard();
    //start loading
    bool isUsername = VValidatorsMixin.isUserNameValidator(_emailOrUsername);

//make request based on check
    final makeLoginRequest = await loginRepoInstance.verify2FACode(
      code: code,
      username: isUsername ? _emailOrUsername : null,
      email: !isUsername ? _emailOrUsername : null,
    );
    // navigateToRoute(context, const DashBoardView());

    makeLoginRequest.fold((onLeft) {
      // VLoader.changeLoadingState(false);
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: 'Invalid credentials');
      return false;

      //run this block when you have error
    }, (onRight) async {
      final authToken = onRight['token'] as String?;
      if (!authToken.isEmptyOrNull) {
        final restToken = onRight['restToken'] ?? '';

        GraphQlConfig.instance.updateToken(authToken!);
        GraphQlConfig.instance.updateRestToken(restToken);
        final user = onRight['user'];

        await VCredentials.inst.storeUserCredentials(authToken);
        //store username
        await VModelSharedPrefStorage()
            .putString(VSecureKeys.username, user['username']);

        await FirebaseApi().initNotification(context);

        ref
            .read(authenticationStatusProvider.notifier)
            .updateStatus(AuthStatus.authenticated);

        if (context.mounted) {
          // goBack(context);
          context.go('/auth_widget');
          //navigateAndRemoveUntilRoute(context, const AuthWidgetPage());
        }

        return true;
      } else {
        final errorMessageFromApi = onRight['errors'];
        //stop loading and show response
        VLoader.changeLoadingState(false);
        VWidgetShowResponse.showToast(ResponseEnum.failed,
            message: onRight['errors']);

        ref
            .read(authenticationStatusProvider.notifier)
            .updateStatus(AuthStatus.unauthenticated);
        if (context.mounted) {
          context.go('/auth_widget');
        }
        return false;
      }
    });
    return false;
  }

//logic for login session start
  startSocialLoginSession(String provider, String accessToken,
      String? firstName, String? lastName, BuildContext context,
      {required AuthStatus authState}) async {
    dismissKeyboard();
    //start loading
    VLoader.changeLoadingState(true, context: context);

    final userType = ref.watch(selectedAccountTypeProvider.notifier);
    final isBusinessAccount = ref.watch(isAccountTypeBusinessProvider.notifier);

    final makeLoginRequest = await loginRepoInstance.socialAuth(
        provider,
        accessToken,
        firstName,
        lastName,
        isBusinessAccount.state,
        userType.state);

    makeLoginRequest.fold((onLeft) {
      VLoader.changeLoadingState(false, context: context);
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: onLeft.message);
    }, (onRight) async {
      if ((onRight['social']['id'] != null && onRight['token'] != null) ==
          true) {
        userIDPk = int.parse(onRight['user']['id']);
        await VCredentials.inst.setUserToken(onRight['token']);

        Map<String, dynamic> user = onRight['user'];
        await VCredentials.inst.storeUserCredentials(json.encode({
          'username': user['userName'],
          'password': '',
        }));

        final restToken = onRight['restToken'] ?? '';

        //run this block when you have data
        LoginResponsModel responsModel = LoginResponsModel.fromJson(onRight);
        state = state.copyWith(
          loginResponse: responsModel,
        );
        state = state.copyWith(
            vuser: VUser(
          username: state.loginResponse?.username,
          firstName: state.loginResponse?.firstName,
          lastName: state.loginResponse?.lastName,
          bio: state.loginResponse?.bio,
          pk: state.loginResponse?.pk,
          token: onRight['token'],
        ));

        userIDPk = state.loginResponse?.pk;
        VConstants.logggedInUser = state.vuser;
        globalUsername = state.loginResponse?.username;
        GraphQlConfig.instance.updateToken(onRight['token']);
        GraphQlConfig.instance.updateRestToken(restToken);
        final storeUsername = VModelSharedPrefStorage()
            .putString(VSecureKeys.username, state.loginResponse?.username);

        // Commenting this out. Token shouldn't be stored in SharedPreferences
        final storeToken = VModelSharedPrefStorage()
            .putString(VSecureKeys.userTokenKey, onRight['token']);
        await VCredentials.inst.storeUserCredentials(onRight['token']);

        await Future.wait([storeToken, storeUsername]);

        ref.invalidate(appUserProvider);

        ref.watch(dashTabProvider.notifier).initFCM(context, ref);

        ref.read(authenticationStatusProvider.notifier).updateStatus(authState);

        VLoader.changeLoadingState(false, context: context);
        if (context.mounted) {
          context.push('/UserVerificationScreen');
        }
        return true;
      }
    });
  }

// logic to change obscure state
  changeObScureState() {
    state = state.copyWith(
      isObscurePassword: !obscure,
    );
    obscure = state.isObscurePassword!;
  }

  //change rememberMe
  changeRememberMeState(bool? value) {
    state = state.copyWith(rememberMeOnLogin: value);
  }

  //authenticate with biometrics
  authenticateWithBiometrics(BuildContext context) async {
    bool isAuthenticated = await BiometricService.authenticateUser();
    if (isAuthenticated) {
      // // // ignore: use_build_context_synchronously
      VLoader.changeLoadingState(true);
      final getUserCredentials = await VCredentials.inst.getUserCredentials();
      VLoader.changeLoadingState(false);
      if (getUserCredentials != null) {
        final Map<String, dynamic> userMappedData =
            json.decode(getUserCredentials);
        // ignore: use_build_context_synchronously
        startLoginSession(
            userMappedData['username'], userMappedData['password'], context , location: 'login');
      } else {
        VWidgetShowResponse.showToast(ResponseEnum.failed,
            message: "Please login and enable your biometrics");
      }
    } else {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Authentication failed");
    }
  }

  //authenticate with biometrics
  Future<bool> authenticateWithBiometricsNew(BuildContext context) async {
    VLoader.changeLoadingState(true);
    bool isAuthenticated = await BiometricService.authenticateUser();
    VLoader.changeLoadingState(false);
    return isAuthenticated;
  }
}

//model to handle UI in your riverpod
class LoginStateModel {
  String? userName;
  String? password;
  bool? isLoading;
  bool? isUserNameType;
  bool? isObscurePassword;
  bool? rememberMeOnLogin;
  LoginResponsModel? loginResponse;
  VUser? vuser;

  LoginStateModel({
    this.isLoading,
    this.isUserNameType,
    this.password,
    this.userName,
    this.isObscurePassword = true,
    this.rememberMeOnLogin = false,
    this.loginResponse,
    this.vuser,
  });

  LoginStateModel copyWith(
      {String? userName,
      String? password,
      bool? isLoading,
      bool? isUserNameType,
      bool? isObscure,
      bool? checkboxValue,
      bool? rememberMeOnLogin,
      bool? isObscurePassword,
      VUser? vuser,
      LoginResponsModel? loginResponse}) {
    return LoginStateModel(
      userName: userName ?? this.userName,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isUserNameType: isUserNameType ?? this.isUserNameType,
      rememberMeOnLogin: rememberMeOnLogin ?? this.rememberMeOnLogin,
      isObscurePassword: isObscurePassword ?? this.isObscurePassword,
      loginResponse: loginResponse ?? this.loginResponse,
      vuser: vuser ?? this.vuser,
    );
  }
}

class SocialAuth {
  static Future<UserCredential?> signInWithGoogle(
      {required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    late AuthCredential credential;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    UserCredential? userCredential;
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          Fluttertoast.showToast(
              msg: "The account already exists with a different credential.",
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: VmodelColors.error.withOpacity(0.6),
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (e.code == 'invalid-credential') {
          Fluttertoast.showToast(
              msg: "Error occurred while accessing credentials. Try again.",
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: VmodelColors.error.withOpacity(0.6),
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (e, s) {
        logger.e(e.toString(), stackTrace: s);
        // handle the error here
      }
    }
    return userCredential;
  }

  static Future<UserCredential> signInWithFacebook(
      {required BuildContext context}) async {
    final LoginResult loginResult = await FacebookAuth.instance
        .login(permissions: ['email', 'public_profile', 'user_birthday']);

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  static Future facebookSignIn(LoginProvider loginNotifier,
      BuildContext context, AuthStatus authState) async {
    UserCredential credentials =
        await SocialAuth.signInWithFacebook(context: context);
    List<String> nameParts = credentials.user!.displayName!.split(' ');
    loginNotifier.startSocialLoginSession(
        "facebook",
        credentials.credential!.accessToken!,
        nameParts[0],
        nameParts[1] ?? '',
        context,
        authState: authState);
  }

  static Future googleSignIn(LoginProvider loginNotifier, BuildContext context,
      AuthStatus authState) async {
    UserCredential? credentials = await SocialAuth.signInWithGoogle(
      context: context,
    );
    if (credentials != null) {
      List<String> nameParts = credentials.user!.displayName!.split(' ');
      loginNotifier.startSocialLoginSession(
          "google-oauth2",
          credentials.credential!.accessToken!,
          nameParts[0],
          nameParts[1] ?? '',
          context,
          authState: authState);
    }
  }
}
