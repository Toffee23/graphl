import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../widgets/cupertino_switch_card2.dart';

class InAppNotificationSetting extends ConsumerStatefulWidget {
  // todo: Remove this screen as it is not in use.
  const InAppNotificationSetting({super.key});

  @override
  ConsumerState<InAppNotificationSetting> createState() =>
      _InAppNotificationSettingState();
}

class _InAppNotificationSettingState
    extends ConsumerState<InAppNotificationSetting> {
  bool alertProfileVisit = false;

  @override
  void initState() {
    alertProfileVisit =
        ref.read(appUserProvider).valueOrNull!.alertOnProfileVisit;
    super.initState();
  }

  final interactions = <Map<String, dynamic>>[
    {'title': 'Likes', 'isSelected': false},
    {'title': 'Comments', 'isSelected': false},
    {'title': 'New Followers', 'isSelected': false},
    {'title': 'Profile View', 'isSelected': false},
    {
      'title': 'Post you interacted with',
      'subTitle':
          'Get notified when a follower comments or likes another friends post',
      'isSelected': false
    },
  ];

  final messages = <Map<String, dynamic>>[
    {'title': 'My Activity', 'isSelected': false},
    {'title': 'Messages', 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "In-app Notifications",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          addVerticalSpacing(10),
          Text('Interactions',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor.withOpacity(0.6))),
          addVerticalSpacing(10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // radius of 10
              color: context.isDarkMode ? null : VmodelColors.lightGreyColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: interactions
                  .map(
                    (el) => Container(
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: VWidgetsCupertinoSwitchWithText2(
                          titleText: el['title'].toString(),
                          trailingText: el['trailingText'],
                          subTitle: el['subTitle'],
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          value: el['isSelected'],
                          onChanged: ((p0) {
                            setState(() {
                              el['isSelected'] = !el['isSelected'];
                            });
                            return el['isSelected'];
                          }),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          addVerticalSpacing(30),
          Text('Messages',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor.withOpacity(0.6))),
          addVerticalSpacing(10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // radius of 10
              color: context.isDarkMode ? null : VmodelColors.lightGreyColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: messages
                  .map(
                    (el) => Container(
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: VWidgetsCupertinoSwitchWithText2(
                          titleText: el['title'].toString(),
                          trailingText: el['trailingText'],
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          value: el['isSelected'],
                          onChanged: ((p0) {
                            setState(() {
                              el['isSelected'] = !el['isSelected'];
                            });
                            return el['isSelected'];
                          }),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
