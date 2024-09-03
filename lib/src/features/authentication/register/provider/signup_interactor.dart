import 'package:get/get.dart';
import 'package:vmodel/src/features/authentication/register/provider/signup_controller.dart';

class SignupInteractor {
  static void onIndustrySelected(String type) {
    var controller = Get.find<SignupController>();
    controller.selectedIndustry(type);
  }

  static void onContinueClicked(context) {
    var controller = Get.find<SignupController>();
    context.push("/onboardingEmail/${controller.selectedIndustry.string}");
    /*navigateToRoute(
        context,
        OnboardingEmail(
          selectedIndustry: controller.selectedIndustry.string,
        ));*/
  }
}
