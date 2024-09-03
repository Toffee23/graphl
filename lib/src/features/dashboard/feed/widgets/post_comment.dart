import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/model/post_comment_model_temp.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/coment_tile_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';

import '../../../../res/res.dart';
import '../../../../vmodel.dart';
import '../controller/post_comment_replies_controller.dart';
import '../controller/post_comments_controller.dart';
import 'comment/comment_input_field.dart';
import 'comment/model/comment_ui_model_temp.dart';

class PostComments extends ConsumerStatefulWidget {
  PostComments({
    super.key,
    required this.postId,
    required this.postUsername,
    this.postCaption,
    required this.date,
    required this.postData,
    this.showReplyIcon = true,
    this.replyCommentOutsideModal,
    this.replyingReplyOutsideModal,
    // required this.onLike,
    // required this.onSave,
    // required this.onUsernameTap,
    // required this.onTaggedUserTap,
    // required this.postOnUsernameTap,
    // required this.postOnTaggedUserTap,
  });
  // final Future<bool> Function() onLike;
  // final Future<bool> Function() onSave;
  // final ValueChanged<String> onTaggedUserTap;
  // final VoidCallback onUsernameTap;
  final bool showReplyIcon;
  final int postId;
  final String postUsername;
  final String? postCaption;
  final DateTime? date;
  final CommentModelForUI postData;
  final NewPostCommentsModel? replyCommentOutsideModal;
  final NewPostCommentsModel? replyingReplyOutsideModal;

  @override
  ConsumerState<PostComments> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<PostComments> {
  // final String postUsername;
  final refreshController = RefreshController();

  final _showLoader = ValueNotifier(false);

  final _commentTextEditing = TextEditingController();
  final _replyTextEditing = TextEditingController();
  final tempCaption =
      "Unleash your style with our revolutionary photographer @testuser. Elevate your fashion game like never before. Use our product today and get the best out of premium #FashionForward #Fashion";
  final mockCommentMessage =
      "Assign Welcome to Gboard clipboard, @smitham any text you copy will be saved here. Touch and hold a clip to pin it . Unpinned clips will be deleted after 1 hour. Welcome to Gboard clipboard, any text you copy will be saved here.";

  final List<String> predefinedEmojis = [
    " 👏 ",
    " ❤️ ",
    " 🙌 ",
    " 😍 ",
    " 🤩 ",
    " 💯 ",
    " 🎉 ",
    " 🥰 ",
    // " 🙏 ",
    " ✅ ",
  ];
  ScrollController _scrollController = ScrollController();
  final homeCtrl = Get.put<HomeController>(HomeController());
  final _debounce = Debounce();
  late final FocusNode commentFieldNode;
  late final Random random;
  bool showSendButton = false;
  String commentator = "";

  bool _isReply = false;
  bool _showSendButton = false;
  int commentId = 0;
  int rootCommentId = 0;
  @override
  initState() {
    super.initState();
    random = Random();
    commentFieldNode = FocusNode();
    _commentTextEditing.addListener(_textChanged);
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = SizerUtil.height * 0.2;
      if (maxScroll - currentScroll <= delta) {
        _debounce(() {
          ref
              .read(postCommentsProvider(widget.postId).notifier)
              .fetchMoreData(widget.postId);
        });
      }
    });

    if (widget.replyingReplyOutsideModal != null) {
      commentFieldNode.requestFocus();
      _isReply = true;
      commentId = widget.replyingReplyOutsideModal!.idToInt;
      rootCommentId = widget.replyingReplyOutsideModal!.rootParent?.idToInt ??
          widget.replyCommentOutsideModal!.idToInt;
      commentator = widget.replyingReplyOutsideModal!.user!.username;
      _replyTextEditing.text = '@${commentator} ';
      _replyTextEditing.selection = TextSelection.fromPosition(
          TextPosition(offset: _replyTextEditing.text.length));
    }
    if (widget.replyCommentOutsideModal != null) {
      commentFieldNode.requestFocus();
      _isReply = true;
      commentId = widget.replyCommentOutsideModal!.idToInt;
      rootCommentId = widget.replyCommentOutsideModal!.rootParent?.idToInt ??
          widget.replyCommentOutsideModal!.idToInt;
      commentator = widget.replyCommentOutsideModal!.user!.username;
    }
  }

  void _textChanged() {
    setState(() {
      showSendButton = _commentTextEditing.text.isNotEmpty;
      //print(showSendButton);
    });
  }

  @override
  dispose() {
    commentFieldNode.dispose();
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  // final rand = Random();
  @override
  Widget build(BuildContext context) {
    // //print("sjioejwf${widget.postId}");
    final comments = ref.watch(postCommentsProvider(widget.postId));
    final userState = ref.watch(appUserProvider);
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    final user = userState.valueOrNull;
    return
        // Scaffold(
        //   backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
        //   appBar: PreferredSize(
        //     preferredSize: Size.fromHeight(40),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 10),
        //       child: UnconstrainedBox(child: VWidgetsModalPill()),
        //     ),
        //   ),
        //   body:
        Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        comments.when(
          data: (data) {
            if (data.isNotEmpty)
              return Column(
                children: [
                  if (data.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.length.toInt() > 1 ? "Comments" : "Comment",
                              // '${data.length.toInt().pluralize("Comment")}',
                              // '${widget.index + 1}-- ${widget.postTime}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    // color: Theme.of(context).colorScheme.onSecondary
                                    // .withOpacity(0.5),
                                  ),
                            ),
                            // Spacer(),
                            // Text(
                            //   widget.date!.timeAgo(),
                            //   style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            //         color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                            //         fontSize: 8.sp,
                            //         // fontWeight: FontWeight.w400,
                            //       ),
                            // ),
                          ],
                        ),
                      ),
                    )
                  else
                    addVerticalSpacing(12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 45.h,
                    ),
                    child: SlidableAutoCloseBehavior(
                      closeWhenOpened: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: data.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return CommentTile(
                            commentParentBgColor: Colors
                                .transparent, // Theme.of(context).bottomSheetTheme.backgroundColor!,
                            indentLevel: 0,
                            showReplyIcon: widget.showReplyIcon,

                            replies: [],

                            onReplyWithIdTap: (reply) {
                              commentFieldNode.requestFocus();
                              _isReply = true;
                              commentId = reply.idToInt;
                              rootCommentId = reply.rootParent?.idToInt ??
                                  reply.idToInt ??
                                  -1;
                              commentator = reply.user!.username;
                              _replyTextEditing.text = '@${commentator} ';
                              _replyTextEditing.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _replyTextEditing.text.length));

                              setState(() {});
                            },
                            commentModel: data[index],
                            replyTo: ([2, 5].contains(index))
                                ? null
                                : data[index].user!.username,
                            onReplyCommentTap: (comment) {
                              commentFieldNode.requestFocus();
                              _isReply = true;
                              commentId = data[index].idToInt;
                              rootCommentId = data[index].rootParent?.idToInt ??
                                  data[index - 2].idToInt;
                              commentator = data[index].user!.username;
                              setState(() {});
                            },
                            posterImage: data[index].user!.thumbnailUrl,
                            commentator: data[index].user!.username,
                          );
                        },
                        //  CommentEndWidget(widget.postId),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 4);
                        },
                      ),
                    ),
                  ),
                  // SizedBox(height: 100.0)
                ],
              );
            else
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (data.length != 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 15, left: 15),
                  //     child: CaptionText(
                  //       username: widget.postUsername, // postUsername,
                  //       onUsernameTap: () {}, // postOnUsernameTap,
                  //       onMentionedUsernameTap: (val) {
                  //         context.push('/other_profile_router');
                  //         // navigateToRoute(
                  //         //   context,
                  //         //   OtherProfileRouter(username: val),
                  //         // );
                  //       }, // postOnTaggedUserTap,
                  //       // text: '${widget.imageList.first.description}',
                  //       text: widget.postCaption ?? '',
                  //     ),
                  //   ),
                  // if (data.length != 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 16, left: 15, right: 15),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(
                  //           '${data.length} Comments',
                  //           style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  //                 color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                  //                 fontSize: 8.sp,
                  //                 // fontWeight: FontWeight.w400,
                  //               ),
                  //         ),
                  //         Text(
                  //           widget.date!.getSimpleDate(),
                  //           style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  //                 color: Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5),
                  //                 fontSize: 8.sp,
                  //                 // fontWeight: FontWeight.w400,
                  //               ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // if (data.length == 0) addVerticalSpacing(50),
                  addVerticalSpacing(50),
                  Center(
                      child: Text("No comments Yet",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  fontSize: 22, fontWeight: FontWeight.w700))),
                  addVerticalSpacing(10),
                  Center(
                      child: Text("Start the conversation.",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(fontSize: 13))),
                  addVerticalSpacing(20),
                ],
              );
          },
          error: (error, stack) => Container(
            alignment: Alignment.center,
            child: Text(error.toString()),
          ),
          loading: () => Container(child: LoadingComments()),
        ),
        addVerticalSpacing(10),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
            width: 95.w,
            // height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // addHorizontalSpacing(16),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: ProfilePicture(
                    url: user!.thumbnailUrl,
                    headshotThumbnail: user.thumbnailUrl,
                    size: 35,
                    profileRing: user.profileRing,
                  ),
                ),
                addHorizontalSpacing(10),
                Expanded(
                  // width: 60.w,
                  child: VWidgetsCommentFieldNormal(
                    showSendButton: showSendButton,
                    controller:
                        _isReply ? _replyTextEditing : _commentTextEditing,
                    handleDoneButtonPress: !_showSendButton
                        ? () {}
                        : () async {
                            if (!_isReply) {
                              //print(widget.postId);
                              if (_commentTextEditing.text.isEmpty) {
                                return;
                              }
                              FocusScope.of(context).unfocus();

                              setState(() {
                                _showLoader.value = true;
                              });
                              await ref
                                  .read(postCommentsProvider(widget.postId)
                                      .notifier)
                                  .savePostComments(
                                    postId: widget.postId,
                                    comment: _commentTextEditing.text.trim(),
                                  );
                              _commentTextEditing.clear();
                              setState(() {
                                _showLoader.value = false;
                              });
                            } else {
                              //print(commentId);
                              if (_replyTextEditing.text.isEmpty) {
                                return;
                              }
                              FocusScope.of(context).unfocus();

                              setState(() {
                                _showLoader.value = true;
                              });
                              await ref
                                  .read(
                                      // postCommentsProvider(widget.postId)
                                      // commentRepliesProvider(widget.postId)
                                      commentRepliesProvider(rootCommentId)
                                          .notifier)
                                  .replyComment(
                                    commentId: widget.postId,
                                    reply: _replyTextEditing.text.trim(),
                                  );
                              ref.invalidate(
                                  commentRepliesProvider(rootCommentId));

                              _replyTextEditing.clear();
                              _showLoader.value = false;
                              _isReply = false;
                              // await _refreshIndicatorKey.currentState?.show();

                              setState(() {});
                            }
                          },
                    focusNode: commentFieldNode,
                    labelText: null,
                    maxLines: 3,
                    hintText: _isReply ? "Reply" : 'Write a comment',
                    // controller: locController,
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {
                      if (value!.isNotEmpty) {
                        _showSendButton = true;
                      } else {
                        _showSendButton = false;
                      }
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                if (_showLoader.value) addHorizontalSpacing(10),
                // addHorizontalSpacing(10),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: ValueListenableBuilder(
                    valueListenable: _showLoader,
                    builder: (context, value, child) {
                      if (value) {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      }
                      if (_showSendButton)
                        return AnimatedContainer(
                          width: _showSendButton ? 40 : 0,
                          height: _showSendButton ? 30 : 0,
                          duration: Duration(milliseconds: 150),
                          padding: _showSendButton
                              ? EdgeInsets.fromLTRB(5, 0, 0, 0)
                              : EdgeInsets.zero,
                          child: GestureDetector(
                            onTap: !_showSendButton
                                ? null
                                : () async {
                                    if (!_isReply) {
                                      //print(widget.postId);
                                      if (_commentTextEditing.text.isEmpty) {
                                        return;
                                      }
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        _showLoader.value = true;
                                      });
                                      await ref
                                          .read(postCommentsProvider(
                                                  widget.postId)
                                              .notifier)
                                          .savePostComments(
                                            postId: widget.postId,
                                            comment:
                                                _commentTextEditing.text.trim(),
                                          );
                                      _commentTextEditing.clear();
                                      setState(() {
                                        _showSendButton = false;
                                        _showLoader.value = false;
                                      });
                                    } else {
                                      //print(commentId);
                                      if (_replyTextEditing.text.isEmpty) {
                                        return;
                                      }
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        _showLoader.value = true;
                                      });
                                      await ref
                                          .read(commentRepliesProvider(
                                                  rootCommentId)
                                              .notifier)
                                          .replyComment(
                                            commentId: commentId,
                                            reply:
                                                _replyTextEditing.text.trim(),
                                          );

                                      ref.invalidate(commentRepliesProvider(
                                          rootCommentId));
                                      _replyTextEditing.clear();
                                      _showLoader.value = false;
                                      _isReply = false;
                                      _showSendButton = false;

                                      setState(() {});
                                    }
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Send",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      return SizedBox(width: 3);
                    },
                  ),
                ),
                addHorizontalSpacing(15),
              ],
            ),
          ),
        ),
        addVerticalSpacing(30),
      ],
    );

    // );
  }
}

class LoadingComments extends StatelessWidget {
  const LoadingComments({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      child: Row(
        children: [
          Container(
            height: 20,
            width: 25.w,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(44)),
            ),
          ),

          addHorizontalSpacing(24),
          Expanded(
            child: Container(
              height: 20,
              width: 35.w,
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                borderRadius: BorderRadius.all(Radius.circular(44)),
              ),
            ),
          ),

          // CircleAvatar(),
        ],
      ),
    );
  }
}

////Old Bodyo
/*

SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommentPost(
              username: widget.postUsername,
              postTime: widget.postData!.createdAt.getSimpleDate(),
              aspectRatio: widget.postData!.aspectRatio,
              homeCtrl: homeCtrl,
              imageList: widget.postData!.photos,
              userTagList: widget.postData!.taggedUsers,
              smallImageAsset: '${widget.postData!.postedBy.profilePictureUrl}',
              smallImageThumbnail: '${widget.postData!.postedBy.thumbnailUrl}',

              isVerified: widget.postData!.postedBy.isVerified,
              blueTickVerified: widget.postData!.postedBy.blueTickVerified,

              isOwnPost:
                  currentUser?.username == widget.postData!.postedBy.username,
              // onTaggedUserTap: (va){},
              caption: widget.postData!.caption ?? "",
            ),
            comments.when(
              data: (data) {
                if (data.isNotEmpty)
                  return SmartRefresher(
    controller: refreshController,
    onRefresh: () async {
    refreshController.refreshCompleted();
                    key: _refreshIndicatorKey,
                    onRefresh: () async =>
                        await ref.refresh(postCommentsProvider(widget.postId)),
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: data.length + 2,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        // //print(data[index].comment!.isEmpty);
                        if (index == 0)
                          // Show comments as the first item
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CaptionText(
                              username: widget.postUsername, // postUsername,
                              onUsernameTap: () {}, // postOnUsernameTap,
                              onMentionedUsernameTap: (val) {
                                navigateToRoute(
                                  context,
                                  OtherProfileRouter(username: val),
                                );
                              }, // postOnTaggedUserTap,
                              // text: '${widget.imageList.first.description}',
                              text: widget.postCaption ?? '',
                            ),
                          );

                        if (index == 1)
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${data.length} Comments',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.color
                                            ?.withOpacity(0.5),
                                        fontSize: 8.sp,
                                        // fontWeight: FontWeight.w400,
                                      ),
                                ),
                                Text(
                                  widget.date!. go(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.color
                                            ?.withOpacity(0.5),
                                        fontSize: 8.sp,
                                        // fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          );

                        return CommentTile(
                          indentLevel: 0,
                          showReplyIcon: widget.showReplyIcon,
                          // replies: data[index - 2].replyParent ?? [],
                          //Todo [comment] fix
                          replies: [],
                          // onReplyWithIdTap: (ReplyParent reply) {
                          onReplyWithIdTap: (reply) {
                            //print("[x-3b] $reply");
                            commentFieldNode.requestFocus();
                            _isReply = true;
                            commentId = reply.idToInt;
                            rootCommentId =
                                reply.rootParent?.idToInt ?? reply.idToInt;
                            commentator = reply.user!.username!;
                            //print(commentId);
                            setState(() {});
                          },
                          commentModel: data[index - 2],
                          replyTo: ([2, 5].contains(index - 2))
                              ? null
                              : data[index - 2].user!.username ?? "",
                          onReplyTap: () {
                            commentFieldNode.requestFocus();
                            _isReply = true;
                            commentId = data[index - 2].idToInt;
                            rootCommentId =
                                data[index - 2].rootParent?.idToInt ??
                                    data[index - 2].idToInt;
                            commentator = data[index - 2].user!.username!;
                            //print(commentId);
                            setState(() {});
                          },
                          posterImage: data[index - 2].user!.thumbnailUrl,
                          commentator: data[index - 2].user!.username,
                        );
                      },
                      //  CommentEndWidget(widget.postId),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 4);
                      },
                    ),
                  );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15, left: 15),
                      child: CaptionText(
                        username: widget.postUsername, // postUsername,
                        onUsernameTap: () {}, // postOnUsernameTap,
                        onMentionedUsernameTap: (val) {
                          navigateToRoute(
                            context,
                            OtherProfileRouter(username: val),
                          );
                        }, // postOnTaggedUserTap,
                        // text: '${widget.imageList.first.description}',
                        text: widget.postCaption ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${data.length} Comments',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.color
                                      ?.withOpacity(0.5),
                                  fontSize: 8.sp,
                                  // fontWeight: FontWeight.w400,
                                ),
                          ),
                          Text(
                            widget.date!.getSimpleDate(),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.color
                                      ?.withOpacity(0.5),
                                  fontSize: 8.sp,
                                  // fontWeight: FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    ),
                    addVerticalSpacing(50),
                    Center(child: Text("No comments")),
                  ],
                );
              },
              error: (error, stack) => Container(
                alignment: Alignment.center,
                child: Text(error.toString()),
              ),
              loading: () =>
                  Container(child: CircularProgressIndicator.adaptive()),
            ),
            addVerticalSpacing(200)
          ],
        ),
      )


 */
