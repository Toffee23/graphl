import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:dart_emoji/dart_emoji.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/widgets/services_card_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/dashboard/profile/controller/profile_controller.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';
import 'package:vmodel/src/features/messages/widgets/message_menu_options.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/create_offer_page.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/response_widgets/toast_dialogue.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/features/messages/views/create_offer.dart';
import 'package:vmodel/src/features/messages/widgets/message_chat_screen_bottom_navigationbar.dart';
import 'package:vmodel/src/features/messages/widgets/receiver_text_message_card.dart';
import 'package:vmodel/src/features/messages/widgets/sender_text_message_card.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar_title_text.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/app_user.dart';
import '../../../core/network/urls.dart';
import '../../../core/network/websocket.dart';
import '../../../core/utils/costants.dart';
import '../../../core/utils/debounce.dart';

class MessagesChatScreen extends ConsumerStatefulWidget {
  final int id;
  final String? profilePicture;
  final String? profileThumbnailUrl;
  final String username;
  final String? label;
  final bool? deep;
  final List<MessageModel> messages;

  const MessagesChatScreen({
    super.key,
    required this.id,
    this.deep,
    this.profilePicture,
    this.profileThumbnailUrl,
    required this.username,
    this.label,
    required this.messages,
  });

  @override
  ConsumerState<MessagesChatScreen> createState() => _MessagesChatScreenState();
}

class _MessagesChatScreenState extends ConsumerState<MessagesChatScreen>
    with TickerProviderStateMixin {
  TextEditingController message = TextEditingController();
  bool isTyping = false;
  bool otherUserisTyping = false;
  bool showSend = false;
  bool showCopy = false;
  String textToCopy = "";
  String username = '';
  List textValue = [];

  List text = [];
  List textSelect = [];
  ScrollController _scrollController = ScrollController();
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _typingController;
  late Animation<double> _scaleAnimation;
  WSMessage wsMessage = WSMessage();
  late WSIsTyping wsIsTyping;
  late final Debounce _debounce;
  var uuid = Uuid();
  StreamSubscription? messagesEventSubscription;

  late List<MessageModel> messages = widget.messages;

  final animatedListKey = GlobalKey<AnimatedListState>();
  // final _seenMessageIds = Set<int>();

  void userIsTyping(bool typing, chatId) {
    var text = jsonEncode(
        <String, dynamic>{"is_typing": typing, "conversation_id": chatId});
    wsIsTyping.add(text);
  }

  void disableUserTyping() {
    if (mounted) {
      setState(() {
        otherUserisTyping = false;
      });
    }
  }

  // static final VModelSecureStorage stroage = VModelSecureStorage();

  // Future<dynamic> initFirebaseToken() async {
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   await FirebaseApi().initNotification(context);
  // }

  void _hasArchived(bool val) async {
    if (val) {
      await ref.read(archiveConversation(widget.id));
    } else {
      await ref.read(unarchiveConversation(widget.id));
    }

    ref.invalidate(getArchivedConversations);
    ref.invalidate(getConversationsProvider);
    if (val) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }

    if (val) {
      // responseDialog(context, "Archived");
      SnackBarService().showSnackBar(message: "Archived", context: context);
    } else {
      // responseDialog(context, "Unarchived");
      SnackBarService().showSnackBar(message: "Unarchived", context: context);
    }
  }

  void hasArchived(bool val) {
    //print('objectval $val');
    _hasArchived(val);
    Navigator.pop(context);
  }

  Future<void> connectWebsocket() async {
    final connect =
        await wsMessage.connect('${VUrls.webSocketBaseUrl}/chat/${widget.id}/');
    if (connect) {
      messagesEventSubscription = wsMessage.channel?.stream.listen((event) {
        ref.read(messagesNotifierProvider.notifier).markMessageAsRead(messages
            .where((e) => e.read == false)
            .map((e) => e.id.toString())
            .toList());
        try {
          logger.i(event);
          messages.insert(0, MessageModel.fromJson(jsonDecode(event)));
          animatedListKey.currentState
              ?.insertItem(0, duration: Duration(milliseconds: 300));
        } catch (e, s) {
          logger.e(e.toString(), stackTrace: s);
        }
      }, onError: (e) => logger.e(e.toString()));
    }
  }

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    connectWebsocket();
    wsIsTyping = WSIsTyping()
      ..connect('${VUrls.webSocketBaseUrl}/istyping/${widget.id}/');

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
      reverseDuration: Duration(seconds: 1),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInSine);
    _controller.forward();

    ref.read(messagesNotifierProvider.notifier).markMessageAsRead(messages
        .where((e) => e.read == false)
        .map((e) => e.id.toString())
        .toList());

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          if (ref
              .read(conversationProvider(int.parse('${widget.id}')).notifier)
              .canLoadMore()) {
            ref
                .read(conversationProvider(int.parse('${widget.id}')).notifier)
                .fetchMoreData(int.parse('${widget.id}'));
          }
        });
      }
    });

    _typingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_typingController);
    _typingController.repeat();
  }

  String selectedChip = "Model";

  @override
  void dispose() {
    _controller.dispose();
    _typingController.dispose();
    // wsMessage.channel?.sink.close();
    messagesEventSubscription?.cancel();
    wsMessage.close();
    wsIsTyping.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations =
        ref.watch(conversationProvider(int.parse('${widget.id}')));
    final failedMessages = ref.watch(failedMessagesProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final userState = ref.watch(profileProviderNoFlag(widget.username));
    final user = userState.valueOrNull;
    var services = ref.watch(servicePackagesProvider(username)).valueOrNull ??
        <ServicePackageModel>[];

    if (!(wsMessage.isConnected)) {
      wsMessage.connect('${VUrls.webSocketBaseUrl}/chat/${widget.id}/');
    }
    if (!(wsIsTyping.isConnected)) {
      wsIsTyping.connect('${VUrls.webSocketBaseUrl}/istyping/${widget.id}/');
    }

    return PopScope(
      canPop: !showCopy,
      onPopInvoked: (value) async {
        if (showCopy) {
          setState(() => showCopy = false);
          // return false;
        } else {
          // return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: ref.watch(messageFileUploadProgress) == 0.0
              ? null
              : PreferredSize(
                  preferredSize: Size(MediaQuery.sizeOf(context).width, 2),
                  child: LinearProgressIndicator(
                    value: ref.watch(messageFileUploadProgress),
                  ),
                ),
          leading: VWidgetsBackButton(
              onTap: () {
                VMHapticsFeedback.lightImpact();
                if (showCopy) {
                  setState(() => showCopy = false);
                  return;
                } else {
                  Navigator.pop(context);
                  ref.invalidate(getConversationsProvider);
                  text.clear();
                }
              },
              deep: widget.deep),
          centerTitle: false,
          title: GestureDetector(
            onTap: () {
              /*navigateToRoute(
                  context, OtherUserProfile(username: widget.username));*/

              String? _userName = widget.username;
              context.push(
                  '${Routes.otherUserProfile.split("/:").first}/$_userName');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfilePicture(
                  url: user?.profilePictureUrl ?? widget.profilePicture,
                  headshotThumbnail:
                      user?.thumbnailUrl ?? widget.profileThumbnailUrl,
                  size: 44,
                  displayName: user?.username,
                  profileRing: user?.profileRing,
                ),
                addHorizontalSpacing(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VWidgetsAppBarTitleText(titleText: widget.username),
                    Text(
                      widget.label ?? "",
                      style: VModelTypography1.normalTextStyle.copyWith(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (showCopy)
              IconButton(
                  onPressed: () {
                    copyText();
                  },
                  icon: Icon(
                    Icons.copy,
                    color: Theme.of(context).iconTheme.color,
                  )),
            if (widget.deep == null || widget.deep == false)
              IconButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        useRootNavigator: true,
                        constraints: BoxConstraints(maxHeight: 50.h),
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                              // color: Theme.of(context).scaffoldBackgroundColor,
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                              ),
                            ),
                            child: MessageMenuOptionsWidget(
                                conversationId: widget.id,
                                username: widget.username,
                                connectionStatus: user?.connectionStatus ?? '',
                                hasArchived: (bool val) {
                                  hasArchived(val);
                                }),
                          );
                        });
                  },
                  icon: const RenderSvg(svgPath: VIcons.exclamation)),
            if (widget.deep == null || widget.deep == false)
              SizedBox(
                width: 5,
              )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(conversationProvider(int.parse('${widget.id}')).future);
          },
          child: Column(
            children: [
              Expanded(
                child: messages.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          dismissKeyboard();
                        },
                        child: Padding(
                          padding:
                              const VWidgetsPagePadding.horizontalSymmetric(10),
                          child: AnimatedList(
                            key: animatedListKey,
                            reverse: true,
                            initialItemCount: messages.length,
                            controller: _scrollController,
                            itemBuilder: (context, index, animation) {
                              return SlideTransition(
                                  position: animation.drive(Tween<Offset>(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero,
                                  )),
                                  child: chatWidget2(
                                      messages[index], index, currentUser));
                            },
                          ),
                        ))
                    : conversations.when(
                        data: (conversationMessage) {
                          ref
                              .read(messagesNotifierProvider.notifier)
                              .markMessageAsRead(conversationMessage
                                  .where((e) => e.read = false)
                                  .map((e) => e.id.toString())
                                  .toList());
                          return ListView.builder(
                            reverse: true,
                            itemCount: conversationMessage.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return chatWidget2(conversationMessage[index],
                                  index, currentUser);
                            },
                          );
                          // text.clear();
                          // text.addAll(messsages.reversed);

                          // for (int i = 0; i < messsages.length; i++) {
                          //   textSelect.add(false);
                          // }

                          // return StreamBuilder(
                          //   stream: wsMessage.channel?.stream,
                          //   builder: (context, snapshot) {
                          //     if (snapshot.hasData) {
                          //       var data = jsonDecode(snapshot.data);

                          //       int? messageId = int.tryParse('${data['id']}'); // Extract message ID from JSON
                          //       if (!(_seenMessageIds.contains(messageId))) {
                          //         textValue.add(data);
                          //         _seenMessageIds.add(messageId!); // Add message ID to seen set
                          //       }
                          //       text.addAll(textValue); // Add message if not seen before

                          //       // textValue.addIf(text.where((element) => element['id'] == data['id'] ).isEmpty,data);
                          //       //
                          //       // text.addAllIf(text.where((element) => element['id'] == textValue.a.last['id'] ).isEmpty,textValue);

                          //       return GestureDetector(
                          //           onTap: () {
                          //             dismissKeyboard();
                          //           },
                          //           child: Padding(
                          //             padding: const VWidgetsPagePadding.horizontalSymmetric(10),
                          //             child: AnimatedList(
                          //               reverse: true,
                          //               key: _key,
                          //               initialItemCount: text.length,
                          //               controller: _scrollController,
                          //               itemBuilder: (BuildContext context, int index, animation) {
                          //                 return SlideTransition(
                          //                   position: Tween<Offset>(
                          //                     begin: Offset(-1.0, -1.0), // Slide in from left
                          //                     end: Offset.zero,
                          //                   ).animate(animation),
                          //                   child: chatWidget2(text.reversed.toList(), index, currentUser),
                          //                 );
                          //               },
                          //             ),
                          //           ));
                          //     } else if (snapshot.hasError) {
                          //       wsMessage = WSMessage()..connect('${VUrls.webSocketBaseUrl}/chat/${widget.id}/');
                          //       return GestureDetector(
                          //           onTap: () {
                          //             dismissKeyboard();
                          //           },
                          //           child: Padding(
                          //             padding: const VWidgetsPagePadding.horizontalSymmetric(10),
                          //             child: ListView.builder(
                          //               reverse: true,
                          //               itemCount: text.length,
                          //               controller: _scrollController,
                          //               itemBuilder: (BuildContext context, int index) {
                          //                 return chatWidget2(text.reversed.toList(), index, currentUser);
                          //               },
                          //             ),
                          //           ));
                          //     }

                          //   },
                          // );
                        },
                        error: (Object error, StackTrace stackTrace) =>
                            const SizedBox.shrink(),
                        loading: () => Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
              ),
              addVerticalSpacing(12),
              // if (failedMessages[widget.id] != null)
              //   ListView.builder(
              //     shrinkWrap: true, // Prevent list from expanding
              //     itemCount: failedMessages[widget.id]!.length,
              //     itemBuilder: (context, index) => GestureDetector(
              //       onTap: () {
              //         message.text = failedMessages[widget.id]![index];
              //         sendMessage();
              //       },
              //       child: VWidgetsReceiverTextCard(
              //         receiverMessage: failedMessages[widget.id]![index],
              //         msg: failedMessages[widget.id]![index],
              //         fontSize: _emojiOnlyTextFontSize(failedMessages[widget.id]![index]),
              //       ),
              //     ),
              //   ),
              StreamBuilder(
                  stream: wsIsTyping.channel?.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SizedBox.shrink();
                    }
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    var data = jsonDecode(snapshot.data);
                    if (data['is_typing'] == true) {
                      otherUserisTyping = true;
                      Timer(Duration(seconds: 4), () {
                        return disableUserTyping();
                      });
                    } else {
                      otherUserisTyping = false;
                    }
                    var userId = data['user'];
                    return userTyping(userId, currentUser);
                  }),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (zipFile != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'ZIP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => zipFile = null);
                                      },
                                      child: CircleAvatar(
                                        radius: 8,
                                        backgroundColor:
                                            Theme.of(context).canvasColor,
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              addVerticalSpacing(2),
                              SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 2.5,
                                  child: Text(
                                    zipFile!.name,
                                    overflow: TextOverflow.ellipsis,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      // height: 65,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding:
                            const VWidgetsPagePadding.horizontalSymmetric(10),
                        child: SizedBox(
                          height: 80,
                          child: VWidgetsTextFieldWithMultipleIcons(
                            textCapitalization: TextCapitalization.sentences,
                            isTyping: isTyping,
                            controller: message,
                            suffixIcon: Padding(
                              padding:
                                  EdgeInsets.only(right: 0, top: 8, bottom: 8),
                              child: RenderSvg(
                                svgPath: VIcons.smilyImojie,
                                svgHeight: 10,
                                svgWidth: 0,
                              ),
                            ),
                            showSend: showSend || zipFile != null,
                            onTapPlus: () => showOptionModalSheet(services),
                            onSend: () async {
                              await sendMessage();
                              message.clear();
                              isTyping = false;
                              userIsTyping(false, widget.id);
                              showSend = false;
                              setState(() {});
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                isTyping = true;
                                showSend = true;
                                userIsTyping(true, widget.id);
                                Timer(Duration(seconds: 5), () {
                                  return userIsTyping(false, widget.id);
                                });
                                setState(() {});
                              } else {
                                showSend = false;
                                isTyping = false;
                                userIsTyping(false, widget.id);
                                setState(() {});
                              }
                            },
                            hintText: 'Message...',
                            onPressedSuffixFirst: () {},
                            onPressedSuffixSecond: () {},
                            onPressedSuffixThird: () {
                              // navigateToRoute(context, const BookingSettings());
                              // showCupertinoModalPopup(
                              //   context: context,
                              //   builder: (BuildContext context) => Container(
                              //     margin: const EdgeInsets.only(
                              //       bottom: 10,
                              //     ),
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.end,
                              //       children: [
                              //         ...createBookingOptions(context).map((e) {
                              //           return Container(
                              //             decoration: BoxDecoration(
                              //               color: VmodelColors.white,
                              //               borderRadius: const BorderRadius.all(
                              //                 Radius.circular(10),
                              //               ),
                              //             ),
                              //             width: double.infinity,
                              //             margin: const EdgeInsets.only(
                              //                 left: 12, right: 12, bottom: 4),
                              //             height: 50,
                              //             child: MaterialButton(
                              //               shape: const RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.all(
                              //                   Radius.circular(10),
                              //                 ),
                              //               ),
                              //               onPressed: () {
                              //                 showModalBottomSheet(
                              //                   isScrollControlled: true,
                              //                   isDismissible: false,
                              //                   backgroundColor: Colors.white,
                              //                   context: context,
                              //                   builder: (context) =>
                              //                       DraggableScrollableSheet(
                              //                     expand: false,
                              //                     key: UniqueKey(),
                              //                     initialChildSize: 0.9,
                              //                     maxChildSize: 0.9,
                              //                     minChildSize: .5,
                              //                     builder: (context, controller) =>
                              //                         const CreateOffer(),
                              //                   ),
                              //                 );
                              //               },
                              //               child: GestureDetector(
                              //                 onTap: () {
                              //                   popSheet(context);
                              //                 },
                              //                 child: Column(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.center,
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.center,
                              //                   children: [
                              //                     Text(
                              //                       e.label.toString(),
                              //                       style: e.label == 'Cancel'
                              //                           ? Theme.of(context)
                              //                               .textTheme
                              //                               .displayMedium!
                              //                               .copyWith(
                              //                                   color: Colors.blue)
                              //                           : Theme.of(context)
                              //                               .textTheme
                              //                               .displayMedium,
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //           );
                              //         }),
                              //       ],
                              //     ),
                              //   ),
                              // );
                            },
                          ),
                        ),
                      ),
                    ),
                    addVerticalSpacing(3),
                  ],
                ),
              ),
              addVerticalSpacing(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatWidget2(MessageModel messages, int index, VAppUser? currentUser) {
    final String senderText = messages.text;
    final String receiverText = messages.text;
    if (messages.senderName == currentUser?.username) {
      return GestureDetector(
        onLongPress: () {
          onLongtap(receiverText, index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: hilight(index)
                ? Theme.of(context).colorScheme.primary.withOpacity(.1)
                : Colors.transparent,
          ),
          child: VWidgetsReceiverTextCard(
            receiverMessage: receiverText,
            msg: messages,
            fontSize: _emojiOnlyTextFontSize(receiverText),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: () {
        onLongtap(senderText, index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: hilight(index)
              ? Theme.of(context).colorScheme.primary.withOpacity(.1)
              : Colors.transparent,
        ),
        child: Container(
          color: hilight(index)
              ? Theme.of(context).colorScheme.primary.withOpacity(.1)
              : Colors.transparent,
          child: VWidgetsSenderTextCard(
            onSenderImageTap: () {
              String? _userName = widget.username;
              context.push(
                  '${Routes.otherUserProfile.split("/:").first}/$_userName');
            },
            senderMessage: senderText,
            senderImage: messages.receiverProfile,
            checkStatus: false,
            msg: messages,
            fontSize: _emojiOnlyTextFontSize(senderText),
          ),
        ),
      ),
    );
  }

  Widget userTyping(int userId, VAppUser? currentUser) {
    if (otherUserisTyping == true && currentUser?.id != userId) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Icon(
              Icons.fiber_manual_record,
              size: 12.0,
              color: Colors.grey,
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.fiber_manual_record,
                size: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation.drive(CurveTween(curve: Curves.easeInOut)),
            child: Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.fiber_manual_record,
                size: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    } else if (otherUserisTyping == false) {
      return SizedBox.shrink();
    }
    ;
    return SizedBox.shrink();
  }

  static const List<String> profanityList = [
    'damn',
    'badword',
    'fuck',
    'asshole',
    'bitch',
    'cocksucker',
    // ... add more profanity words here
  ];
  static const List<String> payments = [
    'electricity bill',
    'payee',
    'phone bill',
    'shopping',
    'payment',
    'reimbursement',
    'compensation',
    'debit',
    'currency',
    'visa mastercard',
    'lump sum'
  ];
  bool paymentFilter(String inputText, List<String> payments) {
    List<String> inputWords = inputText.toLowerCase().split(' ');

    // Iterate over each payment string
    for (String payment in payments) {
      List<String> paymentWords = payment.toLowerCase().split(' ');

      // Check if any of the words in the payment string match any of the words in the input text
      bool matchFound = paymentWords.any((paymentWord) {
        return inputWords.contains(paymentWord);
      });

      // If a match is found, return true
      if (matchFound) {
        return true;
      }
    }

    // If no match is found after checking all payment strings, return false
    return false;
  }

  bool hasProfanity(String inputText, List<String> profanities) {
    List<String> inputWords = inputText.toLowerCase().split(' ');

    // Iterate over each payment string
    for (String payment in profanities) {
      List<String> profanityWords = payment.toLowerCase().split(' ');

      // Check if any of the words in the payment string match any of the words in the input text
      bool matchFound = profanityWords.any((profanityWord) {
        return inputWords.contains(profanityWord);
      });

      // If a match is found, return true
      if (matchFound) {
        return true;
      }
    }

    // If no match is found after checking all payment strings, return false
    return false;
  }

  String profanityText = "######Warning: Swear word: ";
  String paymentText = "######Payment ";

  Future<void> sendMessage() async {
    String messageUUID = uuid.v4();

    wsMessage.add(jsonEncode({
      'message': message.text,
      'message_uuid': messageUUID,
    }));

    // if (message.text.isNotEmpty || zipFile != null) {
    //   if (zipFile != null) {
    //     final file = zipFile;
    //     setState(() {
    //       showSend = false;
    //       zipFile = null;
    //     });
    //     final uploadedFile = await ref.read(messagesNotifierProvider.notifier).uploadFile(File(file!.path));
    //     if (uploadedFile != null) {
    //       log(uploadedFile['data']['urls'][0]);
    //       var text = jsonEncode(
    //         <String, String>{
    //           "message": message.text.trim().replaceAll('#', '%23').replaceAll('message_type', '%%%333'),
    //           "message_uuid": messageUUID,
    //           "attachment": uploadedFile['data']['urls'][0],
    //           "attachment_type": "ZIP"
    //         },
    //       );
    //       if (hasProfanity(message.text, profanityList)) {
    //         text = jsonEncode(
    //           <String, String>{"message": profanityText + message.text.trim(), "message_uuid": messageUUID, "attachment": uploadedFile['data']['urls'][0], "attachment_type": "ZIP"},
    //         );
    //       } else if (paymentFilter(message.text, payments)) {
    //         // Show toast
    //         text = jsonEncode(
    //           <String, String>{"message": paymentText + message.text.trim(), "message_uuid": messageUUID, "attachment": uploadedFile['data']['urls'][0], "attachment_type": "ZIP"},
    //         );
    //       }
    //       final sent = wsMessage.add(text);
    //       if (!sent) {
    //         ref.read(failedMessagesProvider)[widget.id]?.add(text);
    //       }
    //       setState(() => zipFile = null);
    //       // return true;
    //     } else {
    //       VWidgetShowResponse.showToast(ResponseEnum.failed, message: "An error occured uploading files");
    //       // return false;
    //     }
    //   } else {
    //     var text = jsonEncode(
    //       <String, String>{
    //         "message": message.text.trim().replaceAll('#', '%23').replaceAll('message_type', '%%%333'),
    //         "message_uuid": messageUUID,
    //       },
    //     );
    //     if (hasProfanity(message.text, profanityList)) {
    //       text = jsonEncode(
    //         <String, String>{
    //           "message": profanityText + message.text.trim(),
    //           "message_uuid": messageUUID,
    //         },
    //       );
    //     } else if (paymentFilter(message.text, payments)) {
    //       // Show toast
    //       text = jsonEncode(
    //         <String, String>{
    //           "message": paymentText + message.text.trim(),
    //           "message_uuid": messageUUID,
    //         },
    //       );
    //     }
    //     logger.d(text);
    //     wsMessage.channel!.sink.add(text);
    //     // if (!sent) {
    //     //   ref.read(failedMessagesProvider)[widget.id]?.add(text);
    //     // }
    //     // else {
    //     // ref.invalidate(getConversationsProvider);
    //     // }
    //     // await wsMessage.add(text).then((value) {
    //     //   if (!value) {
    //     //     ref.read(failedMessagesProvider)[widget.id]?.add(text);
    //     //   } else {
    //     //     try {

    //     //       ref.read(conversationProvider(widget.id));
    //     //     } catch (e) {}
    //     //   }
    //     // });
    //   }
    // }
  }

  void sendService(ServicePackageModel item) async {
    String messageUUID = uuid.v4();
    try {
      var text = jsonEncode({
        "message": jsonEncode({'message_type': 'SERVICE', ...item.toMap()}),
        "message_uuid": messageUUID
      });
      final sent = wsMessage.add(text);

      if (!sent) {
        //not connected
      } else {
        try {
          ref.invalidate(getConversationsProvider);
          ref.read(conversationProvider(widget.id));
        } catch (e) {}
      }
    } catch (e) {}
    setState(() {});
  }

  double _emojiOnlyTextFontSize(String? text) {
    if (!EmojiUtil.hasOnlyEmojis(text ?? '')) {
      return VConstants.normalChatMessageSize;
    }
    //Todo emojis are typically composed of 2 characters. Thus one emoji will
    // have a length of 2.
    switch (text!.length) {
      case 2: //one emoji only
        return VConstants.emojiOnlyMessageHugeSize;
      case 4: //two emojis only
        return VConstants.emojiOnlyMessageBigSize;
      case 6: //three emojis only
        return VConstants.emojiOnlyMessageMediumSize;
      default:
        return VConstants.normalChatMessageSize;
    }
  }

  void onLongtap(String senderText, int index) {
    textToCopy = senderText;
    textSelect[index] = true;
    showCopy = true;
    setState(() {});
  }

  bool hilight(int index) {
    bool? val;

    for (int i = 0; i < textSelect.length; i++) {
      if (i == index) {
        val = textSelect[i];
      }
    }
    return val ?? false;
  }

  void copyText() {
    for (int i = 0; i < textSelect.length; i++) {
      textSelect[i] = false;
    }
    copyTextToClipboard(textToCopy);
    toastDialoge(
        text: "Message copied",
        toastLength: Duration(milliseconds: 800),
        context: context);

    setState(() => showCopy = false);
  }

  XFile? zipFile;
  showOptionModalSheet(value) {
    showModalBottomSheet(
      // isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      useRootNavigator: true,

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      context: context,
      builder: (context) {
        return Container(
          height: 175,
          padding: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            // color: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addVerticalSpacing(10),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  Navigator.of(context)..pop();
                  showCreateOfferModalSheet();
                },
                message: "Create an offer",
              ),
              const Divider(thickness: 0.5, height: 10),
              addVerticalSpacing(10),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  Navigator.of(context).pop();

                  return showModalBottomSheet(
                      isScrollControlled: true,
                      useRootNavigator: true,
                      constraints: BoxConstraints(maxHeight: 50.h),
                      backgroundColor: Colors.white,
                      enableDrag: false,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10))),
                      context: context,
                      builder: (context) {
                        if (value.isEmpty) {
                          return SingleChildScrollView(
                            padding:
                                const VWidgetsPagePadding.horizontalSymmetric(
                                    18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                addVerticalSpacing(20),
                                SizedBox(
                                  height:
                                      25.h, // Expand to fill available space
                                  child: Center(
                                    child: Text(
                                      'No services has been offered yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: // VmodelColors.primaryColor.withOpacity(0.5),
                                                Theme.of(context)
                                                    .textTheme
                                                    .displayMedium
                                                    ?.color
                                                    ?.withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        return Container(
                            height: MediaQuery.of(context).size.height * .7,
                            padding: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              // color: Theme.of(context).scaffoldBackgroundColor,
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .backgroundColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              physics: AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(minHeight: 60.h),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemCount: value.length,
                                      separatorBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 2),
                                          child: SizedBox(),
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        var item = value[index];
                                        // final displayPrice = (item['price'] as double);

                                        return VWidgetsServicesCardWidget(
                                          serviceUser: item.user,
                                          showLike: false,
                                          userLiked: item.userLiked,
                                          onLike: () {},
                                          delivery: item.delivery,
                                          // statusColor: item.status.statusColor(item.processing),
                                          showDescription: true,
                                          onTap: () {
                                            sendService(item);
                                            Navigator.of(context).pop();
                                          },
                                          user: item.user,
                                          serviceName: item.title,
                                          bannerUrl: item.banner.isNotEmpty
                                              ? item.banner.first.thumbnail
                                              : null,
                                          serviceType: item
                                              .servicePricing.tileDisplayName,
                                          serviceLocation:
                                              item.serviceType.simpleName,
                                          serviceCharge: item.price,
                                          discount: item.percentDiscount ?? 0,
                                          serviceDescription: item.description,
                                          date: item.createdAt.toString(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      });
                },
                message: "Send an existing service",
              ),
              const Divider(thickness: 0.5, height: 10),
              addVerticalSpacing(10),
              VWidgetsBottomSheetTile(
                onTap: () async {
                  Navigator.of(context)..pop();
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['zip'],
                  );

                  if (result != null) {
                    setState(() => zipFile = result.files.single.xFile);
                  } else {
                    setState(() => zipFile = null);
                  }
                },
                message: "Upload File",
              ),
            ],
          ),
        );
      },
    );
  }

  void showCreateOfferModalSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(maxHeight: 50.h),
      backgroundColor: Colors.transparent,
      enableDrag: false,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      context: context,
      builder: (context) {
        return Container(
            height: SizerUtil.height * .93,
            padding: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: CreateOfferPage(
              onCreatOffer: (map) {},
            ));
      },
    );
  }

  void sendOffer(Map<String, dynamic> data) async {
    if (message.text.isNotEmpty) {
      var map = jsonEncode(<String, dynamic>{
        "message": jsonEncode(data),
        "is_item": true,
        "item_id": data['id'].toString(),
        "item_type": "OFFER"
      });
      wsMessage.add(map);
    }
  }
}

List<UploadOptions> createBookingOptions(BuildContext context) {
  return [
    UploadOptions(label: "Create an offer", onTap: () {}),
    UploadOptions(
        label: "Cancel",
        onTap: () {
          popSheet(context);
        }),
  ];
}

void _modalBuilder(BuildContext context) {
  showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  'Create an Offer',
                  style: Theme.of(context).textTheme.displayMedium,
                  // .copyWith(color: VmodelColors.primaryColor),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    constraints: BoxConstraints(maxHeight: 50.h),
                    isDismissible: false,
                    useRootNavigator: true,
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) => DraggableScrollableSheet(
                      expand: false,
                      key: UniqueKey(),
                      initialChildSize: 0.9,
                      maxChildSize: 0.9,
                      minChildSize: .5,
                      builder: (context, controller) => const CreateOffer(),
                    ),
                  );
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.displayMedium,
                // .copyWith(color: VmodelColors.primaryColor),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ));
}
