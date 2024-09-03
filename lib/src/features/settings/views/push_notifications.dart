import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_settings_controller.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/notification_preference_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../widgets/cupertino_switch_card2.dart';

class PushNotificationsScreen extends ConsumerStatefulWidget {
  static const title = 'Push Notifications';
  static const route = '/push_notifications';
  const PushNotificationsScreen({super.key});

  @override
  ConsumerState<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState
    extends ConsumerState<PushNotificationsScreen> {
  bool alertProfileVisit = false;
  bool disableAll = false;
  bool emailNotif = false;
  bool disableAllInteraction = false;
  bool buildOnce = true;
  NotificationsPreferenceInputType? inApps;
  double _listItemBottomMargin = 2;

  /// general notification
  bool newFollowers = false;
  bool profileView = false;
  bool directMessages = false;
  bool activitiesUpdate = false;

  /// general interactions
  bool likes = false;
  bool comments = false;
  bool posts = false;
  bool features = false;

  /// advanced notification
  bool advancedNotification = false;
  NotificationsPreferenceInputType? inEmail;

  @override
  void initState() {
    alertProfileVisit =
        ref.read(appUserProvider).valueOrNull!.alertOnProfileVisit;
    super.initState();
  }

  double _verticalPadding = 1;
  double _containerTopMargin = 2;
  double _containerBottomMargin = 0;

  var _generalNotifications = <Map<String, dynamic>>[
    {'title': 'New Followers', 'isSelected': false},
    {'title': 'Profile View', 'isSelected': false},
    {'title': 'Direct Messages', 'isSelected': false},
  ];

  final _interactionsNotifications = <Map<String, dynamic>>[
    {'title': 'Likes', 'isSelected': false},
    {'title': 'Comments', 'isSelected': false},
    {'title': 'New Posts', 'isSelected': false},
    {'title': 'Features', 'isSelected': false},
    {'title': 'Turn off all notifications', 'isSelected': false},
  ];

  final _advancedNotifications = <Map<String, dynamic>>[
    {'title': 'Turn off all notifications', 'isSelected': false},
  ];

  void preloadQuery() {
    disableAll =
        ref.watch(appSettingsProvider).valueOrNull?.isPushNotification ?? false;
    emailNotif =
        ref.watch(appSettingsProvider).valueOrNull?.isEmailNotification ??
            false;
    disableAllInteraction = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .myActivity ??
        false;

    inEmail = ref.watch(appSettingsProvider).valueOrNull?.emailNotifications;

    /// general notification
    // _generalNotifications[0]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .newFollowers ??
    //     false;
    // _generalNotifications[1]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .profileView ??
    //     false;
    // _generalNotifications[2]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .messages ??
    //     false;
    //
    // /// interaction notification
    // _interactionsNotifications[4]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .myActivity ??
    //     false;
    // _interactionsNotifications[0]["isSelected"] =
    //     ref.watch(appSettingsProvider).valueOrNull?.inappNotifications.likes ??
    //         false;
    // _interactionsNotifications[1]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .comments ??
    //     false;
    // _interactionsNotifications[2]["isSelected"] =
    //     ref.watch(appSettingsProvider).valueOrNull?.inappNotifications.posts ??
    //         false;
    // _interactionsNotifications[3]["isSelected"] = ref
    //         .watch(appSettingsProvider)
    //         .valueOrNull
    //         ?.inappNotifications
    //         .features ??
    //     false;

    debugPrint(
        "Fortune Payload100 ${ref.watch(appSettingsProvider).valueOrNull?.inappNotifications.toJson()}");

    /// general notification
    newFollowers = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .newFollowers ??
        false;

    profileView = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .profileView ??
        false;

    directMessages = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .messages ??
        false;

    activitiesUpdate = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .myActivity ??
        false;

    /// interaction notification
    likes =
        ref.watch(appSettingsProvider).valueOrNull?.inappNotifications.likes ??
            false;
    comments = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .comments ??
        false;
    posts =
        ref.watch(appSettingsProvider).valueOrNull?.inappNotifications.posts ??
            false;
    features = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.inappNotifications
            .features ??
        false;

    // debugPrint("Fortune buildOnce dis ${disableAll}");
    // debugPrint("Fortune buildOnce push ${_generalNotifications}");
    // debugPrint("Fortune buildOnce push ${_interactionsNotifications}");
  }

  @override
  Widget build(BuildContext context) {
    if (buildOnce) {
      preloadQuery();
      setState(() {
        buildOnce = false;
      });
    }
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: PushNotificationsScreen.title,
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: _containerBottomMargin, top: _containerTopMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6))),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(top: 5, bottom: 10),
                    margin: EdgeInsets.only(top: 5),
                    child: Container(
                      child: VWidgetsCupertinoSwitchWithText2(
                        verticalPadding: _verticalPadding,
                        titleText: 'New Followers',
                        addPadding: false,
                        // trailingText: el['trailingText'],
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        value: disableAll ? false : newFollowers,
                        onChanged: disableAll
                            ? (pI) {}
                            : (p0) async {
                                setState(() {
                                  newFollowers = !newFollowers;
                                });
                                await update();
                              },
                      ),
                    ),

                    ///todo: old list switcher
                    // child: Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: _generalNotifications
                    //       .map(
                    //         (el) => Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Container(
                    //               child: VWidgetsCupertinoSwitchWithText2(
                    //                 verticalPadding: _verticalPadding,
                    //                 titleText: el['title'].toString(),
                    //                 trailingText: el['trailingText'],
                    //                 textStyle: TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                 ),
                    //                 value:
                    //                     disableAll ? false : el['isSelected'],
                    //                 onChanged: disableAll
                    //                     ? (pI) {}
                    //                     : (p0) async {
                    //                         setState(() {
                    //                           el['isSelected'] =
                    //                               !el['isSelected'];
                    //                         });
                    //                         // debugPrint(
                    //                         //     "Fortune interactive ${_generalNotifications}");
                    //
                    //                         // await update();
                    //                         await update(_generalNotifications,
                    //                             _interactionsNotifications);
                    //
                    //                         preloadQuery();
                    //                         return el['isSelected'];
                    //                       },
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       )
                    //       .toList(),
                    // ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(bottom: 10),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'Profile View',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : profileView,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                profileView = !profileView;
                              });
                              await update();
                            },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(bottom: 10),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'Direct Messages',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : directMessages,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                directMessages = !directMessages;
                              });
                              // await update();
                              await update();
                              // preloadQuery();
                            },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    margin: EdgeInsets.only(bottom: 15),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'Activities Update',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : activitiesUpdate,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                activitiesUpdate = !activitiesUpdate;
                              });
                              // await update();
                              await update();
                              // preloadQuery();
                            },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: _containerBottomMargin, top: _containerTopMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interactions',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6))),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(top: 5, bottom: 10),
                    margin: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Container(
                      child: VWidgetsCupertinoSwitchWithText2(
                        verticalPadding: _verticalPadding,
                        titleText: 'Likes',
                        // trailingText: el['trailingText'],
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        value: disableAll ? false : likes,
                        onChanged: disableAll
                            ? (pI) {}
                            : (p0) async {
                                setState(() {
                                  likes = !likes;
                                });
                                await update();
                              },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(bottom: 10),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'Comments',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : comments,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                comments = !comments;
                              });
                              // await update();
                              await update();
                              // preloadQuery();
                            },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    // margin: EdgeInsets.only(bottom: 10),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'New Posts',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : posts,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                posts = !posts;
                              });
                              // await update();
                              await update();
                              // preloadQuery();
                            },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    padding: EdgeInsets.only(bottom: _listItemBottomMargin),
                    margin: EdgeInsets.only(bottom: 15),
                    child: VWidgetsCupertinoSwitchWithText2(
                      verticalPadding: _verticalPadding,
                      titleText: 'Features',
                      // trailingText: el['trailingText'],
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: disableAll ? false : features,
                      onChanged: disableAll
                          ? (pI) {}
                          : (p0) async {
                              setState(() {
                                features = !features;
                              });
                              // await update();
                              await update();
                              // preloadQuery();
                            },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: _containerBottomMargin, top: _containerTopMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advanced',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6))),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                    ),
                    margin: EdgeInsets.only(top: 5, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _advancedNotifications
                          .map(
                            (el) => Container(
                              child: VWidgetsCupertinoSwitchWithText2(
                                verticalPadding: _verticalPadding,
                                titleText: el['title'].toString(),
                                trailingText: el['trailingText'],
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                // value: el['isSelected'],
                                value: disableAll,
                                onChanged: ((p0) async {
                                  setState(() {
                                    // el['isSelected'] = !el['isSelected'];
                                    disableAll = p0;
                                  });
                                  await update();
                                }),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> update() async {
    // debugPrint("Fortune Payload ${general}");
    // debugPrint("Fortune Payload2 ${interactions}");

    Map<String, dynamic> payload = {
      "isPushNotification": disableAll,
      "isEmailNotification": emailNotif,
      "isSilentModeOn": false,
      "emailNotifications": inEmail != null ? inEmail!.toJson() : {},
      "inappNotifications": {
        "jobs": false,
        "coupons": false,
        "newFollower": newFollowers,
        "profileView": profileView,
        "messages": directMessages,
        "likes": likes,
        "comments": comments,
        "posts": posts,
        "services": features,
        "features": features,
        "myActivity": activitiesUpdate
      }

      // "inappNotifications": NotificationsPreferenceInputType(
      //   jobs: false,
      //   coupons: false,
      //   features: features,
      //   likes: likes,
      //   myActivity: disableAllInteraction,
      //   newFollowers: newFollowers,
      //   profileView: profileView,
      //   messages: messages,
      //   comments: comments,
      //   posts: posts,
      //   services: features,
      // )
    };
    // print("Micheal payload $payload");

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
