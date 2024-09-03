import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comments_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/post_comment.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:like_button/like_button.dart';

import 'comment/model/comment_ui_model_temp.dart';

class FeedFirstRowIcons extends ConsumerStatefulWidget {
  final VoidCallback like;
  final bool likedBool;
  final int? likeCount;
  final int? postId;
  final bool savedBool;
  final String postUsername;
  final String? postCaption;
  final DateTime? date;
  final CommentModelForUI? postData;
  // final bool? isOwnPost;
  final VoidCallback saved;
  final VoidCallback onLongPressed;
  final bool showCommentIcon;
  final bool showLikeIcon;
  final List<dynamic>? imageList;
  const FeedFirstRowIcons({
    Key? key,
    this.date,
    this.postData,
    this.showCommentIcon = true,
    this.showLikeIcon = true,
    required this.postUsername,
    this.postCaption,
    this.imageList,
    required this.saved,
    required this.onLongPressed,
    required this.like,
    this.likedBool = false,
    this.likeCount,
    required this.savedBool,
    this.postId,
    // this.isOwnPost,
  }) : super(
          key: key,
        );

  @override
  ConsumerState<FeedFirstRowIcons> createState() => _FeedFirstRowIconsState();
}

class _FeedFirstRowIconsState extends ConsumerState<FeedFirstRowIcons> {
  bool showSaved = false;

  @override
  Widget build(BuildContext context) {
    // final showSaved = ref.watch(showSavedProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !widget.showLikeIcon
            ? Container()
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LikeButton(
                    size: 25,
                    likeCount: widget.likeCount,
                    isLiked: widget.likedBool,
                    circleColor: CircleColor(start: Color.fromARGB(255, 242, 79, 67), end: Color.fromARGB(255, 242, 79, 67)),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: Color.fromARGB(255, 242, 79, 67),
                      dotSecondaryColor: Color.fromARGB(255, 242, 79, 67),
                    ),
                    // postFrameCallback: (LikeButtonState state) {
                    //   state.controller?.forward();
                    // },
                    countBuilder: (likeCount, isLiked, text) {
                      return SizedBox.shrink();
                    },
                    onTap: (isLiked) async {
                      // print("------------wow");
                      // if (!widget.showCommentIcon) {
                      //   return null;
                      // }
                      widget.like();
                      return !widget.likedBool;
                      // return isLiked;
                    },
                    likeBuilder: (bool isLiked) {
                      return RenderSvg(
                        // svgPath: widget.likedBool!
                        svgPath: isLiked ? VIcons.likedIcon : VIcons.feedLikeIcon,
                        // color: widget.likedBool!
                        color: isLiked ? Color.fromARGB(255, 242, 79, 67) : Theme.of(context).iconTheme.color,
                      );
                    },
                  ),
                  
                ],
              ),
        if (widget.showCommentIcon) addHorizontalSpacing(15),
        if (widget.showCommentIcon)
          GestureDetector(
              onTap: () {
                // widget.saved();
                showComments();
              },
              // child: RenderSvgWithoutColor(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RenderSvg(
                    svgPath: VIcons.commentNew,
                    color: Theme.of(context).iconTheme.color,
                    svgHeight: 25,
                    svgWidth: 25,
                  ),

                  //Temporary it think bro is still experimenting ui :)
                  // if(ref.watch(postCommentsProvider(widget.postData!.postId)).valueOrNull != null || (ref.watch(postCommentsProvider(widget.postData!.postId)).valueOrNull?.length ?? 0) > 1)
                  Text(
                    '1',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                ],
              ))
      ],
    );
  }

  void showComments() {
    // navigateToRoute(
    //   context,
    //   PostComments(
    //     postId: widget.postId ?? -1,
    //     postUsername: widget.postUsername,
    //     date: widget.date,
    //     postData: widget.postData!,
    //   ),
    //   useMaterial: true,
    // );
    //print('ie552 >>j ${widget.postData?.postId}');
    if (widget.postData == null || widget.postData!.postId < 1) return;
    VBottomSheetComponent.customBottomSheet(
      useRootNavigator: true,
      context: context,
      // isScrollControlled: false,
      isScrollControlled: true,
      style: VBottomSheetStyle(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      child: PostComments(
        postId: widget.postId ?? -1,
        postUsername: widget.postUsername,
        date: widget.date,
        postData: widget.postData!,
        postCaption: widget.postCaption,
      ),
    );
  }
}

class FeedSecondRowIcons extends StatelessWidget {
  final VoidCallback shareFunction;
  final VoidCallback send;
  final bool? showCommentIcon;
  final String? saveAmount;
  const FeedSecondRowIcons({
    super.key,
    required this.shareFunction,
    this.saveAmount,
    required this.send,
    this.showCommentIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCommentIcon!)
          GestureDetector(
              onTap: () {
                send();
              },
              child: RenderSvg(
                svgPath: VIcons.feedSendIcon,
                color: Theme.of(context).iconTheme.color,
                svgHeight: 22,
                svgWidth: 22,
              )),
        // addHorizontalSpacing(20),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: [
        //     GestureDetector(
        //       onTap: () {
        //         shareFunction();
        //       },
        //       child: const RenderSvg(
        //         svgPath: VIcons.feedShareIcon,
        //         svgHeight: 22,
        //         svgWidth: 22,
        //       ),
        //     ),
        //     // Padding(
        //     //   padding: const EdgeInsets.only(top: 7),
        //     //   child: Text(
        //     //     saveAmount ?? '300',
        //     //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
        //     //         fontSize: 12,
        //     //         fontWeight: FontWeight.w500,
        //     //         color: VmodelColors.primaryColor),
        //     //   ),
        //     // ),
        //   ],
        // ),
      ],
    );
  }
}
