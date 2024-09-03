import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/arch_utils/mvc/mvc.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/widgets/dropdown_selection_widget.dart';
import 'package:vmodel/src/vmodel.dart';

import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/authentication/register/provider/user_types_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

import './select_account_type.dart';
part '../views/new_user_onboarding.dart';

class UserOnBoardingPage extends ConsumerStatefulWidget {
  static const name = "signup/selection";
  const UserOnBoardingPage({super.key});

  @override
  ConsumerState<UserOnBoardingPage> createState() =>
      UserOnBoardingPageController();
}

class UserOnBoardingPageController extends ConsumerState<UserOnBoardingPage> {
  ValueNotifier<(String, Map<String, List<String>>)?> iAm = ValueNotifier(null);
  String? accountType;
  String? subCategory;
  List<String> subCategoryBasis = [];
  List<String> _chefCategories = [
    "Culinary Chef",
    "Pastry Chef",
    "Sous Chef",
    "Executive Chef",
    "Personal Chef",
    "Cuisine Chef",
    "Italian Cuisine Chef",
    "Asian Cuisine Chef",
    "French Cuisine Chef",
    "Mexican Cuisine Chef",
    "Dietary Chef",
    "Vegan Chef",
    "Gluten-Free Chef",
    "Keto Chef",
    "Paleo Chef",
    "Event Chef",
    "Wedding Chef",
    "Catering Chef",
    "Private Event Chef",
    "Festival Chef",
  ];

  bool get enableContinueButton {
    if (accountType != null) {
      if (accountType == 'booker' ||
          // accountType == 'chef' ||
          accountType == 'baker' ||
          accountType == 'eventPlanner') {
        return true;
        // if (subCategory != null) {
        //   return true;
        // }
      }
      if (subCategory != null) {
        return true;
      }
    }
    return false;
  }

  void canContinue() {
    String cleanedType = accountType == 'eventPlanner'
        ? 'Event Planner'
        : accountType == 'digitalCreator'
            ? 'Digital Creator'
            : accountType!;

    ref.read(selectedAccountTypeProvider.notifier).state = cleanedType;
    if (accountType == 'booker' ||
        // accountType == 'chef' ||
        accountType == 'baker' ||
        accountType == 'eventPlanner') {
      ref.read(selectedAccountLabelProvider.notifier).state = '';
    } else {
      ref.read(selectedAccountLabelProvider.notifier).state = subCategory!;
    }

    // ref.read(isAccountTypeBusinessProvider.notifier).state =
    //     iAm.value!.$1 == 'enterprise' ? true : false;

    context.push('/sign_up');
  }

  // void selectIam() async {
  //   var iAmChoice =
  //       await showAccountTypeSelection<(String, Map<String, List<String>>)>(
  //     context: context,
  //   );
  //   if (iAmChoice != null) {
  //     iAm.value = iAmChoice;
  //     accountType = null;
  //     subCategory = null;
  //     setState(() {});
  //   }
  // }

  void selectAccountType() async {
    var a = await showAccountTypeOfIam<(String, List<String>)?>(
      context: context,
      // types: iAm.value!.$2,
    );
    // final b = a!.$2;

    accountType = a!.$1;
    subCategoryBasis =
        accountType?.toLowerCase() == "chef" ? _chefCategories : a.$2;
    subCategory = null;
    setState(() {});
  }

  void selectSubCategory() async {
    var a = await showSubCategoryOfAccount<String?>(
      context: context,
      types: subCategoryBasis,
    );
    if (a != null) {
      subCategory = a;
      setState(() {});
    }
  }

  @override
  void dispose() {
    iAm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserOnBoardingPageView(this);
  }
}
