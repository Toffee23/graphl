import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/rating_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/modal_pill_widget.dart';

class ReviewBottomSheet extends ConsumerStatefulWidget {
  const ReviewBottomSheet({Key? key, this.review, required this.onRatingCompleted, required this.username, this.bottomInsetPadding = 15, this.reply, this.reviewReply}) : super(key: key);
  final Function onRatingCompleted;
  final double bottomInsetPadding;
  final String username;
  final Review? review;
  final Reviewed? reply;
  final ReviewReply? reviewReply;
  // final bool edit;
  // final bool? jobReview;
  // final bool reply;
  // final String? editStr;
  // final int? reviewId;
  // final replyText;
  // final bool? replyEdit;
  // final bool? jobRating;

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  TextEditingController controller = TextEditingController();
  final maxReviewLength = 500;
  int rating = 2;
  TextEditingController _reviewController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ratingText = [
    'Negative Rating',
    'Negative Rating',
    'Average Rating',
    'Positive Rating',
    'Positive Rating',
  ];
  @override
  initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
          if (widget.review != null) {
            rating = widget.review!.rating.toInt() - 1;
            controller.text = widget.review!.reviewText;
          }
          if (widget.reply != null) {
            controller.text = widget.reviewReply!.replyText;
          }
        }));
    // controller = // widget.review != null
    //?
    // TextEditingController(text: widget.review?.reviewText)
    //: TextEditingController(text: widget.editStr.isEmptyOrNull || widget.reply ? '' : widget.editStr);
  }

  @override
  Widget build(BuildContext context) {
    final coloWithOpacity = Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        // bottom: VConstants.bottomPaddingForBottomSheets,
        bottom: widget.bottomInsetPadding,
      ),
      constraints: BoxConstraints(
        maxHeight: SizerUtil.height * 0.95,
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
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addVerticalSpacing(15),
              const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
              addVerticalSpacing(25),
              Text(
                widget.username.isEmpty ? "Rate this service" : "Rate ${widget.reply != null ? widget.reply!.username : widget.username}",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // if (widget.reply)
              //   Text(
              //     "Reply ${widget.username}.",
              //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
              //           fontSize: 12.sp,
              //           fontWeight: FontWeight.bold,
              //         ),
              //   ),
              addVerticalSpacing(16),
              if (widget.review != null || widget.reply != null) Text("Edit your feedback"),
              if (widget.reply == null) ...[
                addVerticalSpacing(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index;
                        });
                      },
                      icon: RenderSvg(
                        svgPath: VIcons.star,
                        color: index <= rating ? Colors.amber : context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                addVerticalSpacing(8),
                Text(
                  "${ratingText[rating]}",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 11.sp, color: coloWithOpacity),
                ),
              ],
              addVerticalSpacing(16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if ((value?.length ?? 0) < 5) {
                          return "Minimum 5 character review required";
                        } else {
                          return null;
                        }
                      },
                      controller: controller,
                      maxLines: 5,
                      maxLength: maxReviewLength,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Write a review...',
                        border: InputBorder.none,
                        // errorText: 'Hello',
                        counterText: '',
                        hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                              fontSize: 11.sp,
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${maxReviewLength - controller.text.length} characters remaining",
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // if (widget.jobReview != null && widget.jobReview!)
                        VWidgetsTextButton(
                            text: "Skip",
                            onPressed: () async {
                              await widget.onRatingCompleted("", "");
                            }),
                        if (widget.review == null && widget.reply == null)
                          VWidgetsTextButton(
                              text: "Save",
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  // if (widget.jobRating != true) {
                                  //   // var result = await ref
                                  //   //     .read(reviewProvider(widget.username).notifier)
                                  //   //     .rateUser(username: widget.username, comment: controller.text, rating: _getStatus(rating + 1));
                                  //   // if (!result) return;
                                  //   widget.onRatingCompleted();
                                  // } else {

                                  var wordRating;
                                  switch (rating + 1) {
                                    case 1:
                                      {
                                        setState(() {
                                          wordRating = 'ONE';
                                        });
                                        break;
                                      }
                                    case 2:
                                      {
                                        setState(() {
                                          wordRating = 'TWO';
                                        });
                                        break;
                                      }
                                    case 3:
                                      {
                                        setState(() {
                                          wordRating = 'THREE';
                                        });
                                        break;
                                      }
                                    case 4:
                                      {
                                        setState(() {
                                          wordRating = 'FOUR';
                                        });
                                        break;
                                      }
                                    case 5:
                                      {
                                        setState(() {
                                          wordRating = 'FIVE';
                                        });
                                        break;
                                      }
                                    default:
                                      {
                                        setState(() {
                                          wordRating = 'THREE';
                                        });
                                        break;
                                      }
                                  }

                                  widget.onRatingCompleted(wordRating, controller.text);
                                  // }
                                }
                              }),
                        if (widget.review != null || widget.reply != null)
                          VWidgetsTextButton(
                            text: "Edit",
                            onPressed: () async {
                              var wordRating;
                              switch (rating + 1) {
                                case 1:
                                  {
                                    setState(() {
                                      wordRating = 'ONE';
                                    });
                                    break;
                                  }
                                case 2:
                                  {
                                    setState(() {
                                      wordRating = 'TWO';
                                    });
                                    break;
                                  }
                                case 3:
                                  {
                                    setState(() {
                                      wordRating = 'THREE';
                                    });
                                    break;
                                  }
                                case 4:
                                  {
                                    setState(() {
                                      wordRating = 'FOUR';
                                    });
                                    break;
                                  }
                                case 5:
                                  {
                                    setState(() {
                                      wordRating = 'FIVE';
                                    });
                                    break;
                                  }
                                default:
                                  {
                                    setState(() {
                                      wordRating = 'THREE';
                                    });
                                    break;
                                  }
                              }

                              widget.onRatingCompleted(wordRating, controller.text);
                              // if (formKey.currentState?.validate() ?? false) {
                              //   var result = await ref.read(reviewProvider(widget.username).notifier).editReview(
                              //       reviewId: widget.reviewId!, username: widget.username, comment: controller.text, rating: _getStatus(rating + 1));
                              //   if (!result) return;
                              //   widget.onRatingCompleted();
                              // }
                            },
                          ),
                        // if (widget.reply && widget.jobRating != true)
                        //   VWidgetsTextButton(
                        //     text: "Send",
                        //     onPressed: () async {
                        //       // if (formKey.currentState?.validate() ?? false) {
                        //       //   if (controller.text.trim().length == 0) return;
                        //       //   var result = await ref.read(reviewProvider(widget.username).notifier).updateReview(
                        //       //         reviewId: widget.reviewId!,
                        //       //         reply: controller.text,
                        //       //       );
                        //       //   if (!result) return;
                        //       //   widget.onRatingCompleted();
                        //       // }
                        //     },
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
              addVerticalSpacing(24),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatus(int rate) {
    switch (rate) {
      case 1:
        return "ONE";
      case 2:
        return "TWO";
      case 3:
        return "THREE";
      case 4:
        return "FOUR";
      case 5:
        return "FIVE";
      default:
        return "THREE";
    }
  }
}
