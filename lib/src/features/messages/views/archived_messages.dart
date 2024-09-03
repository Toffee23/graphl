import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/features/messages/model/messages_route_model.dart';
import 'package:vmodel/src/features/messages/widgets/date_time_message.dart';
import 'package:vmodel/src/features/messages/widgets/message_homepage_card.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class ArchivedMessagesScreen extends ConsumerStatefulWidget {
  const ArchivedMessagesScreen({super.key});

  @override
  ConsumerState<ArchivedMessagesScreen> createState() => _ArchivedMessagesScreenState();
}

class _ArchivedMessagesScreenState extends ConsumerState<ArchivedMessagesScreen> {
  String selectedChip = "Model";
  bool isLiked = false;
  final refreshController = RefreshController();
  bool isLikedTemp = false;

  Future<void> reloadData() async {
    await ref.refresh(getArchivedConversations.future);
  }

  @override
  Widget build(BuildContext context) {
    final archivedMessages = ref.watch(getArchivedConversations);
    return Scaffold(
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          refreshController.refreshCompleted();
          return await reloadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              pinned: true,
              // snap: _snap,
              floating: true,
              title: Text(
                "Archived",
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              centerTitle: true,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: _titleSearch(),
              ),
              // leadingWidth: 150,
              leading: const VWidgetsBackButton(),
              elevation: 1,
              // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              // actions: [
              // ],
            ),
            archivedMessages.when(
                data: (p0) {
                   if (p0.isNotEmpty)
                      return SliverList.builder(
                        // shrinkWrap: true,
                        itemCount: p0.length,
                        itemBuilder: (context, index) {
                         var conversation = p0[index];
                            final date = conversation.lastMessage == null ? conversation.createdAt : conversation.lastMessage!.createdAt;
                            // final DateTime date = DateTime.parse(dateString);

                            bool isCurrentUserLastMessage = conversation.lastMessage == null ? false : ref.watch(appUserProvider.notifier).isCurrentUser(conversation.lastMessage!.sender!.username);
                            final bool read = conversation.lastMessage == null
                                ? true
                                : isCurrentUserLastMessage
                                    ? true
                                    : conversation.lastMessage!.read;
                            final unreadMessageCount = conversation.unreadMessagesCount;

                            return conversation.lastMessage == null
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () async {
                                      String? label = conversation.recipient.userType;
                                      int? id = int.parse(conversation.id);
                                      ref.refresh(conversationProvider(int.parse('${id}')));
                                      ref.read(chatIdProvider.notifier).state = id;
                                      String? username = conversation.recipient.username;
                                      String profilePicture = conversation.recipient.profilePictureUrl ?? '';
                                      String profileThumbnailUrl = conversation.recipient.profilePictureUrl ?? '';
                                      context.push(
                                        "/messagesChatScreen/$id/$username/${Uri.parse('profilePicture')}/${Uri.parse('profileThumbnailUrl')}/$label",
                                        extra: MessageRouteModel(messages: conversation.messageChunk),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: const VWidgetsPagePadding.horizontalSymmetric(18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: VWidgetsMessageCard(
                                              profileRing: conversation.recipient.profileRing,
                                              unreadMessageCount: unreadMessageCount,
                                              isCurrentUserLastMsg: isCurrentUserLastMessage,
                                              isRead: read,
                                              profileImage: conversation.recipient.profilePictureUrl,
                                              titleText: "${conversation.recipient.username}" ?? '',
                                              latestMessage: conversation.lastMessage != null
                                                  ? conversation.lastMessage!.text.toString().contains('message_type')
                                                      ? conversation.lastMessage!.text.substring(17, 24) == 'SERVICE'
                                                          ? '######service'
                                                          : conversation.lastMessage!.text.substring(17, 21) == 'POST'
                                                              ? '######post'
                                                              : ''
                                                      : conversation.lastMessage!.text
                                                  : '',
                                              latestMessageTime: date.timeAgoMessage(),
                                              onTapCard: () {
                                                String? label = conversation.recipient.userType;
                                                int? id = int.parse(conversation.id);
                                                String? username = conversation.recipient.username;
                                                String profilePicture = conversation.recipient.profilePictureUrl ?? '';
                                                String profileThumbnailUrl = conversation.recipient.profilePictureUrl ?? '';
                                                context.push(
                                                  "/messagesChatScreen/$id/$username/${Uri.parse('profilePicture')}/${Uri.parse('profileThumbnailUrl')}/$label",
                                                  extra: MessageRouteModel(messages: conversation.messageChunk),
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
                                  ); },
                      );

                    return SliverFillRemaining(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // addVerticalSpacing(300),
                          Text("No messages"),
                        ],
                      ),
                    );
                },
                error: (Object error, StackTrace stackTrace) {
                  //print('$error $stackTrace');
                  return SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // addVerticalSpacing(300),
                        Text("An error occured"),
                      ],
                    ),
                  );
                },
                loading: () => SliverFillRemaining(
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )),
          ],
        ),
      ),
      // appBar: VWidgetsAppBar(
      //   backgroundColor: VmodelColors.white,
      //   appbarTitle: "Archived",
      //   appBarHeight: 50,
      //   leadingIcon: const VWidgetsBackButton(),
      // ),
      // body:
    );
  }

  Widget _titleSearch() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: addVerticalSpacing(20)),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 13),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         "Discover",
          //         style: Theme.of(context).textTheme.displayLarge!.copyWith(
          //               fontWeight: FontWeight.w600,
          //               // color: VmodelColors.mainColor,
          //               fontSize: 16.sp,
          //             ),
          //       ),
          //     ],
          //   ),
          // ),
          addVerticalSpacing(10),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: SearchTextFieldWidget(
              hintText: "Search...",
              // controller: _searchController,
              // onChanged: (val) {},

              onTapOutside: (event) {},
              onTap: () {},
              // focusNode: myFocusNode,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(height: 5),

          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          //   child: Container(
          //     padding: const EdgeInsets.all(15),
          //     decoration: BoxDecoration(
          //         color: const Color(0xFFD9D9D9),
          //         borderRadius: BorderRadius.circular(8)),
          //     child: Container(
          //       padding: const EdgeInsets.all(2),
          //       decoration: BoxDecoration(
          //           color: VmodelColors.white,
          //           borderRadius: BorderRadius.circular(8)),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 15),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             IconButton(
          //               onPressed: () {
          //                 // navigateToRoute(context, const LocalServices());
          //               },
          //               icon: const RenderSvg(
          //                 svgPath: VIcons.addServiceOutline,
          //               ),
          //             ),
          //             IconButton(
          //               onPressed: () {
          //                 // navigateToRoute(context, AllJobs(job: job));
          //               },
          //               icon: const RenderSvg(
          //                 svgPath: VIcons.alignVerticalIcon,
          //               ),
          //             ),
          //             IconButton(
          //               onPressed: () {
          //                 navigateToRoute(context, const Explore());
          //               },
          //               icon: const RenderSvg(
          //                 svgPath: VIcons.searchIcon,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 10),
        ],
      ),
    );
  }
}
