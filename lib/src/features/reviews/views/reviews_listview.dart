// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
// import 'package:vmodel/src/core/cache/credentials.dart';
// import 'package:vmodel/src/core/utils/debounce.dart';
// import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
// import 'package:vmodel/src/features/reviews/controllers/review_controller.dart';
// import 'package:vmodel/src/features/reviews/views/review_sheet.dart';
// import 'package:vmodel/src/res/icons.dart';
// import 'package:vmodel/src/res/res.dart';
// import 'package:vmodel/src/shared/modal_pill_widget.dart';
// import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
// import 'package:vmodel/src/vmodel.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class DemoListTile extends ConsumerStatefulWidget {
//   DemoListTile({Key? key, required this.username, required this.profilePictureUrl, required this.thumbnailUrl, this.onDelete}) : super(key: key);
//   String username;
//   String profilePictureUrl;
//   String thumbnailUrl;
//   Function(int val)? onDelete;
//   @override
//   ConsumerState<DemoListTile> createState() => _DemoListTileState();
// }

// class _DemoListTileState extends ConsumerState<DemoListTile> {
//   late final Debounce _debounce;
//   ScrollController _scrollController = ScrollController();
//   String username = '';
//   final refreshController = RefreshController();

//   @override
//   void initState() {
//     getUser();
//     _debounce = Debounce(delay: Duration(milliseconds: 300));
//     _scrollController.addListener(() {
//       final maxScroll = _scrollController.position.maxScrollExtent;
//       final currentScroll = _scrollController.position.pixels;
//       final delta = SizerUtil.height * 0.2;
//       if (maxScroll - currentScroll <= delta) {
//         _debounce(() {
//           ref.read(reviewProvider(widget.username).notifier).fetchMoreData();
//         });
//       }
//     });

//     super.initState();
//   }

//   void getUser() async {
//     username = (await VCredentials.inst.getUsername()) ?? '';
//   }

//   Future<dynamic> _showEditBottomSheet(BuildContext context, {required String username, required editStr, required int reviewId, required int rating}) {
//     VMHapticsFeedback.lightImpact();
//     return showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         constraints: BoxConstraints(maxHeight: 50.h),
//         backgroundColor: Colors.transparent,
//         builder: (context) {
//           return ReviewBottomSheet(
//             editStr: editStr,
//             reviewId: reviewId,
//             edit: true,
//             reply: false,
//             bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
//             username: username,
//             onRatingCompleted: () {
//               try {
//                 widget.onDelete?.call(rating);
//               } catch (e) {}
//               Navigator.of(context)..pop();
//             },
//           );
//         });
//   }

//   Future<dynamic> _showReplyBottomSheet(BuildContext context, {required String username, required int reviewId, String? replyText}) {
//     VMHapticsFeedback.lightImpact();
//     return showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         constraints: BoxConstraints(maxHeight: 50.h),
//         backgroundColor: Colors.transparent,
//         builder: (context) {
//           return ReviewBottomSheet(
//             reviewId: reviewId,
//             replyText: replyText,
//             replyEdit: true,
//             edit: false,
//             reply: true,
//             bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
//             username: username,
//             onRatingCompleted: () {
//               Navigator.of(context)..pop();
//             },
//           );
//         });
//   }

//   Future<dynamic> _showDeleteBottomSheet(BuildContext context, {required String username, required int reviewId}) {
//     VMHapticsFeedback.lightImpact();
//     return showModalBottomSheet<void>(
//         context: context,
//         backgroundColor: Colors.transparent,
//         builder: (BuildContext context) {
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
//                     const VWidgetsModalPill(),
//                     addVerticalSpacing(25),
//                     Center(
//                       child: Text('Are you sure you want to delete this review? This action cannot be undone. ',
//                           style: Theme.of(context).textTheme.displaySmall!.copyWith(
//                                 color: Theme.of(context).primaryColor,
//                               )),
//                     ),
//                     addVerticalSpacing(30),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
//                       child: GestureDetector(
//                         onTap: () async {
//                           VMHapticsFeedback.lightImpact();
//                           var result = await ref.read(reviewProvider(username).notifier).deleteReview(reviewId: reviewId);
//                           if (!result) return;
//                           try {
//                             widget.onDelete?.call(-1);
//                           } catch (e) {}
//                           Navigator.of(context)..pop();
//                         },
//                         child: Text("Delete",
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
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reviewState = ref.watch(reviewProvider(widget.username));
//     return reviewState.when(data: (reviews) {
//       if (reviews.isNotEmpty) //print("JohnPrints_reviews not empty");
//         return Column(
//           children: [
//             for (var index = 0; index < reviews.length; index++) ...[
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 0.0),
//                 child: Card(
//                   
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
//                     child: GestureDetector(
//                       onTap: () {
//                         // context.push('/review_page_content');
//                         //navigateToRoute(context, const ReviewsPageContent());
//                       },
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         addVerticalSpacing(05),
//                         Row(
//                           //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ProfilePicture(
//                                   displayName: '${reviews[index].reviewer?.username}',
//                                   url: '${reviews[index].reviewer?.profilePictureUrl}',
//                                   headshotThumbnail: '${reviews[index].reviewer?.thumbnailUrl}',
//                                   size: 44,
//                                   showBorder: false,
//                                 ),
//                                 addHorizontalSpacing(10),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       width: MediaQuery.sizeOf(context).width - 100,
//                                       child: Row(
//                                         children: [
//                                           Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "${reviews[index].reviewer?.firstName} ${reviews[index].reviewer?.lastName}",
//                                                 style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
//                                               ),
//                                               addVerticalSpacing(2),
//                                               Text(
//                                                 "${reviews[index].reviewer?.userType}",
//                                                 style: Theme.of(context).textTheme.displayMedium!.copyWith(
//                                                     fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor.withOpacity(0.3), fontSize: 10.sp),
//                                               ),
//                                             ],
//                                           ),
//                                           Spacer(),
//                                           Text(
//                                             "${reviews[index].rating}",
//                                             style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
//                                           ),
//                                           addHorizontalSpacing(3),
//                                           RenderSvg(
//                                             svgPath: VIcons.star,
//                                             svgHeight: 14,
//                                             svgWidth: 14,
//                                             color: VmodelColors.starColor,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     addVerticalSpacing(4),
//                                     Container(
//                                       width: MediaQuery.sizeOf(context).width - 100,
//                                       child: Row(
//                                         children: [
//                                           Text(
//                                             "",
//                                             style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
//                                           ),
//                                           Spacer(),
//                                           Text(
//                                             "${timeago.format(DateTime.parse(reviews[index].dateCreated))}",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .displaySmall!
//                                                 .copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         addVerticalSpacing(15),
//                         Text(
//                           reviews[index].comment ?? "",
//                           textAlign: TextAlign.start,
//                           //style: VmodelTypography2.kCommentTextStyle,
//                           style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
//                         ),
//                         if (reviews[index].reviewReply != null) SizedBox(height: 5),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 10.0),
//                           child: Column(
//                             children: [
//                               if (reviews[index].reviewReply != null)
//                                 Row(
//                                   children: [
//                                     ProfilePicture(
//                                       url: widget.profilePictureUrl,
//                                       headshotThumbnail: widget.thumbnailUrl,
//                                       size: 40,
//                                     ),
//                                     addHorizontalSpacing(10),
//                                     Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "${reviews[index].reviewReply?.review?.reviewed.lastName} ${reviews[index].reviewReply?.review?.reviewed.firstName}",
//                                           style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
//                                         ),
//                                         addVerticalSpacing(2),
//                                         Text(
//                                           "${reviews[index].reviewReply?.review?.reviewed.userType}",
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .displayMedium!
//                                               .copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor.withOpacity(0.3), fontSize: 10.sp),
//                                         ),
//                                       ],
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       "${timeago.format(DateTime.parse(reviews[index].reviewReply?.dateCreated))}",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .displaySmall!
//                                           .copyWith(fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                     ),
//                                   ],
//                                 ),
//                               if (reviews[index].reviewReply != null) addVerticalSpacing(10),
//                               if (reviews[index].reviewReply != null)
//                                 Row(
//                                   children: [
//                                     addHorizontalSpacing(50),
//                                     Container(
//                                       width: MediaQuery.of(context).size.width * .65,
//                                       child: Text(
//                                         reviews[index].reviewReply?.reply ?? "",
//                                         textAlign: TextAlign.start,
//                                         //style: VmodelTypography2.kCommentTextStyle,
//                                         style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               if (reviews[index].reviewReply != null) SizedBox(height: 20),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 0.0),
//                                 child: Row(
//                                   children: [
//                                     if (widget.username == username)
//                                       InkWell(
//                                         child: Container(
//                                           width: MediaQuery.sizeOf(context).width / 4.2,
//                                           decoration: BoxDecoration(
//                                               border: Border.all(width: 1.2, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                               borderRadius: BorderRadius.circular(08)),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(5.0),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                 children: [
//                                                   Icon((reviews[index].reviewReply?.reply != null) ? Icons.edit_note : Icons.reply_sharp,
//                                                       size: 20, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                                   addHorizontalSpacing(05),
//                                                   Text(
//                                                     (reviews[index].reviewReply?.reply != null) ? "Edit" : "Reply",
//                                                     textAlign: TextAlign.start,
//                                                     //style: VmodelTypography2.kCommentTextStyle,
//                                                     style: Theme.of(context).textTheme.displaySmall!.copyWith(
//                                                         fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         onTap: () async {
//                                           _showReplyBottomSheet(context,
//                                               username: widget.username ?? '',
//                                               replyText: reviews[index].reviewReply?.reply,
//                                               reviewId: int.parse(reviews[index].id));
//                                         },
//                                       ),
//                                     if (widget.username == username) addHorizontalSpacing(20),
//                                     if (username == reviews[index].reviewer?.username && widget.username != username)
//                                       InkWell(
//                                         child: Container(
//                                           width: MediaQuery.sizeOf(context).width / 3.2,
//                                           decoration: BoxDecoration(
//                                               border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                               borderRadius: BorderRadius.circular(08)),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(5.0),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                                   addHorizontalSpacing(05),
//                                                   Text(
//                                                     "Edit",
//                                                     textAlign: TextAlign.start,
//                                                     //style: VmodelTypography2.kCommentTextStyle,
//                                                     style: Theme.of(context).textTheme.displaySmall!.copyWith(
//                                                         fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.6), fontSize: 14),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         onTap: () async {
//                                           _showEditBottomSheet(context,
//                                               rating: int.parse('${reviews[index].rating}'),
//                                               username: widget.username,
//                                               editStr: reviews[index].comment,
//                                               reviewId: int.parse(reviews[index].id));
//                                         },
//                                       ),
//                                     if (username == reviews[index].reviewer?.username && widget.username != username) addHorizontalSpacing(20),
//                                     if (username == reviews[index].reviewer?.username)
//                                       InkWell(
//                                           child: Container(
//                                             width: MediaQuery.sizeOf(context).width / 3.2,
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                                 borderRadius: BorderRadius.circular(08)),
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(5.0),
//                                               child: Center(
//                                                 child: Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     Icon(Icons.delete, size: 20, color: Theme.of(context).primaryColor.withOpacity(0.6)),
//                                                     addHorizontalSpacing(05),
//                                                     Text(
//                                                       "Delete",
//                                                       textAlign: TextAlign.start,
//                                                       //style: VmodelTypography2.kCommentTextStyle,
//                                                       style: Theme.of(context).textTheme.displaySmall!.copyWith(
//                                                           fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.6), fontSize: 14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           onTap: () {
//                                             _showDeleteBottomSheet(context, username: widget.username, reviewId: int.parse(reviews[index].id));
//                                           }),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ]),
//                     ),
//                   ),
//                 ),
//               ),
//               addVerticalSpacing(03),
//               // Divider(),
//               // addVerticalSpacing(10),
//             ]
//           ],
//         );

//       return Container(
//         child: SmartRefresher(
//           controller: refreshController,
//           onRefresh: () async {
//             ref.invalidate(reviewProvider);
//             refreshController.refreshCompleted();
//           },
//           child: Center(
//             child: Center(
//               child: Text(
//                 "No reviews available..",
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ),
//       );
//     }, loading: () {
//       return Center(child: CupertinoActivityIndicator());
//     }, error: (error, stackTrace) {
//       //print("jkcnwe $error $stackTrace");
//       return Container();
//     });
//   }
// }
