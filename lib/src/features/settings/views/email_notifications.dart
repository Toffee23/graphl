import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_settings_controller.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/notification_preference_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../widgets/cupertino_switch_card2.dart';

class EmailNotificationsScreen extends ConsumerStatefulWidget {
  static const title = 'Email Notifications';
  static const route = '/email_notifications';
  const EmailNotificationsScreen({super.key});

  @override
  ConsumerState<EmailNotificationsScreen> createState() =>
      _EmailNotificationsScreenState();
}

class _EmailNotificationsScreenState
    extends ConsumerState<EmailNotificationsScreen> {
  bool alertProfileVisit = false;
  bool disableAll = false;
  bool inAppNotif = false;
  bool buildOnce = true;

  @override
  void initState() {
    alertProfileVisit =
        ref.read(appUserProvider).valueOrNull!.alertOnProfileVisit;
    super.initState();
  }

  double _verticalPadding = 1;
  double _containerTopMargin = 2;
  double _containerBottomMargin = 0;
  double _listItemBottomMargin = 2;

  // final _generalNotifications = <Map<String, dynamic>>[
  //   {'title': 'New Followers', 'isSelected': false},
  //   {'title': 'Profile View', 'isSelected': false},
  //   {'title': 'Direct Messages', 'isSelected': false},
  //   {'title': 'Activities update', 'isSelected': false},
  // ];

  // final _interactionsNotifications = <Map<String, dynamic>>[
  //   {'title': 'Likes', 'isSelected': false},
  //   {'title': 'Comments', 'isSelected': false},
  //   {'title': 'New Posts', 'isSelected': false},
  //   {'title': 'Features', 'isSelected': false},
  // ];

  // final _advancedNotifications = <Map<String, dynamic>>[
  //   {'title': 'Turn off all notifications', 'isSelected': false},
  // ];

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
  NotificationsPreferenceInputType? inApps;

  void preloadQuery() {
    disableAll =
        ref.watch(appSettingsProvider).valueOrNull?.isEmailNotification ??
            false;
    inAppNotif =
        ref.watch(appSettingsProvider).valueOrNull?.isPushNotification ?? false;

    inApps = ref.watch(appSettingsProvider).valueOrNull?.inappNotifications;

    debugPrint(
        "Fortune Payload100 ${ref.watch(appSettingsProvider).valueOrNull?.emailNotifications.toJson()}");

    /// general notification
    newFollowers = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
            .newFollowers ??
        false;

    profileView = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
            .profileView ??
        false;

    directMessages = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
            .messages ??
        false;

    activitiesUpdate = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
            .myActivity ??
        false;

    /// interaction notification
    likes =
        ref.watch(appSettingsProvider).valueOrNull?.emailNotifications.likes ??
            false;
    comments = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
            .comments ??
        false;
    posts =
        ref.watch(appSettingsProvider).valueOrNull?.emailNotifications.posts ??
            false;
    features = ref
            .watch(appSettingsProvider)
            .valueOrNull
            ?.emailNotifications
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
        appbarTitle: EmailNotificationsScreen.title,
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
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10), // radius of 10
                  //   ),
                  //   margin: EdgeInsets.only(top: 5, bottom: 15),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: _interactionsNotifications
                  //         .map(
                  //           (el) => Column(
                  //             children: [
                  //               Container(
                  //                 child: VWidgetsCupertinoSwitchWithText2(
                  //                   verticalPadding: _verticalPadding,
                  //                   titleText: el['title'].toString(),
                  //                   trailingText: el['trailingText'],
                  //                   textStyle: TextStyle(
                  //                     fontSize: 16,
                  //                     fontWeight: FontWeight.w600,
                  //                   ),
                  //                   value:
                  //                       disableAll ? false : el['isSelected'],
                  //                   disabled: disableAll ? true : false,
                  //                   onChanged: disableAll
                  //                       ? (pI) {}
                  //                       : ((p0) async {
                  //                           setState(() {
                  //                             el['isSelected'] =
                  //                                 !el['isSelected'];
                  //                           });
                  //                           // debugPrint(
                  //                           //     "Fortune interactive ${_generalNotifications}");
                  //
                  //                           // await update();
                  //                           await update(_generalNotifications,
                  //                               _interactionsNotifications);
                  //
                  //                           preloadQuery();
                  //                           return el['isSelected'];
                  //                         }),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         )
                  //         .toList(),
                  //   ),
                  // ),
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
                      child: Container(
                        child: VWidgetsCupertinoSwitchWithText2(
                          verticalPadding: _verticalPadding,
                          titleText: 'Turn off all notifications',
                          // trailingText: el['trailingText'],
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          value: disableAll,
                          onChanged: (p0) async {
                            setState(() {
                              advancedNotification = !advancedNotification;
                              disableAll = p0;
                            });

                            await update();

                            // preloadQuery();
                          },
                        ),
                      )),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> update() async {
    print("ADE1 newFollowers $newFollowers ");

    Map<String, dynamic> payload = {
      "isPushNotification": inAppNotif,
      "isEmailNotification": disableAll,
      "isSilentModeOn": false,
      "inappNotifications": inApps != null ? inApps!.toJson() : {},
      "emailNotifications": {
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
