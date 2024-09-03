import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/rating_model.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/notifiers.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/reviews/controllers/review_controller.dart';
import 'package:vmodel/src/features/reviews/views/review_sheet.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

class ReviewCard extends ConsumerStatefulWidget {
  const ReviewCard(
      {super.key, required this.review, this.isCurrentUser = false});
  final Review review;
  final bool isCurrentUser;

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard> {
  String replyText = '';
  bool reply = false;
  bool update = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfilePicture(
                    url: widget.review.reviewer.profilePictureUrl,
                    headshotThumbnail: widget.review.reviewer.profilePictureUrl,
                    size: 50,
                    profileRing: widget.review.reviewer.profileRing,
                  ),
                  const SizedBox(width: 5),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              widget.review.reviewer.username == 'teamvmodel'
                                  ? 'Team VModel'
                                  : widget.review.reviewer.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              child: Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (index) => RenderSvg(
                                      svgPath: VIcons.star,
                                      svgHeight: 13,
                                      svgWidth: 13,
                                      color:
                                          int.parse("${widget.review.rating}") >
                                                  index
                                              ? Colors.amber
                                              : context.appTheme.primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.review.reviewer.username == 'teamvmodel'
                              ? ""
                              : widget.review.reviewer.userType ?? '',
                          style: context.appTextTheme.labelMedium?.copyWith(
                            color:
                                context.appTheme.primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.99,
                          child: Text(
                            widget.review.reviewText,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.review.createdAt.getSimpleDate(),
                    style: context.appTextTheme.labelMedium?.copyWith(
                      color: context.appTheme.primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // ASSUMING ACCOUNT OWNERS SHOULD NOT BE ABLE TO SEE THIS POST -- THIS SHOULD BE DEPRECIATED
                    if (ref
                        .watch(appUserProvider.notifier)
                        .isCurrentUser(widget.review.reviewer.username)) ...[
                      GestureDetector(
                          onTap: () {
                            _showEditBottomSheet(context, widget.review);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text("Edit"),
                          ))

                      // ReviewsOutlinedButton(
                      //   text: 'Edit',
                      //   onTap: () => _showEditBottomSheet(context, widget.review),
                      // ),
                    ] else ...[
                      if (widget.review.reviewReply == null &&
                          widget.isCurrentUser)
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                reply = !reply;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text("Reply"),
                            )),
                      // ReviewsOutlinedButton(
                      //   text: 'Reply',
                      //   onTap: () =>
                      //       _showReplyBottomSheet(context, widget.review),
                      // ),
                    ],
                  ],
                ),
              ),

              // TOGGLING REPLY INPUTFIELD, SUBMIT CTA & COUNT NOTIFYER
              AnimatedOpacity(
                opacity: reply ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Visibility(
                  visible: reply,
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 500,
                        controller: replyController,
                        decoration: InputDecoration(
                          hintText: "Type your reply here",
                          counterText: "",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (replyText.length < 500) {
                            setState(() => replyText = value);
                          }
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // REPLY GESTURE SECTION
                            Row(
                              children: [
                                update
                                    ? GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            replyText = "";
                                            replyController.text = "";
                                            reply = false;
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text("Cancel"),
                                        ))
                                    : SizedBox(),
                              ],
                            ),

                            Text(
                                "${500 - replyText.length} Characters Remaining")
                          ],
                        ),
                      ),

                      VWidgetsPrimaryButton(
                          showLoadingIndicator: loading,
                          enableButton: true,
                          buttonTitle: update ? "Update" : "Submit",
                          onPressed: () async {
                            // update();

                            setState(() {
                              loading = true;
                            });

                            final replyReview = await ref
                                .read(reviewProvider.notifier)
                                .createOrReplyReview(
                                    reply: replyText,
                                    reviewId:
                                        int.parse(widget.review.id.toString()),
                                    reviewType:
                                        widget.review.reviewer.userType!);
                            if (!replyReview) {
                              SnackBarService()
                                  .showSnackBarError(context: context);
                            } else {
                              setState(() {
                                replyController.text = "";
                                reply = false;
                              });
                              SnackBarService().showSnackBar(
                                  message: "Reply sent", context: context);
                              await ref.refresh(reviewProvider.future);
                              // ref.read(_replyReviewLoaderProvider.notifier).state = false;
                              // Future.delayed(Duration(seconds: 2), () {
                              //   goBack(context);

                              // });
                            }
                          }),

                      // GestureDetector(
                      //               onTap: () async {
                      //                 final replyReview = await ref.read(reviewProvider.notifier).createOrReplyReview(reply: replyText!, reviewId: int.parse(widget.review.id.toString()), reviewType: widget.review.reviewer.userType!);
                      //                 if (!replyReview) {
                      //                   SnackBarService().showSnackBarError(context: context);
                      //                 } else {
                      //                   setState(() {
                      //                     replyController.text = "";
                      //                     reply = false;
                      //                   });

                      //                   await ref.refresh(reviewProvider.future);
                      //                   ref.read(_replyReviewLoaderProvider.notifier).state = false;
                      //                   Future.delayed(Duration(seconds: 2), () {
                      //                     goBack(context);
                      //                     // SnackBarService().showSnackBar(message: "Re successfully", context: context);
                      //                   });
                      //                 }
                      //               },
                      //               child: update ? Text("Update") : Text("Submit")

                      //               ),
                    ],
                  ),
                ),
              ),

              // DIDPLAY REVIEW REPLY HERE IF IT EXIST ----- & USER OWNER HASNT TOGGLED REPLY TO EDIT REPLY
              if (widget.review.reviewReply != null && !reply) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePicture(
                            url: widget.review.reviewed.profilePictureUrl,
                            headshotThumbnail:
                                widget.review.reviewed.profilePictureUrl,
                            displayName: widget.review.reviewed.username,
                            size: 50,
                            profileRing: widget.review.reviewed.profileRing,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.sizeOf(context).width / 1.6,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.4,
                                      child: Text(
                                        widget.review.reviewed.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      widget.review.reviewReply!.createdAt
                                          .getSimpleDate(),
                                      style: context.appTextTheme.labelMedium
                                          ?.copyWith(
                                        color: context.appTheme.primaryColor
                                            .withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                widget.review.reviewed.userType ?? '',
                                style:
                                    context.appTextTheme.labelMedium?.copyWith(
                                  color: context.appTheme.primaryColor
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 1.6,
                                  child: Text(
                                    widget.review.reviewReply!.replyText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          Spacer(),

                          // Row(
                          //   children: [
                          //     SizedBox(
                          //       width: 2,
                          //     ),
                          //     Text(
                          //       review.rating.toString(),
                          //       style: context.appTextTheme.bodyLarge?.copyWith(
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     Icon(
                          //       Icons.star_rounded,
                          //       color: context.appTheme.primaryColor,
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                      if (widget.isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (ref
                                    .watch(appUserProvider.notifier)
                                    .isCurrentUser(
                                        widget.review.reviewed.username)) ...[
                                  // ReviewsOutlinedButton(
                                  //   text: 'Edit',
                                  //   onTap: () => _showReplyBottomSheet(
                                  //       context, widget.review),
                                  // ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          reply = true;
                                          update = true;
                                          replyController.text = widget
                                              .review.reviewReply!.replyText;
                                        });
                                      },
                                      child: reply
                                          ? Text("Cancel")
                                          : Text("Edit")),
                                  // Spacer(),

                                  GestureDetector(
                                      onTap: () {
                                        showAnimatedDialog(
                                            context: context,
                                            child: VWidgetsConfirmationPopUp(
                                              popupTitle: "Delete Confirmation",
                                              popupDescription:
                                                  "Are you sure you want to delete this review reply ?",
                                              usePop: false,
                                              onPressedYes: () async {
                                                Navigator.of(context).pop();
                                                _deleteReviewReply(
                                                    context,
                                                    widget.review.reviewReply!,
                                                    ref);
                                              },
                                              onPressedNo: () {
                                                // Navigator.of(context).pop();
                                              },
                                            ));
                                      },
                                      child: Text("Delete")),

                                  // ReviewsOutlinedButton(
                                  //   text: 'Delete',
                                  //   onTap: () => _deleteReviewReply(
                                  //       context, widget.review, ref),
                                  // )
                                ]
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

final _reviewLoaderProvider = StateProvider.autoDispose((ref) => true);

Future<dynamic> _showEditBottomSheet(
  BuildContext context,
  Review review,
) {
  VMHapticsFeedback.lightImpact();
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(maxHeight: 50.h),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(builder: (context, ref, _) {
          return ReviewBottomSheet(
            // reviewId: null,
            // replyText: '',
            // replyEdit: false,
            // jobReview: true,
            // edit: false,
            // reply: false,
            // jobRating: true,
            review: review,
            bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
            username: review.reviewer.username,
            onRatingCompleted: (String rating, String? reviewText) async {
              showAnimatedDialog(
                barrierColor: Colors.black54,
                context: context,
                child: Consumer(builder: (context, ref, child) {
                  return LoaderProgress(
                    done: !ref.watch(_reviewLoaderProvider),
                    loading: ref.watch(_reviewLoaderProvider),
                  );
                }),
              );
              final editReview = await ref
                  .read(reviewProvider.notifier)
                  .updateReview(
                      reviewText: reviewText ?? review.reviewText,
                      reviewId: int.parse(review.id),
                      rating: rating,
                      reviewType: "review.reviewType ?? ''");
              if (!editReview) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                SnackBarService().showSnackBarError(context: context);
              } else {
                await ref.refresh(reviewProvider.future);
                ref.read(_reviewLoaderProvider.notifier).state = false;
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context)..pop();
                  goBack(context);
                  SnackBarService().showSnackBar(
                      message: "Review updated successfully", context: context);
                });
              }
            },
          );
        });
      });
}

final _replyReviewLoaderProvider = StateProvider.autoDispose((ref) => true);

// Future<dynamic> _showReplyBottomSheet(BuildContext context, Review review, [bool isEdit = false]) {
//   VMHapticsFeedback.lightImpact();
//   return showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       constraints: BoxConstraints(maxHeight: 50.h),
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Consumer(builder: (context, ref, _) {
//           return ReviewBottomSheet(
//             reply: review.replyReview,
//             bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
//             username: review.reviewer.username,
//             onRatingCompleted: (String rating, String? reviewText) async {
//               showAnimatedDialog(
//                 barrierColor: Colors.black54,
//                 context: context,
//                 child: Consumer(builder: (context, ref, child) {
//                   return LoaderProgress(
//                     done: !ref.watch(_replyReviewLoaderProvider),
//                     loading: ref.watch(_replyReviewLoaderProvider),
//                   );
//                 }),
//               );
//               final replyReview = await ref.read(reviewProvider.notifier).createOrReplyReview(reply: reviewText!, reviewId: int.parse(review.id.toString()), reviewType: review.reviewType!);
//               if (!replyReview) {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop();
//                 SnackBarService().showSnackBarError(context: context);
//               } else {
//                 await ref.refresh(reviewProvider.future);
//                 ref.read(_replyReviewLoaderProvider.notifier).state = false;
//                 Future.delayed(Duration(seconds: 2), () {
//                   Navigator.of(context)..pop();
//                   goBack(context);
//                   // SnackBarService().showSnackBar(message: "Re successfully", context: context);
//                 });
//               }
//             },
//           );
//         });
//       });
// }

final _deleteReviewReplyProvider = StateProvider((ref) => false);

Future<void> _deleteReviewReply(
    BuildContext context, ReviewReply reply, WidgetRef ref) async {
  showAnimatedDialog(
    barrierColor: Colors.black54,
    context: context,
    child: Consumer(builder: (context, ref, child) {
      return LoaderProgress(
        done: !ref.watch(_deleteReviewReplyProvider),
        loading: ref.watch(_deleteReviewReplyProvider),
      );
    }),
  );

  final deleteReply = await ref
      .read(reviewProvider.notifier)
      .deleteReviewReply(replyId: reply.id, context: context);
  if (!deleteReply) {
    Navigator.of(context).pop();
    SnackBarService().showSnackBarError(context: context);
  } else {
    ref.read(_deleteReviewReplyProvider.notifier).state = false;
    Future.delayed(Duration(seconds: 2), () {
      goBack(context);
      ref.invalidate(reviewProvider);
      // SnackBarService().showSnackBar(message: "Re successfully", context: context);
    });
  }
}
