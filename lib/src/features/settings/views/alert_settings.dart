import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_settings_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/models/notification_preference_model.dart';
import 'package:vmodel/src/features/settings/views/email_notifications.dart';
import 'package:vmodel/src/features/settings/views/push_notifications.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card2.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class AlertSettingsPage extends ConsumerStatefulWidget {
  const AlertSettingsPage({super.key, required this.user});
  final VAppUser? user;

  @override
  ConsumerState<AlertSettingsPage> createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends ConsumerState<AlertSettingsPage> {
  bool alertReceiveBooking = false;
  bool alertFeatureMe = false;
  bool alertLikesContent = false;
  bool alertNewJobMatches = false;
  bool alertReceiveOffer = false;
  bool alertProfileVisit = false;
  bool alertSilenceAllMessages = false;
  bool alertPrintPolaroid = false;
  double _titleFontSize = 12;
  double _listItemBottomMargin = 2;
  bool disableAll = false;
  bool isNotifEnabled = false;
  NotificationPreference? notificationPreference;
  NotificationsPreferenceInputType? emailNotification;
  NotificationsPreferenceInputType? inAppNotification;

  final _advancedNotifications = <Map<String, dynamic>>[
    {'title': 'Turn off all notifications', 'isSelected': false},
  ];

  final _notificationsChannels = <Map<String, dynamic>>[
    {'title': 'Push notifications', 'goto': PushNotificationsScreen()},
    {'title': 'Email notifications', 'goto': EmailNotificationsScreen()},
  ];

  @override
  void initState() {
    alertProfileVisit = widget.user!.alertOnProfileVisit;
    super.initState();
  }

  preload() {
    disableAll =
        (ref.watch(appSettingsProvider).valueOrNull?.isEmailNotification ??
                false) &&
            (ref.watch(appSettingsProvider).valueOrNull?.isPushNotification ??
                false);

    emailNotification =
        ref.watch(appSettingsProvider).valueOrNull?.emailNotifications;
    inAppNotification =
        ref.watch(appSettingsProvider).valueOrNull?.inappNotifications;
  }

  @override
  Widget build(BuildContext context) {
    preload();

    // debugPrint("Fortune disAble ${disableAll}");
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Notifications",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(20),
        child: SingleChildScrollView(
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _notificationsChannels
                        .map(
                          (el) => Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                               horizontal: 1),
                            child: VWidgetsCupertinoSwitchWithText2(
                              titleText: el['title'].toString(),
                              trailingText: '',
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              value: el['isSelected'],
                              disabled: disableAll,
                              onTap: () {
                                if (el['goto'] == null || el['goto'] == '')
                                  return; // todo: This condition should ckeck if el['goto'] is a Widget Instance.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => el['goto']),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),

            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Advanced Settings',
                    style: TextStyle(
                        fontSize: _titleFontSize,
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).primaryColor.withOpacity(0.6))),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                      child: VWidgetsCupertinoSwitchWithText2(
                        titleText: 'Turn off all notifications',
                        // trailingText: el['trailingText'],
                        disabled: false,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        // value: el['isSelected'],
                        value: disableAll,
                        onChanged: ((p0) async {
                          setState(() {
                             !disableAll;
                          });
                          await update();
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> update() async {
    Map<String, dynamic> payload = {
      "isPushNotification": !disableAll,
      "isEmailNotification": !disableAll,
      "isSilentModeOn": false,
      "emailNotifications": emailNotification?.toJson(),
      "inappNotifications": inAppNotification?.toJson()
    };
    // print(payload);

    final result = await ref
        .read(appSettingsProvider.notifier)
        .updateNotificationPreference(payload);
    if (result) {
      SnackBarService().showSnackBar(message: "Successful", context: context);
    } else {
      SnackBarService().showSnackBarError(context: context);
    }
  }
}
