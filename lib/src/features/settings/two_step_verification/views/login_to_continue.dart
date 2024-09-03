import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/text_fields/login_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../shared/appbar/appbar.dart';
import 'two_factor_authentication.dart';

class LoginToContinueScreen extends ConsumerStatefulWidget {
  static const title = 'Login to continue';
  static const route = '/login_to_continue';
  LoginToContinueScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginToContinueScreen> createState() =>
      _LoginToContinueScreenState();
}

class _LoginToContinueScreenState extends ConsumerState<LoginToContinueScreen> {

    final TextEditingController _password = TextEditingController();



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: LoginToContinueScreen.title,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 18, right: 18, bottom: 18),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Please enter your password to continue',
                  style: TextStyle(color: Colors.grey),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [


                        AuthTextField(
                    hintText: "Password",
                    controller: _password,
                    keyboardType: TextInputType.visiblePassword,
                    // obscureText: loginNotifier.getPasswordObscure,
                    onChanged: (val) {},
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                  ),

                  
                      // TextField(
                      //   obscureText: true,
                      //   cursorColor: !context.isDarkMode
                      //       ? Theme.of(context).primaryColor
                      //       : Colors.white,
                      //   decoration: InputDecoration(
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //         color: Colors.transparent,
                      //       ),
                      //       borderRadius:
                      //           BorderRadius.circular(10.0), // Rounded corners
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: !context.isDarkMode
                      //               ? Theme.of(context).primaryColor
                      //               : VmodelColors.white,
                      //           width: 2.0),
                      //       borderRadius:
                      //           BorderRadius.circular(10.0), // Rounded corners
                      //     ),
                      //   ),
                      // ),



                      VWidgetsTextButton(
                        text: 'Forgot password?',
                        onPressed: () {},
                        textStyle: context.textTheme.displayMedium!
                            .copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  // width: 150,
                  child: VWidgetsPrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TwoFactorAuthentication()),
                      );
                    },
                    buttonTitle: "Continue",
                    enableButton: true,
                    buttonColor:
                        Theme.of(context).buttonTheme.colorScheme?.background,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
