import 'dart:async';
import 'dart:convert';

import 'package:either_option/either_option.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/connection/controller/provider/my_connections_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/shimmer/widgets/circle_avatar_two_line_tile.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/utils/costants.dart';
import 'package:vmodel/src/res/icons.dart';

enum SendType { post, service, job }

class SendWidget extends ConsumerStatefulWidget {
  const SendWidget({this.item, this.type = SendType.post});

  final item;
  final SendType type;

  @override
  ConsumerState<SendWidget> createState() => _SendWidgetState();
}

class _SendWidgetState extends ConsumerState<SendWidget> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> mockData = [];
  bool loaded = false;
  List selectedList = [];
  int shimmerLength = 15;
  String dynamicLink = '';
  var uuid = Uuid();

  late final Debounce _debounce;

  String mapToQueryString(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return '';
    final buffer = StringBuffer('?');
    queryParams.forEach((key, value) {
      buffer.write(Uri.encodeQueryComponent(key));
      buffer.write('=');
      buffer.write(Uri.encodeQueryComponent(value));
      buffer.write('&');
    });

    return buffer.toString().substring(0, buffer.length - 1);
  }

  Future createDynamicLink(Map<String, String> queryParams) async {
    // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    var convertedString = mapToQueryString(queryParams);

    final String link = 'https://vmodelapp.com$convertedString';
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://vmodel.page.link',
    //   longDynamicLink: Uri.parse(
    //     'https://vmodel.page.link?imv=0&amv=0&link=https%3A%2F%2Fvmodelapp.com',
    //   ),
    //   link: Uri.parse(DynamicLink),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'app.vmodel.social',
    //     minimumVersion: 0,
    //   ),
    //   iosParameters: const IOSParameters(
    //     bundleId: 'app.vmodel.social',
    //     minimumVersion: '0',
    //   ),
    // );

    // Uri url;

    // if (false) {
    //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    //   url = shortLink.shortUrl;
    // } else {
    //   url = await dynamicLinks.buildLink(parameters);
    // }
    return Uri.parse(link);
  }

  @override
  initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
  }

  void initDynamicLink() async {
    try {
      dynamicLink = (await createDynamicLink(
              {'a': 'true', 'p': 'post', 'i': widget.item.id.toString()}))
          .toString();
      copyToClipboard(dynamicLink);
      Navigator.pop(context);
      SnackBarService().showSnackBar(
          icon: VIcons.copyIcon, message: "Link copied", context: context);
    } catch (e) {
      //print(e);
    }
    setState(() {});
  }

  @override
  dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(searchConnections);
    final messages = ref.watch(getConversationsProvider.future);

    if (!loaded) {
      connections.when(
          data: (Either<CustomException, List<dynamic>> data) {
            return data.fold((p0) => const SizedBox.shrink(), (p0) {
              mockData =
                  List.generate(p0.length, (index) => {"selected": false});
              loaded = true;
            });
          },
          error: (Object error, StackTrace stackTrace) {},
          loading: () {});
    }
    // }
    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          // height: 600,
          constraints: const BoxConstraints(
            minHeight: 200,
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: VConstants.bottomPaddingForBottomSheets,
          ),
          decoration: BoxDecoration(
              // color: Colors.white,
              // color: Theme.of(context).colorScheme.surface,
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Send to",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        // color: VmodelColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(.2)),
                      child: Icon(
                        CupertinoIcons.link,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      initDynamicLink.call();
                    },
                  )
                ],
              ),
              addVerticalSpacing(15),
              if (selectedList.length > 8)
                SearchTextFieldWidget(
                  controller: searchController,
                  onChanged: (String? val) {
                    if (val != null) {
                      _debounce(() => ref
                          .read(myConnectionsSearchProvider.notifier)
                          .state = val);
                    } else {
                      ref.watch(searchConnections);
                    }
                  },
                  hintText: "Search...",
                ),
              addVerticalSpacing(10),
              connections.when(
                  data: (data) {
                    return data.fold((p0) => const SizedBox.shrink(), (p0) {
                      shimmerLength = p0.length;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 185,
                        ),
                        child: GridView.builder(
                          itemCount: p0.length,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent: 100,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: ((context, index) {
                            var connection = p0[index];
                            return SendOption(
                              profileRing: connection['profileRing'],
                              imagePath: connection['profilePictureUrl'],
                              title: '${connection['username']}',
                              subtitle: connection['userType'],
                              selected: mockData[index]["selected"],
                              onTap: () async {
                                mockData[index]["selected"] =
                                    !mockData[index]["selected"];
                                if (mockData[index]["selected"] == true) {
                                  if (selectedList.contains(connection) ==
                                      false) {
                                    selectedList.add(connection);
                                  }
                                } else {
                                  if (selectedList.contains(connection)) {
                                    selectedList.remove(connection);
                                  }
                                }
                                setState(() {});
                              },
                            );
                          }),
                        ),
                      );
                    });
                  },
                  error: (Object error, StackTrace stackTrace) =>
                      SliverToBoxAdapter(child: const SizedBox.shrink()),
                  loading: () {
                    return ListView.separated(
                        itemCount: 3,
                        padding: EdgeInsets.symmetric(vertical: 25),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return addVerticalSpacing(16);
                        },
                        itemBuilder: (context, index) {
                          return CircleAvatarTwoLineTileShimmer();
                        });
                  }),
              addVerticalSpacing(15),
              VWidgetsPrimaryButton(
                buttonTitle: "Send",
                enableButton: selectedList.isNotEmpty ? true : false,
                onPressed: () async {
                  SnackBarService().showSnackBar(
                      message:
                          "Sending ${widget.type.name.capitalizeFirstVExt}..",
                      context: context);
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  int? id = prefs.getInt('id');

                  final token = await getRestToken() as String?;
                  selectedList.forEach((person) async {
                    final messageList = await messages.then((value) => value);
                    final hasChatted = messageList.any((element) =>
                        element.recipient.username == person['username']);
                    var conversationId;
                    if (hasChatted) {
                      final conversationer = messageList.where((element) =>
                          element.recipient.username == person['username']);
                      conversationId = conversationer.first.id;
                    } else {
                      conversationId = id;
                    }
                    String messageUUID = uuid.v4();
                    final wsUrl = Uri.parse(
                        '${VUrls.webSocketBaseUrl}/chat/${conversationId}/');
                    WebSocketChannel channel =
                        await IOWebSocketChannel.connect(wsUrl, headers: {
                      "authorization": "Token ${token.toString().trim()}"
                    });
                    var text = jsonEncode({
                      "message": jsonEncode({
                        if (widget.type == SendType.post)
                          'message_type': 'POST',
                        if (widget.type == SendType.service)
                          'message_type': 'SERVICE',
                        if (widget.type == SendType.job) 'message_type': 'JOB',
                        ...widget.item.toMap(),
                      }),
                      "message_uuid": messageUUID
                    });
                    channel.sink.add(text);
                    // responseDialog(context, "Post sent");
                    SnackBarService().showSnackBar(
                        message: "${widget.type.name.capitalizeFirstVExt} sent",
                        context: context);
                  });
                  await ref.refresh(getConversationsProvider);
                },
              ),
              addVerticalSpacing(20)
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getRestToken() async {
    var vcred = VCredentials.inst;
    return VModelSecureStorage()
        .getSecuredKeyStoreData(VSecureKeys.restTokenKey);
  }
}

class SendOption extends StatelessWidget {
  const SendOption({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    required this.selected,
    required this.subtitle,
    required this.profileRing,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String imagePath;
  final Function() onTap;
  final bool selected;
  final String? profileRing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ProfilePicture(
                url: imagePath,
                headshotThumbnail: imagePath,
                borderColor: selected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderWidth: 2,
                showBorder: true,
                imageBorderPadding: EdgeInsets.zero,
                size: 70,
                profileRing: profileRing,
              ),
              if (selected)
                CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black45,
                )
            ],
          ),
          addVerticalSpacing(05),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                // color: VmodelColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
          // addHorizontalSpacing(8),
          // Flexible(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         title,
          //         style: Theme.of(context)
          //             .textTheme
          //             .displayMedium
          //             ?.copyWith(
          //                 // color: VmodelColors.primaryColor,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w600),
          //         maxLines: 1,
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //       addVerticalSpacing(4),
          //       Text(
          //         subtitle,
          //         style: Theme.of(context)
          //             .textTheme
          //             .displayMedium
          //             ?.copyWith(
          //                 color: Theme.of(context)
          //                     .colorScheme
          //                     .onSurface
          //                     .withOpacity(0.35),
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w500),
          //         maxLines: 1,
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class SendCouponWidget extends ConsumerStatefulWidget {
  final String couponId;
  final String couponTitle;
  final String couponCode;

  const SendCouponWidget(
      {required this.couponId,
      required this.couponTitle,
      required this.couponCode});

  @override
  ConsumerState<SendCouponWidget> createState() => _SendCouponWidgetState();
}

class _SendCouponWidgetState extends ConsumerState<SendCouponWidget> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> mockData = [];
  bool loaded = false;
  List selectedList = [];
  int shimmerLength = 15;
  String dynamicLink = '';
  var uuid = Uuid();

  late final Debounce _debounce;

  String mapToQueryString(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return '';
    final buffer = StringBuffer('?');
    queryParams.forEach((key, value) {
      buffer.write(Uri.encodeQueryComponent(key));
      buffer.write('=');
      buffer.write(Uri.encodeQueryComponent(value));
      buffer.write('&');
    });

    return buffer.toString().substring(0, buffer.length - 1);
  }

  Future createDynamicLink(Map<String, String> queryParams) async {
    // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    var convertedString = mapToQueryString(queryParams);

    final String link = 'https://vmodelapp.com$convertedString';
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://vmodel.page.link',
    //   longDynamicLink: Uri.parse(
    //     'https://vmodel.page.link?imv=0&amv=0&link=https%3A%2F%2Fvmodelapp.com',
    //   ),
    //   link: Uri.parse(DynamicLink),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'app.vmodel.social',
    //     minimumVersion: 0,
    //   ),
    //   iosParameters: const IOSParameters(
    //     bundleId: 'app.vmodel.social',
    //     minimumVersion: '0',
    //   ),
    // );

    // Uri url;

    // if (false) {
    //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    //   url = shortLink.shortUrl;
    // } else {
    //   url = await dynamicLinks.buildLink(parameters);
    // }
    return Uri.parse(link);
  }

  @override
  initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
  }

  void initDynamicLink() async {
    try {
      dynamicLink = (await createDynamicLink(
              {'a': 'true', 'p': 'post', 'i': widget.couponId.toString()}))
          .toString();
      copyToClipboard(dynamicLink);
      Navigator.pop(context);
      SnackBarService().showSnackBar(
          icon: VIcons.copyIcon, message: "Link copied", context: context);
    } catch (e) {
      //print(e);
    }
    setState(() {});
  }

  @override
  dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(searchConnections);
    final messages = ref.watch(getConversationsProvider.future);

    if (!loaded) {
      connections.when(
          data: (Either<CustomException, List<dynamic>> data) {
            return data.fold((p0) => const SizedBox.shrink(), (p0) {
              mockData =
                  List.generate(p0.length, (index) => {"selected": false});
              loaded = true;
            });
          },
          error: (Object error, StackTrace stackTrace) {},
          loading: () {});
    }
    // }
    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          // height: 600,
          constraints: const BoxConstraints(
            minHeight: 200,
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: VConstants.bottomPaddingForBottomSheets,
          ),
          decoration: BoxDecoration(
              // color: Colors.white,
              // color: Theme.of(context).colorScheme.surface,
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: VmodelColors.primaryColor.withOpacity(0.15),
                  ),
                ),
              ),
              addVerticalSpacing(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Send to",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        // color: VmodelColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(.2)),
                      child: Icon(
                        CupertinoIcons.link,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      initDynamicLink.call();
                    },
                  )
                ],
              ),
              addVerticalSpacing(15),
              if (selectedList.length > 8)
                SearchTextFieldWidget(
                  controller: searchController,
                  onChanged: (String? val) {
                    if (val != null) {
                      _debounce(() => ref
                          .read(myConnectionsSearchProvider.notifier)
                          .state = val);
                    } else {
                      ref.watch(searchConnections);
                    }
                  },
                  hintText: "Search...",
                ),
              // TextFormField(
              //   controller: searchController,
              //   onChanged: (String? val) {
              //     if (val != null) {
              //       _debounce(() => ref
              //           .read(myConnectionsSearchProvider.notifier)
              //           .state = val);
              //     } else {
              //       ref.watch(searchConnections);
              //     }
              //   },
              //   decoration: InputDecoration(
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //           color: Theme.of(context).primaryColor, width: 1.5),
              //     ),
              //     border: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //           color: Theme.of(context).primaryColor, width: 1.5),
              //     ),
              //     enabledBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //           color: Theme.of(context).primaryColor, width: 1.5),
              //     ),
              //     hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
              //         color: Theme.of(context).primaryColor.withOpacity(0.5),
              //         fontSize: 11.sp,
              //         overflow: TextOverflow.clip),
              //     hintText: "Search...",
              //     constraints: const BoxConstraints(maxHeight: 50),
              //     contentPadding: VWidgetsPagePadding.only(2, 2, 17),
              //   ),
              // ),

              addVerticalSpacing(10),
              CustomScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  slivers: [
                    connections.when(
                        data: (Either<CustomException, List<dynamic>> data) {
                          return data.fold((p0) => const SizedBox.shrink(),
                              (p0) {
                            shimmerLength = p0.length;
                            return SliverGrid.builder(
                              itemCount: p0.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisExtent: 100,
                              ),
                              itemBuilder: ((context, index) {
                                var connection = p0[index];
                                return SendOption(
                                  profileRing: connection['profileRing'],
                                  imagePath: connection['profilePictureUrl'],
                                  title: '${connection['username']}',
                                  subtitle: connection['userType'],
                                  selected: mockData[index]["selected"],
                                  onTap: () async {
                                    mockData[index]["selected"] =
                                        !mockData[index]["selected"];
                                    if (mockData[index]["selected"] == true) {
                                      if (selectedList.contains(connection) ==
                                          false) {
                                        selectedList.add(connection);
                                      }
                                    } else {
                                      if (selectedList.contains(connection)) {
                                        selectedList.remove(connection);
                                      }
                                    }
                                    setState(() {});
                                  },
                                );
                              }),
                            );
                            // return ListView.builder(
                            //   shrinkWrap: true,
                            //   itemCount: p0.length,
                            //   itemBuilder: (context, index) {
                            //     var connection = p0[index];
                            //     return SendOption(
                            //       imagePath: connection['profilePictureUrl'],
                            //       title: '${connection['username']}',
                            //       subtitle: connection['userType'],
                            //       selected: mockData[index]["selected"],
                            //       onTap: () async {
                            //         mockData[index]["selected"] =
                            //             !mockData[index]["selected"];
                            //         if (mockData[index]["selected"] == true) {
                            //           if (selectedList.contains(connection) ==
                            //               false) {
                            //             selectedList.add(connection);
                            //           }
                            //         } else {
                            //           if (selectedList.contains(connection)) {
                            //             selectedList.remove(connection);
                            //           }
                            //         }
                            //         setState(() {});
                            //       },
                            //     );
                            //   },
                            // );
                          });
                        },
                        error: (Object error, StackTrace stackTrace) =>
                            SliverToBoxAdapter(child: const SizedBox.shrink()),
                        loading: () {
                          return SliverToBoxAdapter(
                            child: ListView.separated(
                                itemCount: 3,
                                padding: EdgeInsets.symmetric(vertical: 25),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return addVerticalSpacing(16);
                                },
                                itemBuilder: (context, index) {
                                  return CircleAvatarTwoLineTileShimmer();
                                }),
                          );
                        })
                  ]),
              addVerticalSpacing(15),
              VWidgetsPrimaryButton(
                buttonTitle: "Send",
                enableButton: selectedList.isNotEmpty ? true : false,
                onPressed: () async {
                  SnackBarService().showSnackBar(
                      message: "Sending coupon..", context: context);
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  // int? id = prefs.getInt('id');
                  //
                  // final token = await getRestToken() as String?;
                  // selectedList.forEach((person) async {
                  //   final messageList = await messages.then((value) => value);
                  //   final hasChatted = messageList.any((element) => element['recipient']['username'] == person['username']);
                  //   var conversationId;
                  //   if (hasChatted) {
                  //     final conversationer = messageList.where((element) => element['recipient']['username'] == person['username']);
                  //     conversationId = conversationer.first['id'];
                  //   } else {
                  //     conversationId = id;
                  //   }
                  //   String messageUUID = uuid.v4();
                  //   final wsUrl = Uri.parse('${VUrls.webSocketBaseUrl}/chat/${conversationId}/');
                  //   WebSocketChannel channel = await IOWebSocketChannel.connect(wsUrl, headers: {"authorization": "Token ${token.toString().trim()}"});
                  //   var text = jsonEncode({
                  //     "message": jsonEncode({'message_type': 'POST', ...widget.item.toMap()}),
                  //     "message_uuid": messageUUID
                  //   });
                  //   channel.sink.add(text);
                  //   // responseDialog(context, "Post sent");
                  //   SnackBarService().showSnackBar(message: "Post sent", context: context);
                  // });
                  await ref.refresh(getConversationsProvider);
                },
              ),
              addVerticalSpacing(20)
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getRestToken() async {
    var vcred = VCredentials.inst;
    return VModelSecureStorage()
        .getSecuredKeyStoreData(VSecureKeys.restTokenKey);
  }
}
