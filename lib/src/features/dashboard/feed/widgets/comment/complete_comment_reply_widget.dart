import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/extensions/string_extensions.dart';

import '../../../../../core/controller/app_user_controller.dart';
import '../../../../../res/icons.dart';
import '../../../../../res/res.dart';
import '../../../../../shared/rend_paint/render_svg.dart';
import '../../../../../shared/username_verification.dart';
import '../../../../../vmodel.dart';
import '../../../new_profile/profile_features/widgets/profile_picture_widget.dart';
import '../../model/post_comment_model_temp.dart';
import '../comment_message.dart';

class NewCommentReplyTile extends ConsumerStatefulWidget {
  const NewCommentReplyTile({
    super.key,
    required this.commentModel,
    required this.onReplyTap,
    this.indentLevel = 1,
    required this.showReplyIcon,
  });

  final int indentLevel;
  final bool showReplyIcon;
  final NewPostCommentsModel commentModel;
  final Function(NewPostCommentsModel reply) onReplyTap;

  @override
  ConsumerState<NewCommentReplyTile> createState() =>
      _NewCommentReplyTileState();
}

class _NewCommentReplyTileState extends ConsumerState<NewCommentReplyTile> {
  bool isMessageCollapsed = true;
  final int maxIndentLevel = 1;
  final double indentWidth = 16;
  final double imageSize = 40;

  bool _userLikedReply = false;
  int _likeCount = 0;

  // double get replyIndicatorIndent {
  //   //print('[jxoo1] ${widget.indentLevel}');
  //   return min(widget.indentLevel, maxIndentLevel) * indentWidth +
  //       imageSize +
  //       4;
  // }

  @override
  void initState() {
    super.initState();
    _likeCount = widget.commentModel.upVotes ?? 0;
    _userLikedReply = widget.commentModel.userLiked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = ref
        .read(appUserProvider.notifier)
        .isCurrentUser("${widget.commentModel.user?.username}");
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

    void _toggleLike({bool callSetState = true}) {
      _userLikedReply = !_userLikedReply;
      _userLikedReply ? ++_likeCount : --_likeCount;
      if (callSetState) {
        setState(() {});
      }
    }

    return Container(
      padding: EdgeInsets.only(left: 44),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          addVerticalSpacing(4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCommentTopSection(
                username: widget.commentModel.user!.username,
                userType: widget.commentModel.user!.label ?? '',
                isVerified: widget.commentModel.user?.isVerified ?? false,
                blueTickVerified:
                    widget.commentModel.user?.blueTickVerified ?? false,
                isCurrentUser: isCurrentUser,
                posterImage: widget.commentModel.user!.thumbnailUrl ?? "",
                displayName: widget.commentModel.user!.displayName,
                profileRing: widget.commentModel.user!.profileRing,
              ),
              // addVerticalSpacing(2),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    addHorizontalSpacing(35),
                    Flexible(
                        child: CommentMessage(
                      username: widget.commentModel.user!.username,
                      text: widget.commentModel.comment,
                      isVerified: widget.commentModel.user?.isVerified ?? false,
                      blueTickVerified:
                          widget.commentModel.user?.blueTickVerified ?? false,
                      onUsernameTap: () {
                        if (!isCurrentUser) {
                          /*navigateToRoute(
                              context,
                              OtherUserProfile(
                                  username: widget.commentModel.user!.username));*/

                          String? _userName =
                              widget.commentModel.user!.username;
                          context.push(
                              '${Routes.otherUserProfile.split("/:").first}/$_userName');
                        }
                      },
                      onMentionedUsernameTap: (value) {},
                      isMessageCollapsed: (value) {
                        //print('[wxwx] onread more tap $value');
                        isMessageCollapsed = value;
                        setState(() {});
                      },
                    )),
                  ]),
              // addVerticalSpacing(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  addHorizontalSpacing(34),
                  // Text("5d",
                  //   style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  //     color: VmodelColors.greyColor,
                  //     fontSize: 10.sp,
                  //   ),
                  // ),
                  // addHorizontalSpacing(15),
                  GestureDetector(
                    onTap: () => widget.onReplyTap(widget.commentModel),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Reply",
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: VmodelColors.greyColor,
                                  fontSize: 10.sp,
                                ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: LikeButton(
                      size: 16,
                      likeCount: _likeCount,
                      isLiked: _userLikedReply,
                      circleColor: CircleColor(
                          start: Color.fromARGB(255, 242, 79, 67),
                          end: Color.fromARGB(255, 242, 79, 67)),
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
                          svgPath:
                              isLiked ? VIcons.likedIcon : VIcons.feedLikeIcon,
                          color: _userLikedReply
                              ? VmodelColors.heartIconColor
                              : VmodelColors.greyColor,
                          // color: isLiked
                          //     ? Color.fromARGB(255, 242, 79, 67)
                          //     : Theme.of(context).iconTheme.color,
                        );
                      },
                    ),
                  ),
                  addHorizontalSpacing(2),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _likeCount.toString(),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: VmodelColors.greyColor,
                                  fontSize: 10.sp,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              // buildCommentBottomSection(upVotes: '${_likeCount.pluralize('Like', pluralString: 'Likes')}'),
              //   ],
              // ),
              // if (widget.showReplyIcon)
              //   GestureDetector(
              //     onTap: () {
              //       //print("object");
              //       //[important] Todo reply fix
              //       widget.onReplyTap(widget.commentModel);
              //     },
              //     child: Container(
              //         color: Colors.transparent,
              //         padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              //         child: RenderSvgWithoutColor(
              //           svgPath: VIcons.commentReply,
              //           svgHeight: 20,
              //           svgWidth: 20,
              //         )

              //         // Text(
              //         //   'Reply3',
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
        ],
      ),
    );
  }

  Widget buildCommentTopSection({
    required String username,
    required String userType,
    required bool isVerified,
    required bool blueTickVerified,
    required bool isCurrentUser,
    required String? posterImage,
    required String? displayName,
    String? profileRing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePicture(
          url: posterImage ?? "",
          headshotThumbnail: posterImage ?? "",
          displayName: displayName,
          size: 25,
          profileRing: profileRing,
        ),
        addHorizontalSpacing(10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                              // color: VmodelColors.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                    isVerified: isVerified,
                    blueTickVerified: blueTickVerified,
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 30.w
                  ),
                  child: Text(
                    "• " + userType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: VmodelColors.greyColor,
                          fontSize: 9.sp,
                        ),
                  ),
                ),
                if (widget.commentModel.createdAt != null)
                  Text(
                    " • ${StringExtensions.toTimeAgo(widget.commentModel.createdAt!)}",
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          // color: VmodelColors.text,
                          fontWeight: FontWeight.w500,
                          color: VmodelColors.greyColor,
                          fontSize: 9.sp,
                        ),
                  )
              ],
            ),
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
      padding: const EdgeInsets.only(left: 44.0, bottom: 4),
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
            onTap: () => widget.onReplyTap(widget.commentModel),
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
