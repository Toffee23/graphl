import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/dashboard/content/data/content_mock_data.dart';
import 'package:vmodel/src/features/notifications/widgets/date_time_extension.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../feed/model/post_comment_model_temp.dart';
import '../../feed/widgets/coment_tile_widget.dart';
import '../../new_profile/profile_features/widgets/profile_picture_widget.dart';

class VideoCommentsBottomSheet extends ConsumerStatefulWidget {
  const VideoCommentsBottomSheet({
    Key? key,
    this.onItemTap,
    required this.onClosed,
    required this.height,
    // this.bottomInsetPadding = 15,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  final VoidCallback onClosed;
  final double height;

  @override
  ConsumerState<VideoCommentsBottomSheet> createState() => _ClassAttendeesBottomSheetState();
}

class _ClassAttendeesBottomSheetState extends ConsumerState<VideoCommentsBottomSheet> {
  final names = ['Jane', 'Ellie', 'Jessica', 'Mark', 'Miley', 'Mary', 'Sophie', 'Mathew', 'Olivia', 'Elsa'];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.displayMedium;
    final coloWithOpacity = Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: VConstants.bottomPaddingForBottomSheets,
      ),
      constraints: BoxConstraints(
        maxHeight: widget.height,
        minHeight: SizerUtil.height * 0.2,
        minWidth: SizerUtil.width,
      ),
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Column(
        children: [
          addVerticalSpacing(15),
          const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
          addVerticalSpacing(15),
          Expanded(
            child: CustomScrollView(
              // shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  leading: SizedBox.shrink(),
                  // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
                  pinned: true,

                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // addVerticalSpacing(15),
                              // const Align(
                              //     alignment: Alignment.center,
                              //     child: VWidgetsModalPill()),
                              // addVerticalSpacing(25),
                              Text(
                                "Attendees",
                                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                "Tap on a profile picture to mute and unmute them",
                                maxLines: 1,
                                style: textTheme?.copyWith(
                                  fontSize: 11.sp,
                                  color: coloWithOpacity,
                                ),
                              ),
                              addVerticalSpacing(8),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClosed,
                          icon: Icon(Icons.close),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  actions: [],
                ),
                // StickySectionHeader(title: 'Speaking'),

                SliverList.separated(
                  itemCount: 20,
                  // shrinkWrap: true,
                  // padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    // print(data[index].comment!.isEmpty);

                    if (index == 0)
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${20} Comments',
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                    color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                                    fontSize: 8.sp,
                                    // fontWeight: FontWeight.w400,
                                  ),
                            ),
                            Text(
                              DateTime.now().timeAgo(),
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                    color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                                    fontSize: 8.sp,
                                    // fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                      );

                    return CommentTile(
                      commentParentBgColor: Theme.of(context).bottomSheetTheme.backgroundColor!,
                      indentLevel: 0,

                      showReplyIcon: false,
                      // replies: data[index - 2].replyParent ?? [],
                      //Todo [comment] fix
                      replies: [],
                      // onReplyWithIdTap: (ReplyParent reply) {
                      onReplyWithIdTap: (reply) {
                        // commentFieldNode.requestFocus();
                        // _isReply = true;
                        // commentId = reply.idToInt;
                        // rootCommentId =
                        //     reply.rootParent?.idToInt ?? reply.idToInt;
                        // commentator = reply.user!.username;
                        // print(commentId);
                        // setState(() {});
                      },
                      commentModel: NewPostCommentsModel.fromMap(mockComments[index % 5]
                          // postId: 1838,
                          // id: '9993',
                          // upVotes: 0,
                          // createdAt: '22-01-2024',
                          // updatedAt: '22-01-2024',
                          // comment: 'This is a sample comment' * 12,
                          // userLiked: false,
                          // hasChildren: false,
                          // childrenCount: 0,
                          ),
                      replyTo: null,
                      onReplyCommentTap: (comment) {
                        // commentFieldNode.requestFocus();
                        // _isReply = true;
                        // commentId = data[index - 2].idToInt;
                        // rootCommentId = data[index - 2].rootParent?.idToInt ??
                        //     data[index - 2].idToInt;
                        // commentator = data[index - 2].user!.username;
                        // print(commentId);
                        // setState(() {});
                      },
                      posterImage: VMString.testImageUrl,
                      commentator: 'Simone',
                    );
                  },
                  //  CommentEndWidget(widget.postId),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double factor) {
    return SliverGrid.builder(
      // shrinkWrap: true,
      // physics: BouncingScrollPhysics(),
      // padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: (liveImages.length * factor).toInt(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisExtent: 86,
      ),

      itemBuilder: ((context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfilePicture(
              showBorder: false,
              // borderColor: Colors.white,
              // borderWidth: 0,
              imageBorderPadding: EdgeInsets.zero,
              displayName: 'Janet Conner',
              url: liveImages[index % 10],
              headshotThumbnail: liveImages[index % 10],
              size: 50,
            ),
            Text(
              names[index % 10],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 10.sp,
                  ),
            ),
          ],
        );
      }),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.title,
    required this.textTheme,
  });

  final TextStyle? textTheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      // color: Theme.of(context).scaffoldBackgroundColor,
      color: Theme.of(context).bottomSheetTheme.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: textTheme?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
