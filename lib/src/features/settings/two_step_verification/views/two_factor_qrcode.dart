import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:quiver/iterables.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/auth_app_two_fa_otp_verification.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card2.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/cache/credentials.dart';
import '../../../../core/cache/local_storage.dart';
import '../../../../res/gap.dart';
import '../../../../shared/appbar/appbar.dart';
import '../../../../shared/response_widgets/toast.dart';
import '../../../../shared/switch/primary_switch.dart';
import '../controller/2fa_controller.dart';
import 'login_to_continue.dart';

class TwoFactorQRCode extends ConsumerStatefulWidget {
  static const title = 'Two factor authentication';
  static const route = '/two_factor_qrcode';
  TwoFactorQRCode({Key? key}) : super(key: key);

  @override
  ConsumerState<TwoFactorQRCode> createState() => _TwoFactorQRCodeState();
}

class _TwoFactorQRCodeState extends ConsumerState<TwoFactorQRCode> {
  final _instructions = <String>[
    'Download an authenticator app like <b>Google Authenticator</b> or <b>Microsoft Authenticator.</b>',
    'Within the app, select </b>"Add Account"</b> and choose the option to scan a QR code or enter a setup key.',
    "Use the app to <b>\"scan the QR code\"</b> displayed below or manually enter the key we've provided for you",
    'The app will generate a unique code - <b>enter this code on the next screen</b> to complete the setup.',
    'Your VModel account is now secured with two-factor authentication!'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user2FA = ref.watch(twoStepVerificationProvider);
    return Scaffold(
        appBar: const VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: TwoFactorQRCode.title,
        ),
        body: SafeArea(
          child: Padding(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Column(children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: context.isDarkMode
                          ? VmodelColors.notificationDarkModeOverlayColor
                          : VmodelColors.onSurfaceVariantLight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...enumerate(_instructions).map((each) {
                          int index = each.index + 1;
                          String instruction = each.value;
                          return Container(
                              child: Column(
                            children: [
                              Html(
                                data: '<p>$index. $instruction</p>',
                                style: {
                                  "p": Style(
                                      margin: Margins.zero,
                                      fontSize: FontSize(16),
                                      fontWeight: FontWeight.normal),
                                  "b": Style(fontWeight: FontWeight.w600),
                                },
                              ),
                            ],
                          ));
                        }).toList(),
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                height: 250,
                                width: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'https://play-lh.googleusercontent.com/lomBq_jOClZ5skh0ELcMx4HMHAMW802kp9Z02_A84JevajkqD87P48--is1rEVPfzGVf=w240-h480-rw'), // URL to your network image
                                    fit: BoxFit
                                        .cover, // Cover the entire container
                                  ),
                                ),
                              ),
                              Text(
                                '63388hjsjsgugeigegeiuegiuegeugeuu',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: !context.isDarkMode
                                        ? Theme.of(context).primaryColor
                                        : Colors.white),
                              ),
                              addVerticalSpacing(10),
                              SizedBox(
                                width: 60,
                                height: 25,
                                child: VWidgetsPrimaryButton(
                                  onPressed: () {},
                                  buttonTitle: "Copy",
                                  buttonTitleTextStyle: TextStyle(fontSize: 13),
                                  enableButton: true,
                                  buttonColor: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme
                                      ?.background,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                addVerticalSpacing(25),
                SizedBox(
                  // width: 150,
                  child: VWidgetsPrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AuthAppTwoFaOtpVerificationScreen()),
                      );
                    },
                    buttonTitle: "Continue",
                    enableButton: true,
                    buttonColor:
                        Theme.of(context).buttonTheme.colorScheme?.background,
                  ),
                )
              ])),
        ));
  }
}
