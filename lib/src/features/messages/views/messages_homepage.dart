import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/features/messages/model/messages_route_model.dart';
import 'package:vmodel/src/features/messages/widgets/date_time_message.dart';
import 'package:vmodel/src/features/messages/widgets/message_homepage_card.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/picture_confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/bottom_sheets/tile.dart';

class MessagingHomePage extends ConsumerStatefulWidget {
  const MessagingHomePage({super.key});

  @override
  ConsumerState<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends ConsumerState<MessagingHomePage>
    with SingleTickerProviderStateMixin {
  String selectedChip = "Model";
  bool isLiked = false;
  final refreshController = RefreshController();
  bool isLikedTemp = false;

  Future<void> reloadData() async {
    ref.invalidate(getConversationsProvider);
  }

  SlidableController? slidableController;
  @override
  void initState() {
    slidableController = SlidableController(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(getConversationsProvider);
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Messages",
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        trailingIcon: [
          IconButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                //navigateToRoute(context, const ArchivedMessagesScreen());
                context.push("/archivedMessagesScreen");
              },
              icon: const RenderSvg(svgPath: VIcons.archiveIcon2)),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: VWidgetsPagePadding.horizontalSymmetric(18),
            child: SearchTextFieldWidget(
              hintText: 'Search',
            ),
          ),
          addVerticalSpacing(13),
          conversations.when(
              data: (p0) {
                if (p0.isNotEmpty)
                  return Expanded(
                    child: SlidableAutoCloseBehavior(
                      closeWhenOpened: true,
                      child: SmartRefresher(
                        controller: refreshController,
                        onRefresh: () async {
                          VMHapticsFeedback.lightImpact();
                          await reloadData();
                          refreshController.refreshCompleted();
                        },
                        child: ListView.builder(
                          // shrinkWrap: true,
                          itemCount: p0.length,
                          itemBuilder: (context, index) {
                            var conversation = p0[index];
                            final date = conversation.lastMessage == null
                                ? conversation.createdAt
                                : conversation.lastMessage!.createdAt;
                            // final DateTime date = DateTime.parse(dateString);

                            bool isCurrentUserLastMessage =
                                conversation.lastMessage == null
                                    ? false
                                    : ref
                                        .watch(appUserProvider.notifier)
                                        .isCurrentUser(conversation
                                            .lastMessage!.sender!.username);
                            final bool read = conversation.lastMessage == null
                                ? true
                                : isCurrentUserLastMessage
                                    ? true
                                    : conversation.lastMessage!.read;
                            final unreadMessageCount =
                                conversation.unreadMessagesCount;

                            return conversation.lastMessage == null
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () async {
                                      String? label =
                                          conversation.recipient.userType;
                                      int? id = int.parse(conversation.id);
                                      ref.refresh(conversationProvider(
                                          int.parse('${id}')));
                                      ref.read(chatIdProvider.notifier).state =
                                          id;
                                      String? username =
                                          conversation.recipient.username;
                                      String profilePicture = conversation
                                              .recipient.profilePictureUrl ??
                                          '';
                                      String profileThumbnailUrl = conversation
                                              .recipient.profilePictureUrl ??
                                          '';
                                      context.push(
                                        "/messagesChatScreen/$id/$username/${Uri.parse('profilePicture')}/${Uri.parse('profileThumbnailUrl')}/$label",
                                        extra: MessageRouteModel(
                                            messages:
                                                conversation.messageChunk),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: const VWidgetsPagePadding
                                          .horizontalSymmetric(18),
                                      child: Slidable(
                                        groupTag: "slider",
                                        key: Key("item_$index"),
                                        endActionPane: ActionPane(
                                          extentRatio: 0.5,
                                          motion: const StretchMotion(),
                                          dragDismissible: index != index,
                                          children: [
                                            // SlidableAction(
                                            //   onPressed: (context) {},
                                            //   foregroundColor:
                                            //       Colors.white,
                                            //   backgroundColor:
                                            //       Color.fromARGB(
                                            //           255, 186, 186, 187),
                                            //   label: 'Pin',
                                            // ),
                                            SlidableAction(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                      left: Radius.circular(5)),
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              onPressed: (context) {},
                                              foregroundColor: Colors.white,
                                              backgroundColor: Color.fromARGB(
                                                  255, 128, 128, 129),
                                              label: 'Mute',
                                            ),
                                            SlidableAction(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                      right:
                                                          Radius.circular(5)),
                                              onPressed: (context) {
                                                showModalBottomSheet<void>(
                                                    context: context,
                                                    useRootNavigator: true,
                                                    constraints: BoxConstraints(
                                                        maxHeight: 50.h),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 16,
                                                                right: 16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Theme.of(
                                                            context,
                                                          ).scaffoldBackgroundColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    13),
                                                            topRight:
                                                                Radius.circular(
                                                                    13),
                                                          ),
                                                        ),
                                                        child: VWidgetsConfirmationWithPictureBottomSheet(
                                                            username:
                                                                conversation
                                                                    .recipient
                                                                    .username,
                                                            profilePictureUrl:
                                                                conversation
                                                                    .recipient
                                                                    .profilePictureUrl,
                                                            profileThumbnailUrl:
                                                                conversation
                                                                    .recipient
                                                                    .profilePictureUrl,
                                                            actions: [
                                                              VWidgetsBottomSheetTile(
                                                                  message:
                                                                      'Yes',
                                                                  onTap: () {})
                                                            ],
                                                            dialogMessage:
                                                                'Are you sure you want to delete your messages with ${conversation.recipient.username}? This action cannot be undone'),
                                                      );
                                                    });
                                              },
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.red,
                                              label: 'Delete',
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: VWidgetsMessageCard(
                                                profileRing: conversation
                                                    .recipient.profileRing,
                                                unreadMessageCount:
                                                    unreadMessageCount,
                                                isCurrentUserLastMsg:
                                                    isCurrentUserLastMessage,
                                                isRead: read,
                                                profileImage: conversation
                                                    .recipient.thumbnailUrl,
                                                titleText:
                                                    "${conversation.recipient.username}" ??
                                                        '',
                                                latestMessage: conversation
                                                            .lastMessage !=
                                                        null
                                                    ? conversation
                                                            .lastMessage!.text
                                                            .toString()
                                                            .contains(
                                                                'message_type')
                                                        ? conversation
                                                                    .lastMessage!
                                                                    .text
                                                                    .substring(
                                                                        17,
                                                                        24) ==
                                                                'SERVICE'
                                                            ? '######service'
                                                            : conversation
                                                                        .lastMessage!
                                                                        .text
                                                                        .substring(
                                                                            17,
                                                                            21) ==
                                                                    'POST'
                                                                ? '######post'
                                                                : ''
                                                        : conversation
                                                            .lastMessage!.text
                                                    : '',
                                                latestMessageTime:
                                                    date.timeAgoMessage(),
                                                onTapCard: () {
                                                  String? label = conversation
                                                      .recipient.userType;
                                                  int? id = int.parse(
                                                      conversation.id);
                                                  String? username =
                                                      conversation
                                                          .recipient.username;
                                                  String profilePicture =
                                                      conversation.recipient
                                                              .profilePictureUrl ??
                                                          '';
                                                  String profileThumbnailUrl =
                                                      conversation.recipient
                                                              .profilePictureUrl ??
                                                          '';
                                                  context.push(
                                                    "/messagesChatScreen/$id/$username/${Uri.parse('profilePicture')}/${Uri.parse('profileThumbnailUrl')}/$label",
                                                    extra: MessageRouteModel(
                                                        messages: conversation
                                                            .messageChunk),
                                                  );
                                                },
                                                onPressedLike: () {
                                                  setState(() {
                                                    isLiked = !isLiked;
                                                  });
                                                },
                                              ),
                                            ),
                                            Divider(height: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                  );

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    addVerticalSpacing(300),
                    Text("No messages"),
                  ],
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ))
        ],
      ),
    );
  }
}

const String dateFormatter = 'MMM dd, y';

extension DateHelper on DateTime {
  String formatDateExtension() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}
