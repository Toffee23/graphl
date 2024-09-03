import 'package:go_router/go_router.dart';
import 'package:vmodel/src/vmodel.dart';

class LoginInteractor {
  static void onSignupClicked(BuildContext context) {
    context.push("/SignupView");
    //navigateToRoute(context, const SignupView());
  }
}
