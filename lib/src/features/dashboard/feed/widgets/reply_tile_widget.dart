import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/features/dashboard/feed/model/post_comments_model.dart';

import '../controller/post_comment_replies_controller.dart';
import '../model/post_comment_model_temp.dart';
import 'comment/complete_comment_reply_widget.dart';
import 'comment/comment_slidable_widget.dart';

class ReplyTile extends ConsumerStatefulWidget {
  const ReplyTile({
    super.key,
    // required this.comment,
    this.indentLevel = 0,
    required this.showReplyIcon, // = true,
    this.replyTo,
    required this.rootCommentId,
    required this.onReplyTap,
    required this.gotCountCallBack,
    this.posterImage,
    this.numberToShow,
    // this.commentator,
    required this.replies,
  });

  final bool showReplyIcon;
  final int indentLevel;
  final int? numberToShow;
  // final String postId;
  final String? replyTo;
  // final Function(ReplyParent reply) onReplyTap;
  // final Function(PostCommentsModel reply) onReplyTap;
  final Function(NewPostCommentsModel reply) onReplyTap;
  final Function(int count) gotCountCallBack;
  final String? posterImage;
  final int rootCommentId;
  // final String? commentator;

  // final List<ReplyParent> replies;
  final List<PostCommentsModel> replies;

  @override
  ConsumerState<ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends ConsumerState<ReplyTile> {
  final int maxIndentLevel = 1;
  final double indentWidth = 16;
  final double imageSize = 30;
  bool showAll = false;

  bool isMessageCollapsed = true;
  double get replyIndicatorIndent {
    return min(widget.indentLevel, maxIndentLevel) * indentWidth +
        imageSize +
        4;
  }

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final newReplies = ref.watch(commentRepliesProvider(widget.rootCommentId));
    final commentRepliesTotalNumber =
        ref.watch(commentRepliesTotalProvider(widget.rootCommentId));

    WidgetsBinding.instance.addPostFrameCallback((x) {
      widget.gotCountCallBack(commentRepliesTotalNumber);
    });

    // final TextStyle baseStyle =
    //     Theme.of(context).textTheme.displaySmall!.copyWith(
    //           // color: VmodelColors.text,
    //           fontSize: 10.sp,
    //           fontWeight: FontWeight.w500,
    //         );
    // final replies = ref.watch(replyProvider(widget.commentId));
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

    return newReplies.maybeWhen(
      data: (data) {
        // data = data.reversed.toList();
        //If child comments are less
        // than 3 show all else make provision
        // to whow 'view more replies' text widget

        final sooso = data.length < 50 ? data.length : (data.length + 1);
        if (data.isEmpty) return SizedBox.shrink();
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.numberToShow != null
              ? widget.numberToShow
              : widget.showReplyIcon
                  ? sooso
                  : 1,
          itemBuilder: ((context, index) {
            final isAllRepliesFetched =
                data.length >= commentRepliesTotalNumber;

            if (index == data.length) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(commentRepliesProvider(widget.rootCommentId)
                              .notifier)
                          .fetchMoreData();
                    },
                    child: Container(
                      child: Text(
                        isAllRepliesFetched
                            // ? 'View less'
                            ? ''
                            // : 'View ${commentRepliesTotalNumber} replies',
                            : 'View more replies',
                        // '${widget.index + 1}-- ${widget.postTime}',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontSize: 10.sp,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  // color: Theme.of(context).colorScheme.onSecondary
                                  // .withOpacity(0.5),
                                ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return CommentSlidable(
              isPostReply: true,
              keyString: 'item-$index',
              postId: data[index].postId!,
              rootCommentId: widget.rootCommentId,
              commentId: data[index].idToInt,
              commentedBy: data[index].user!.username,
              commentModel: data[index],
              onReply: widget.onReplyTap,
              showReply: widget.showReplyIcon,
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.pink,
                //   border: Border.symmetric(
                //     horizontal: BorderSide(color: Colors.white),
                //   ),
                // ),
                // child: SizedBox.shrink(),
                child: NewCommentReplyTile(
                  showReplyIcon: widget.showReplyIcon,
                  commentModel: data[index],
                  onReplyTap: widget.onReplyTap,
                ),
              ),
            );
          }),
        );
      },
      orElse: () => Text('No data for new replies'),
    );
  }
}
