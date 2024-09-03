// import 'package:dm_stepper/dm_stepper.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
// import 'package:vmodel/src/core/utils/helper_functions.dart';
// import 'package:vmodel/src/core/utils/logs.dart';
// import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
// import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';
// import 'package:vmodel/src/features/reviews/views/booking_review.dart';
// import 'package:vmodel/src/res/icons.dart';
// import 'package:vmodel/src/res/res.dart';
// import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
// import 'package:vmodel/src/shared/appbar/appbar.dart';
// import 'package:vmodel/src/shared/buttons/primary_button.dart';
// import 'package:vmodel/src/shared/loader/loader_progress.dart';
// import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
// import 'package:vmodel/src/vmodel.dart';

// import '../../../../../../../main.dart';
// import '../../../../../../core/utils/costants.dart';
// import '../../../../../../res/SnackBarService.dart';
// import '../../../../../../shared/loader/full_screen_dialog_loader.dart';
// import '../../../../../../shared/modal_pill_widget.dart';
// import '../../../review_sheet.dart';
// import '../../model/booking_status.dart';
// import '../../widgets/booking_tile.dart';
// import '../controller/gig_controller.dart';
// import '../model/booking_id_tab.dart';

// class GigProgressPage extends ConsumerStatefulWidget {
//   const GigProgressPage({super.key, required this.bookingIdTab, required this.bookingId}); //, required this.status});
//   final BookingIdTab bookingIdTab;
//   final String bookingId;
//   // final BookingStatus status;

//   @override
//   ConsumerState<GigProgressPage> createState() => _GigProgressPageState();
// }

// class _GigProgressPageState extends ConsumerState<GigProgressPage> {
//   final refreshController = RefreshController();

//   @override
//   initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // Widget? showReviewButton(BookingModel booking) {
//   //   if (booking.status == BookingStatus.completed) {
//   //     if (booking.module == BookingModule.JOB) {
//   //       if (booking.bookieReview == null) {
//   //         return FloatingActionButton(
//   //           backgroundColor: Theme.of(context).primaryColor,
//   //           onPressed: () {
//   //             _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//   //           },
//   //           child: Icon(Icons.reviews),
//   //         );
//   //       } else {
//   //         return FloatingActionButton(
//   //           backgroundColor: Theme.of(context).primaryColor,
//   //           onPressed: () {
//   //             // navigateToRoute(
//   //             //     context,
//   //             //     BooingReviewPage(
//   //             //       bookerReview: booking.bookieReview,
//   //             //       bookieReview: booking.bookerReview,
//   //             //     ));
//   //             // _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//   //           },
//   //           child: Icon(Icons.rate_review),
//   //         );
//   //       }
//   //     } else {
//   //       if (booking.bookerReview == null) {
//   //         return FloatingActionButton(
//   //           backgroundColor: Theme.of(context).primaryColor,
//   //           onPressed: () {
//   //             _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//   //           },
//   //           child: Icon(Icons.reviews),
//   //         );
//   //       } else {
//   //         return FloatingActionButton(
//   //           backgroundColor: Theme.of(context).primaryColor,
//   //           onPressed: () {
//   //             navigateToRoute(
//   //                 context,
//   //                 BooingReviewPage(
//   //                   bookerReview: booking.bookieReview,
//   //                   bookieReview: booking.bookerReview,
//   //                 ));
//   //             // _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//   //           },
//   //           child: Icon(Icons.rate_review),
//   //         );
//   //       }
//   //     }
//   //   } else {
//   //     return null;
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final booking = ref.watch(selectedGigProvider(widget.bookingIdTab));
//     return Scaffold(
//         appBar: VWidgetsAppBar(
//           leadingIcon: const VWidgetsBackButton(),
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           appbarTitle: "Booking details",
//           trailingIcon: [],
//         ),
//         body: SmartRefresher(
//           controller: refreshController,
//           onRefresh: () async {
//             VMHapticsFeedback.lightImpact();
//             ref.invalidate(userBookingsProvider(widget.bookingIdTab.tab));
//             ref.invalidate(selectedGigProvider(widget.bookingIdTab));
//             refreshController.refreshCompleted();
//           },
//           child: Scaffold(
//             body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: [
//                   addVerticalSpacing(16),
//                   BookingTile(
//                     onItemTap: () {},
//                     status: booking.status.simpleName,
//                     statusColor: Colors.indigo,
//                     enableDescription: false,
//                     profileImage: booking.user?.profilePictureUrl,
//                     bookingPriceOption: booking.pricingOption.simpleName,
//                     location: booking.bookingType.simpleName,
//                     title: booking.title,
//                     jobDescription: '',
//                     date: booking.dateCreated.getSimpleDate(),
//                     bookingAmount: VConstants.noDecimalCurrencyFormatterGB.format(booking.price.round()),
//                   ),
//                   // addVerticalSpacing(32),
//                   // VWidgetsBusinessBookingItemCard(
//                   //   onItemTap: () {
//                   //     // navigateToRoute(context, BookingJobDetailPage(job: jobItem));
//                   //   },
//                   //   statusColor: Colors.blue,
//                   //   enableDescription: false,
//                   //   profileImage: VMString.testImageUrl,
//                   //   jobPriceOption: "Per Hour",
//                   //   location: "On Location",
//                   //   noOfApplicants: 3,
//                   //   profileName: 'My First job',
//                   //   jobDescription: 'The first sentence' * 33,
//                   //   date: DateTime.now().getSimpleDateOnJobCard(),
//                   //   appliedCandidateCount: "16",
//                   //   jobBudget: VConstants.noDecimalCurrencyFormatterGB.format(838),
//                   //   candidateType: "Female",
//                   //   shareJobOnPressed: () {},
//                   // ),
//                   addVerticalSpacing(16),
//                   Flexible(
//                     flex: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: DMStepper(
//                         getDMStepList(booking.status),
//                         stepCircleSize: 10,
//                         // backgroundColor: Colors.amber,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   if (booking.status == BookingStatus.bookieCompleted)
//                     VWidgetsPrimaryButton(
//                       butttonWidth: 30.w,
//                       buttonTitle: 'Confirm Completion',
//                       onPressed: () async {
//                         VLoader.changeLoadingState(true);
//                         _showConfirmBottomSheet(context);
//                       },
//                     ),
//                   // if (booking.status == BookingStatus.completed)
//                   //   VWidgetsPrimaryButton(
//                   //     butttonWidth: 30.w,
//                   //     buttonTitle: 'Review this service',
//                   //     onPressed: () async {
//                   //       _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//                   //     },
//                   //   ),
//                   addVerticalSpacing(42),
//                 ],
//               ),
//             ),
//             floatingActionButton:
//                 // showReviewButton(booking),
//                 (booking.status == BookingStatus.completed && booking.bookerReview == null)
//                     ? FloatingActionButton(
//                         backgroundColor: Theme.of(context).primaryColor,
//                         onPressed: () {
//                           _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//                         },
//                         child: Icon(Icons.reviews),
//                       )
//                     : (booking.status == BookingStatus.completed && booking.bookerReview != null)
//                         ? FloatingActionButton(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             onPressed: () {
//                               navigateToRoute(
//                                   context,
//                                   BooingReviewPage(
//                                     bookerReview: booking.bookieReview,
//                                     bookieReview: booking.bookerReview,
//                                   ));
//                               // _showReplyBottomSheet(context, booking.moduleUser!.displayName);
//                             },
//                             child: Icon(Icons.rate_review),
//                           )
//                         : null,
//           ),
//         ));
//   }

//   final _reviewLoaderProvider = StateProvider.autoDispose((ref) => true);
//   Future<dynamic> _showReplyBottomSheet(BuildContext context, String username) {
//     VMHapticsFeedback.lightImpact();
//     return showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         constraints: BoxConstraints(maxHeight: 50.h),
//         backgroundColor: Colors.transparent,
//         builder: (context) {
//           return ReviewBottomSheet(
//             bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
//             username: username ?? '',
//             onRatingCompleted: (String rating, String? review) async {
//               VLoader.changeLoadingState(true);
//               showAnimatedDialog(
//                 barrierColor: Colors.black54,
//                 context: context,
//                 child: Consumer(builder: (context, ref, child) {
//                   return LoaderProgress(
//                     done: !ref.watch(_reviewLoaderProvider),
//                     loading: ref.watch(_reviewLoaderProvider),
//                   );
//                 }),
//               );
//               final reviewUser =
//                   await ref.read(userBookingsProvider(widget.bookingIdTab.tab).notifier).reviewBookedUser(widget.bookingId, rating: rating, review: review);

//               VLoader.changeLoadingState(false);
//               reviewUser.fold(
//                 (p0) {
//                   Navigator.of(context)..pop();
//                   goBack(context);
//                   SnackBarService().showSnackBarError(context: context);
//                 },
//                 (p0) async {
//                   await ref.refresh(userBookingsProvider(widget.bookingIdTab.tab).future);
//                   ref.invalidate(selectedGigProvider(widget.bookingIdTab));
//                   ref.read(_reviewLoaderProvider.notifier).state = false;
//                   Future.delayed(Duration(seconds: 2), () {
//                     Navigator.of(context)..pop();
//                     goBack(context);
//                     SnackBarService().showSnackBar(message: "Review sent successfully", context: context);
//                   });
//                   // ref.invalidate(selectedGigProvider(widget.bookingIdTab));
//                   // Navigator.of(context)..pop();
//                 },
//               );
//             },
//           );
//         });
//   }

//   final _confirmCompletionLoadingProvider = StateProvider.autoDispose((ref) => true);
//   Future<dynamic> _showConfirmBottomSheet(BuildContext context) async {
//     VMHapticsFeedback.lightImpact();
//     return showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         constraints: BoxConstraints(maxHeight: 50.h),
//         backgroundColor: Colors.transparent,
//         builder: (context) {
//           return Consumer(
//             builder: (BuildContext context, WidgetRef ref, Widget? child) {
//               return Container(
//                 padding: const EdgeInsets.only(left: 16, right: 16),
//                 decoration: BoxDecoration(
//                   // color: Theme.of(context).scaffoldBackgroundColor,
//                   color: Theme.of(context).bottomSheetTheme.backgroundColor,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 ),
//                 child: // VWidgetsReportAccount(username: widget.username));
//                     Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     addVerticalSpacing(15),
//                     VWidgetsModalPill(),
//                     addVerticalSpacing(25),
//                     Center(
//                       child: Text(
//                           'Are you sure you want to confirm completion? Please make sure you have the confirmed the right deliverables. This cannot be undone.',
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.displaySmall!.copyWith(
//                                 color: Theme.of(context).primaryColor,
//                               )),
//                     ),
//                     addVerticalSpacing(30),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
//                       child: InkWell(
//                         onTap: () async {
//                           showAnimatedDialog(
//                             barrierColor: Colors.black54,
//                             context: context,
//                             child: Consumer(builder: (context, ref, child) {
//                               return LoaderProgress(
//                                 done: !ref.watch(_confirmCompletionLoadingProvider),
//                                 loading: ref.watch(_confirmCompletionLoadingProvider),
//                               );
//                             }),
//                           );
//                           await ref.read(userBookingsProvider(widget.bookingIdTab.tab).notifier).bookerConfirmBookingCompleted(widget.bookingId);
//                           VLoader.changeLoadingState(false);
//                           ref.invalidate(selectedGigProvider(widget.bookingIdTab));
//                           ref.read(_confirmCompletionLoadingProvider.notifier).state = false;
//                           Future.delayed(Duration(seconds: 2), () {
//                             Navigator.of(context)..pop();
//                             goBack(context);
//                             SnackBarService().showSnackBar(message: "Job completed successfully", context: context);
//                             _showReplyBottomSheet(context, ref.read(selectedGigProvider(widget.bookingIdTab)).moduleUser!.displayName);
//                           });
//                         },
//                         child: Text("Confirm",
//                             style: Theme.of(context).textTheme.displayMedium!.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   color: Theme.of(context).primaryColor,
//                                 )),
//                       ),
//                     ),
//                     const Divider(
//                       thickness: 0.5,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
//                       child: GestureDetector(
//                         onTap: () {
//                           goBack(context);
//                         },
//                         child: Text('Cancel',
//                             style: Theme.of(context).textTheme.displayMedium!.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   color: Theme.of(context).primaryColor,
//                                 )),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     )
//                   ],
//                 ),
//               );
//             },
//             // child:
//           );
//           ;
//         });
//   }

//   List<DMStepModel> getDMStepList(BookingStatus bookingStatus) {
//     return [
//       DMStepModel(
//         label: '',
//         title: '',
//         stepIcon: const SizedBox.shrink(),
//         stepLabelWidget: IconWithText(
//           iconAsset: VIcons.bookingPencil,
//           text: 'Booking created',
//           isDone: bookingStatus.id >= BookingStatus.created.id,
//         ),
//         dmStepType: getStepType(bookingStatus, BookingStatus.created),
//         dmStepColorsModel: getColors(bookingStatus, BookingStatus.created),
//         // dmStepType: DMStepType.done,
//         // dmStepColorsModel: DMStepColorsModel().copyWith(
//         //   // doneIcon: Colors.black,
//         //   doneBackground: Theme.of(context).colorScheme.primary,
//         //   doneLink: Theme.of(context).colorScheme.primary,
//         //   currentBackground: Theme.of(context).colorScheme.primary,
//         //   currentLink: Theme.of(context).colorScheme.primary,
//         //   nextBackground: Colors.grey.shade300,
//         // ),
//       ),
//       DMStepModel(
//         title: '',
//         stepLabelWidget: IconWithText(
//           iconAsset: VIcons.bookingCalendar,
//           text: 'In progress',
//           isDone: bookingStatus.id >= BookingStatus.inProgress.id,
//         ),
//         stepIcon: const SizedBox.shrink(),
//         // dmStepType: DMStepType.current,
//         dmStepType: getStepType(bookingStatus, BookingStatus.inProgress),
//         dmStepColorsModel: getColors(bookingStatus, BookingStatus.inProgress),
//       ),
//       DMStepModel(
//         title: '',
//         stepLabelWidget: IconWithText(
//           iconAsset: VIcons.bookingRoundedOutlineStar,
//           text: '*Delivered',
//           isDone: bookingStatus.id >= BookingStatus.bookieCompleted.id,
//         ),
//         stepIcon: const SizedBox.shrink(),
//         dmStepType: getStepType(bookingStatus, BookingStatus.bookieCompleted),
//         dmStepColorsModel: getColors(bookingStatus, BookingStatus.bookieCompleted),
//         // dmStepType: DMStepType.next,
//         // dmStepColorsModel: DMStepColorsModel().copyWith(
//         //   doneBackground: Theme.of(context).colorScheme.primary,
//         //   doneLink: Theme.of(context).colorScheme.primary,
//         //   currentBackground: Theme.of(context).colorScheme.primary,
//         //   currentLink: Theme.of(context).colorScheme.primary,
//         //   nextBackground: Colors.grey.shade300,
//         // ),
//       ),
//       DMStepModel(
//         title: '',
//         stepLabelWidget: IconWithText(
//           iconAsset: VIcons.bookingRoundedOutlineStar,
//           text: 'Completed',
//           isDone: bookingStatus.id >= BookingStatus.completed.id,
//         ),
//         stepIcon: const SizedBox.shrink(),
//         dmStepType: getStepType(bookingStatus, BookingStatus.completed),
//         dmStepColorsModel: getColors(bookingStatus, BookingStatus.completed),
//         // dmStepType: DMStepType.next,
//         // dmStepColorsModel: DMStepColorsModel().copyWith(
//         //   doneBackground: Theme.of(context).colorScheme.primary,
//         //   doneLink: Theme.of(context).colorScheme.primary,
//         //   currentBackground: Theme.of(context).colorScheme.primary,
//         //   currentLink: Theme.of(context).colorScheme.primary,
//         //   nextBackground: Colors.grey.shade300,
//         // ),
//       ),
//       // DMStepModel(
//       //   title: '',
//       //   stepLabelWidget: IconWithText(
//       //     iconAsset: VIcons.bookingRoundedOutlineStar,
//       //     text: 'Client review',
//       //     isDone: bookingStatus.id >= BookingStatus.clientReview.id,
//       //   ),
//       //   stepIcon: const SizedBox.shrink(),
//       //   dmStepType: getStepType(bookingStatus, BookingStatus.clientReview),
//       //   dmStepColorsModel: getColors(bookingStatus, BookingStatus.clientReview),
//       //   // dmStepType: DMStepType.next,
//       //   // dmStepColorsModel: DMStepColorsModel().copyWith(
//       //   //   doneBackground: Theme.of(context).colorScheme.primary,
//       //   //   currentBackground: Theme.of(context).colorScheme.primary,
//       //   //   currentLink: Theme.of(context).colorScheme.primary,
//       //   //   nextBackground: Colors.grey.shade300,
//       //   // ),
//       // ),
//       DMStepModel(
//         title: '',
//         stepLabelWidget: IconWithText(
//           iconAsset: VIcons.bookingRoundedOutlineStar,
//           text: 'Payment complete',
//           isDone: bookingStatus.id >= BookingStatus.paymentCompleted.id,
//         ),
//         stepIcon: const SizedBox.shrink(),
//         dmStepType: getStepType(bookingStatus, BookingStatus.paymentCompleted),
//         dmStepColorsModel: getColors(bookingStatus, BookingStatus.paymentCompleted),
//         // dmStepType: DMStepType.next,
//         // dmStepColorsModel: DMStepColorsModel().copyWith(
//         //   doneBackground: Theme.of(context).colorScheme.primary,
//         //   currentBackground: Theme.of(context).colorScheme.primary,
//         //   currentLink: Theme.of(context).colorScheme.primary,
//         //   nextBackground: Colors.grey.shade300,
//         // ),
//       ),
//     ];
//   }

//   DMStepType getStepType(BookingStatus bookingStatus, BookingStatus step) {
//     DMStepType temp;
//     if (step == bookingStatus)
//       temp = DMStepType.current;
//     else if (step.id < bookingStatus.id)
//       temp = DMStepType.done;
//     else
//       temp = DMStepType.next;
//     // //print('{//>>>>>} ${bookingStatus.id} ?? ${step.id}  ==> $temp');
//     return temp;
//   }

//   DMStepColorsModel getColors(BookingStatus bookingStatus, BookingStatus step) {
//     final defaultColor = Colors.grey.shade300;
//     return DMStepColorsModel().copyWith(
//       doneBackground: step.id < bookingStatus.id ? Theme.of(context).colorScheme.primary : defaultColor,
//       doneLink: step.id < bookingStatus.id ? Theme.of(context).colorScheme.primary : defaultColor,
//       currentBackground: step == bookingStatus ? Theme.of(context).colorScheme.primary : defaultColor,
//       currentLink:
//           // step == bookingStatus
//           //     ? Theme.of(context).colorScheme.primary
//           //     : defaultColor,
//           defaultColor,
//       nextBackground: defaultColor,
//     );
//   }
// }

// class IconWithText extends StatelessWidget {
//   const IconWithText({super.key, required this.iconAsset, required this.text, required this.isDone});
//   final String iconAsset;
//   final String text;
//   final bool isDone;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         RenderSvg(svgPath: iconAsset),
//         addHorizontalSpacing(8),
//         Text(
//           text,
//           style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                 fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
//               ),
//         ),
//         // Spacer(),
//       ],
//     );
//   }
// }
