import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/two_factor_qrcode.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/security_and_privacy_settings.dart';
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
import 'email_two_fa_otp_verification.dart';
import 'sms_two_fa_otp_verification.dart';

class TwoFactorAuthentication extends ConsumerStatefulWidget {
  static const title = '2 Factor Authenticator (2FA)';
  static const route = '/two_factor_authentication';
  TwoFactorAuthentication({Key? key}) : super(key: key);

  @override
  ConsumerState<TwoFactorAuthentication> createState() =>
      _TwoFactorAuthenticationState();
}

class _TwoFactorAuthenticationState
    extends ConsumerState<TwoFactorAuthentication> {
  double _titleFontSize = 16;
  double _subTextFontSize = 13;
  double _iconSize = 20;

  final _authChannels = <Map<String, dynamic>>[
    {
      'channel': 'SMS',
      'icon': Icons.sms,
      'info': "We'll send a verification code to your phone number",
      'disabled': false,
      'goto': SmsTwoFaOtpVerificationScreen(),
    },
    {
      'channel': 'Authenticator',
      'icon': Icons.security,
      'info': 'Install an authenticator app to generate a verification code',
      'disabled': false,
      'goto': TwoFactorQRCode(),
    },
    {
      'channel': 'Email',
      'icon': Icons.mail,
      'info': "You'll receive a verification code in your email.",
      'disabled': false,
      'goto': EmailTwoFaOtpVerificationScreen(),
    },
    {
      'channel': 'Face ID',
      'icon': Icons.face,
      'info': "You'll receive a verification code in your email.",
      'disabled': false,
      'goto': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user2FA = ref.watch(twoStepVerificationProvider);
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(
          onTap: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => AccountSettingsPage()),
            );
            Navigator.pop(
              // todo: Remove duplicate pop(); using it now as a temporary fix to move back to the AccountSettingsPage.
              context,
              MaterialPageRoute(builder: (context) => AccountSettingsPage()),
            );
          },
        ),
        appbarTitle: TwoFactorAuthentication.title,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: context.isDarkMode
                      ? VmodelColors.notificationDarkModeOverlayColor
                      : VmodelColors.onSurfaceVariantLight,
                ),
                child: Column(
                  children: _authChannels.map((el) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            el['icon'],
                            size: _iconSize,
                          ),
                          addHorizontalSpacing(10),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  el['channel'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: _titleFontSize,
                                      ),
                                ),
                                addVerticalSpacing(5),
                                Text(
                                  el['info'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        fontSize: _subTextFontSize,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          VWidgetsSwitch(
                            swicthValue: el['disabled'],
                            onChanged: (p0) {
                              setState(() {
                                el['disabled'] = !el['disabled'];
                              });
                              if (el['goto'] == null) {
                                return;
                              }
                              if (el['disabled']) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => el['goto']),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Column(
                children: [
                  Text(
                    "Two-Factor Authentication (2FA) adds an extra layer of security to your accounts. Instead of just entering a password to log in, 2FA requires a second piece of information - like a code from your phone. This way, even if someone knows your password, they can't access your account without that second step. It's like having two locks on your door instead of one.",
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
