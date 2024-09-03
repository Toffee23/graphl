import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/string_extensions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment_message.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/reply_tile_widget.dart';
import '../../../../res/icons.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/res/res.dart';

import '../../../../shared/username_verification.dart';
import '../../../likes/controller/provider/likes_provider.dart';
import '../../new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../model/post_comment_model_temp.dart';
import 'comment/comment_slidable_widget.dart';

class CommentTile extends ConsumerStatefulWidget {
  const CommentTile({
    super.key,
    required this.commentModel,
    this.indentLevel = 0,
    required this.showReplyIcon, // = true,
    this.replyTo,
    this.posterImage,
    this.commentator,
    required this.replies,
    required this.onReplyCommentTap,
    required this.onReplyWithIdTap,
    required this.commentParentBgColor,
  });

  final int indentLevel;
  final bool showReplyIcon;

  // final String comment;
  final NewPostCommentsModel commentModel;
  final String? replyTo;
  final Function(NewPostCommentsModel comment) onReplyCommentTap;
  final String? posterImage;
  final String? commentator;

  // final Function(ReplyParent reply) onReplyWithIdTap;
  // final Function(PostCommentsModel reply) onReplyWithIdTap;
  final Function(NewPostCommentsModel reply) onReplyWithIdTap;

  // final List<ReplyParent> replies;
  final List<NewPostCommentsModel> replies;
  final Color commentParentBgColor;

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  final int maxIndentLevel = 1;
  final double indentWidth = 16;
  final double imageSize = 30;

  bool isMessageCollapsed = true;
  bool userLikedComment = false;

  ValueNotifier<int> totalRepliesCount = ValueNotifier(0);
  ValueNotifier<int> visibleRepliesCount = ValueNotifier(0);
  bool showViewMore = false;

  double get replyIndicatorIndent =>
      min(widget.indentLevel, maxIndentLevel) * indentWidth + imageSize + 4;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.commentModel.upVotes ?? 0;
    userLikedComment = widget.commentModel.userLiked ?? false;
  }

  String getViewMoreText() {
    int total = totalRepliesCount.value;
    int visible = visibleRepliesCount.value;
    int remaining = total - visible;

    if (remaining <= 0 && visible > 2) {
      return "View less";
    } else if (remaining > 0) {
      return "View ${remaining} more ${remaining == 1 ? 'reply' : 'replies'}";
    } else {
      return "";
    }
  }

  void updateVisibleRepliesCount() {
    int total = totalRepliesCount.value;
    int current = visibleRepliesCount.value;

    if (total <= 2) {
      visibleRepliesCount.value = total;
      showViewMore = false;
    } else if (current == 2) {
      visibleRepliesCount.value = min(total, current + 2);
      showViewMore = visibleRepliesCount.value < total;
    } else if (current < total) {
      visibleRepliesCount.value = min(total, current + 2);
      showViewMore = visibleRepliesCount.value < total;
    } else {
      visibleRepliesCount.value = 2;
      showViewMore = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.commentator);
    // final TextStyle baseStyle =
    //     Theme.of(context).textTheme.displaySmall!.copyWith(
    //           // color: VmodelColors.text,
    //           fontSize: 10.sp,
    //           fontWeight: FontWeight.w500,
    //         );

    final TextStyle? replyIndicatorStyle = Theme.of(context)
        .textTheme
        .displaySmall
        ?.copyWith(
            fontSize: 8.sp,
            color: Theme.of(context)
                .textTheme
                .displaySmall
                ?.color
                ?.withOpacity(0.5));

    void _toggleLike({bool callSetState = true}) async {
      userLikedComment = !userLikedComment;
      userLikedComment ? ++_likeCount : --_likeCount;
      VMHapticsFeedback.lightImpact();
      await ref
          .watch(likesProvider)
          .likeAComment(commentId: widget.commentModel.id!);
      if (callSetState) {
        setState(() {});
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: CommentSlidable(
                  isPostReply: false,
                  postId: widget.commentModel.postId!,
                  rootCommentId: widget.commentModel.rootParent?.idToInt,
                  commentId: widget.commentModel.idToInt,
                  keyString: 'item-${widget.commentModel.idToInt}',
                  commentedBy: '${widget.commentator}',
                  commentModel: widget.commentModel,
                  showReply: widget.showReplyIcon,
                  onReply: (comment) {
                    widget.onReplyWithIdTap(comment);
                    // widget.onReplyTap?.call();
                  },
                  child: ColoredBox(
                    color: widget.commentParentBgColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCommentTopSection(
                            username: widget.commentator!,
                            userType: widget.commentModel.user?.label ?? '',
                            isVerified:
                                widget.commentModel.user?.isVerified ?? false,
                            blueTickVerified:
                                widget.commentModel.user?.blueTickVerified ??
                                    false,
                            isCurrentUser: isCurrentUser),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            addHorizontalSpacing(37),
                            Flexible(
                                child: CommentMessage(
                              username: widget.commentator!,
                              text: widget.commentModel.comment,
                              isVerified:
                                  widget.commentModel.user?.isVerified ?? false,
                              blueTickVerified:
                                  widget.commentModel.user?.blueTickVerified ??
                                      false,
                              onUsernameTap: () {
                                if (!isCurrentUser) {
                                  /*navigateToRoute(
                                        context,
                                        OtherUserProfile(
                                            username: widget.commentator!));*/

                                  String? _userName = widget.commentator;
                                  context.push(
                                      '${Routes.otherUserProfile.split("/:").first}/$_userName');
                                }
                              },
                              onMentionedUsernameTap: (value) {
                                /*navigateToRoute(context,
                                      OtherProfileRouter(username: value));*/

                                String? _userName = value;
                                context.push(
                                    '${Routes.otherProfileRouter.split("/:").first}/$_userName');
                              },
                              isMessageCollapsed: (value) {
                                //print('[wxwx] onread more tap $value');
                                isMessageCollapsed = value;
                                setState(() {});
                              },
                            )),
                          ],
                        ),
                        // addVerticalSpacing(2),
                        Row(
                          children: [
                            addHorizontalSpacing(32),
                            GestureDetector(
                              onTap: () =>
                                  widget.onReplyCommentTap(widget.commentModel),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "Reply",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: VmodelColors.greyColor,
                                        fontSize: 10.sp,
                                      ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            ValueListenableBuilder(
                              valueListenable: totalRepliesCount,
                              builder: (_, value, child) {
                                return value == 0
                                    ? SizedBox()
                                    : GestureDetector(
                                        onTap: () {
                                          if (widget.showReplyIcon) {
                                            updateVisibleRepliesCount();
                                          } else {
                                            widget.onReplyCommentTap(
                                                widget.commentModel);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            !widget.showReplyIcon
                                                ? '${value} ${value > 1 ? 'replies' : 'reply'}'
                                                : getViewMoreText(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall!
                                                .copyWith(
                                                  color: VmodelColors.greyColor,
                                                  fontSize: 10.sp,
                                                ),
                                          ),
                                        ),
                                      );
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: LikeButton(
                                  size: 16,
                                  likeCount: _likeCount,
                                  isLiked: userLikedComment,
                                  circleColor: CircleColor(
                                      start: Color.fromARGB(255, 242, 79, 67),
                                      end: Color.fromARGB(255, 242, 79, 67)),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor:
                                        Color.fromARGB(255, 242, 79, 67),
                                    dotSecondaryColor:
                                        Color.fromARGB(255, 242, 79, 67),
                                  ),
                                  // postFrameCallback: (LikeButtonState state) {
                                  //   state.controller?.forward();
                                  // },
                                  countBuilder: (likeCount, isLiked, text) {
                                    return SizedBox.shrink();
                                  },
                                  onTap: (isLiked) async {
                                    VMHapticsFeedback.mediumImpact();
                                    // if (!widget.showCommentIcon) {
                                    //   return null;
                                    // }
                                    // widget.like();
                                    // return !widget.likedBool;
                                    _toggleLike();
                                    return !isLiked;
                                  },
                                  likeBuilder: (bool isLiked) {
                                    return RenderSvg(
                                      // svgPath: widget.likedBool!
                                      svgPath: isLiked
                                          ? VIcons.likedIcon
                                          : VIcons.feedLikeIcon,
                                      color: userLikedComment
                                          ? VmodelColors.heartIconColor
                                          : VmodelColors.greyColor,
                                      // color: isLiked
                                      //     ? Color.fromARGB(255, 242, 79, 67)
                                      //     : Theme.of(context).iconTheme.color,
                                    );
                                  },
                                )),
                            addHorizontalSpacing(2),
                            GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  _likeCount.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: VmodelColors.greyColor,
                                        fontSize: 10.sp,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // buildCommentBottomSection(upVotes: '${_likeCount.pluralize('Like', pluralString: 'Likes')}'),
                        // if (widget.showReplyIcon)
                        //   GestureDetector(
                        //     onTap: () {
                        //       widget.onReplyTap?.call();
                        //     },
                        //     child: Container(
                        //         color: Colors.transparent,
                        //         // color: Colors.blue,
                        //         padding: EdgeInsets.symmetric(
                        //             horizontal: 4, vertical: 1),
                        //         child: RenderSvgWithoutColor(
                        //           svgPath: VIcons.commentReply,
                        //           svgHeight: 20,
                        //           svgWidth: 20,
                        //         )

                        //         //  Text(
                        //         //   'Reply1',
                        //         //   style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        //         //         // color: VmodelColors.text,
                        //         //         fontSize: 8.sp,
                        //         //         fontWeight: FontWeight.w400,
                        //         //       ),
                        //         // ),
                        //         ),
                        //   )
                      ],
                    ),
                  ))),
          addVerticalSpacing(4),

          ValueListenableBuilder(
            valueListenable: visibleRepliesCount,
            builder: (_, value, child) {
              return Flexible(
                child: ReplyTile(
                  showReplyIcon: widget.showReplyIcon,
                  rootCommentId: widget.commentModel.idToInt,
                  replies: [],
                  indentLevel: 1,
                  replyTo: widget.commentator,
                  numberToShow: widget.showReplyIcon ? value : null,
                  gotCountCallBack: (int count) {
                    totalRepliesCount.value = count;
                    if (widget.showReplyIcon &&
                        visibleRepliesCount.value == 0) {
                      visibleRepliesCount.value = min(2, count);
                      showViewMore = count > 2;
                    }

                    // totalRepliesCount.value = count;
                    // if (widget.showReplyIcon &&
                    //     visibleRepliesCount.value == 0) {
                    //   updateVisibleRepliesCount();
                    // }
                  },
                  onReplyTap: (NewPostCommentsModel reply) {
                    widget.onReplyWithIdTap(reply);
                  },
                  posterImage: "thumbnailUrl",
                ),
              );
            },
          ),

          // ValueListenableBuilder(
          //     valueListenable: getNumberToShow,
          //     builder: (_, value, child) {
          //       return Flexible(
          //         child: ReplyTile(
          //           // replies: widget.replies,
          //           //Todo [comment] fix
          //           showReplyIcon: widget.showReplyIcon,
          //           rootCommentId: widget.commentModel.idToInt,
          //           replies: [],
          //           indentLevel: 1,
          //           numberToShow: getNumberToShow.value,
          //           // comment: "niwefiowhioen",
          //           replyTo: widget.commentator,
          //           // onReplyTap: (ReplyParent reply) {
          //           gotCountCallBack: (int count) {
          //             getRepliesCount.value = count;
          //             if (widget.showReplyIcon) {
          //               if (getRepliesCount.value == 1) {
          //                 getNumberToShow.value = 1;
          //               } else if (getRepliesCount.value == 2) {
          //                 getNumberToShow.value = 2;
          //               } else {
          //                 getNumberToShow.value = 2 - (count);
          //               }
          //             }
          //           },
          //           onReplyTap: (NewPostCommentsModel reply) {
          //             widget.onReplyWithIdTap(reply);
          //           },
          //           posterImage: "thumbnailUrl",
          //           // commentator: "username",
          //         ),
          //       );
          //     }),

          // Flexible(
          //   child: ReplyTile(
          //     replies: widget.replies,

          //     indentLevel: 2,
          //     comment: "niwefiowhioen",
          //     replyTo: widget.commentator,
          //     onReplyTap: (id) {
          //       // commentFieldNode.requestFocus();
          //     },
          //     posterImage: "thumbnailUrl",
          //     commentator: "username",
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildCommentTopSection(
      {required String username,
      required String userType,
      required bool isVerified,
      required bool blueTickVerified,
      required bool isCurrentUser}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfilePicture(
          url: widget.posterImage ?? "",
          headshotThumbnail: widget.posterImage ?? "",
          displayName: widget.commentator,
          size: 25,
          profileRing: widget.commentModel.user?.profileRing,
        ),
        addHorizontalSpacing(10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => usernameTap(isCurrentUser, username),
                  child: VerifiedUsernameWidget(
                    rowMainAxisSize: MainAxisSize.min,
                    useFlexible: true,
                    // iconSize: 8,
                    spaceSeparatorWidth: 2,
                    username: '${username}',
                    // displayName:
                    //     "${widget.commentModel.parent!.user?.displayN}",
                    textStyle:
                        Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                    isVerified: isVerified,
                    blueTickVerified: blueTickVerified,
                  ),
                ),
                Text(
                  "• " + userType,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: VmodelColors.greyColor,
                        fontSize: 9.sp,
                      ),
                ),

                if (widget.commentModel.createdAt != null)
                  Text(
                    " • ${StringExtensions.toTimeAgo(widget.commentModel.createdAt!)}",
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          // color:
                          //     Theme.of(context).primaryColor.withOpacity(0.3),
                          fontWeight: FontWeight.w500,
                          color: VmodelColors.greyColor,
                          fontSize: 9.sp,
                        ),
                  ),

                /// padding was added for only ios devices
                /// todo: keep for now till i can build on ios
                ///
                ///
                /*if (widget.commentModel.createdAt != null)
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isIOS) addVerticalSpacing(2),
                      Text(
                        " • ${StringExtensions.toTimeAgo(widget.commentModel.createdAt!)}",
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  // color:
                                  //     Theme.of(context).primaryColor.withOpacity(0.3),
                                  fontWeight: FontWeight.w500,
                                  color: VmodelColors.greyColor,
                                  fontSize: 9.sp,
                                ),
                      ),
                    ],
                  ),*/
              ],
            ),
            // addVerticalSpacing(4),
            // Text(
            //   userType,
            //   style: Theme.of(context).textTheme.displaySmall!.copyWith(
            //         color: VmodelColors.greyColor,
            //         fontSize: 9.sp,
            //       ),
            // ),
          ],
        )
      ],
    );
  }

  void usernameTap(isCurrentUser, username) {
    if (!isCurrentUser) {
      String? _userName = username;
      context.push('${Routes.otherUserProfile.split("/:").first}/$_userName');
    }
  }

  Widget buildCommentBottomSection({required String upVotes}) {
    return Padding(
      padding: const EdgeInsets.only(left: 55.0, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                upVotes,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: VmodelColors.greyColor,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => widget.onReplyCommentTap(widget.commentModel),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "Reply",
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: VmodelColors.greyColor,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
