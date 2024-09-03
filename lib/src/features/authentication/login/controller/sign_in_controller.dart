import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/arch_utils/mvc/mvc.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/authentication/login/provider/login_provider.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/login_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/enum/auth_enum.dart';

part '../views/sign_in_view.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const name = "login";
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => LoginPageController();
}

class LoginPageController extends ConsumerState<LoginPage> {
  final TextEditingController usermail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final showLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    showLoading.dispose();
    usermail.dispose();
    password.dispose();
    super.dispose();
  }

  void signIn(LoginProvider loginNotifier) async {
    VMHapticsFeedback.lightImpact();
    try {
      if (formKey.currentState!.validate()) {
        showLoading.value = true;
        final result = await loginNotifier.startLoginSession(
          usermail.text.toLowerCase(),
          password.text,
          context, location: 'login',
          
        );
        if (!result) {
          showLoading.value = false;
        }
      } else {
        showLoading.value = false;
        VWidgetShowResponse.showToast(
          ResponseEnum.warning,
          message: "Please fill all fields",
        );
      }
    } on Exception {
      showLoading.value = false;
    }
  }

  void facebookSignIn(LoginProvider loginNotifier, AuthStatus authState) async {
    UserCredential credentials = await SocialAuth.signInWithFacebook(context: context);
    List<String> nameParts = credentials.user!.displayName!.split(' ');
    loginNotifier.startSocialLoginSession(
      "facebook",
      credentials.credential!.accessToken!,
      nameParts[0],
      nameParts[1]??'',
      context,
      authState: authState
    );
  }

  void googleSignIn(LoginProvider loginNotifier, AuthStatus authState,bool isLogin) async {
    UserCredential? credentials = await SocialAuth.signInWithGoogle(
      context: context,
    );
    if(credentials!=null){
      List<String> nameParts = credentials.user!.displayName!.split(' ');
      loginNotifier.startSocialLoginSession(
        "google-oauth2",
        credentials.credential!.accessToken!,
          isLogin==true?null:nameParts[0],
          isLogin==true?null:nameParts[1]??'',
        context,
          authState: authState
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageView(this);
  }
}
