import 'package:go_router/go_router.dart';
import 'package:vmodel/src/vmodel.dart';

class PasswordInteractor {
  static void onForgotPasswordClicked(BuildContext context) {
    //navigateToRoute(context, ForgotPasswordView());
    context.push("/reset_password_provider");
  }

  static void onCreatePassword(BuildContext context) {
    String? link = null;
    context.push("/createPasswordView/$link");
    //navigateToRoute(context, CreatePasswordView());
  }
}
