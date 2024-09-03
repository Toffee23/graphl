import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/features/coupon/controller/saved_coupon_controller.dart';
import 'package:vmodel/src/features/coupon/model/coupon_model.dart';
import 'package:vmodel/src/features/saved/views/saved_user_post.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/vmodel.dart';


class AddCouponToBoardsSheet extends ConsumerStatefulWidget {
  const AddCouponToBoardsSheet({
    Key? key,
    required this.couponId,
    required this.currentSavedValue,
    required this.username,
    required this.boardTitle,
    required this.onSaveToggle,
    this.unsave,
  }) : super(key: key);
  final String couponId;
  final String username;
  final String boardTitle;
  final bool currentSavedValue;
  final bool? unsave;
  final ValueChanged<bool> onSaveToggle;
  // final ValueNotifier<bool> showLoader;

  @override
  ConsumerState<AddCouponToBoardsSheet> createState() => _AddCouponToBoardsSheetState();
}

CouponBoardModel? pp;

class _AddCouponToBoardsSheetState extends ConsumerState<AddCouponToBoardsSheet> {
  final ValueNotifier<String> _completionText = ValueNotifier('');
  final boardsCouponHasBeenAddedIDs = [];
  var addState = {};
  bool refreshingBoard = false;
  int refreshingIndex = 0;
  bool savingCoupon = false;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final userPrefsConfig = ref.watch(userPrefsProvider);//animation
    // final userCouponBoards = ref.watch(boardCouponsProvider(widget.username));

    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpacing(15),
            const Align(
                alignment: Alignment.center, child: VWidgetsModalPill()),
            addVerticalSpacing(16),
            VWidgetsPrimaryButton(
              butttonWidth: MediaQuery.of(context).size.width,
              onPressed: saveCoupon,
              enableButton: true,
              buttonColor: widget.unsave==true?Colors.pink:null,
              showLoadingIndicator: savingCoupon,
              buttonTitle: widget.unsave==true?"Remove coupon from board":"Save coupon to board",
            ),
            // GestureDetector(
            //   onTap: () async {
            //     VMHapticsFeedback.lightImpact();
            //     showDialog(
            //         context: context,
            //         builder: (context) {
            //           return CreateNewBoardDialog(
            //             controller: TextEditingController(),
            //             onSave: (title) async {
            //               final Map<String, bool> success = await ref
            //                   .read(boardCouponsProvider(widget.username).notifier)
            //                   .createBoardAndAddCoupon(widget.couponId,title);
            //               print(success);
            //               if (success.values.first && context.mounted) {
            //                 goBack(context);
            //                 responseDialog(context, "Coupon Board created");
            //               ref.read(boardCouponsProvider(widget.username));
            //                 boardsCouponHasBeenAddedIDs.add(success.keys.first);
            //                 setState(() {});
            //               }else{
            //                 goBack(context);
            //                 responseDialog(context, "Couldn't create Board");
            //               }
            //             },
            //           );
            //         });
            //   },
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       Flexible(
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(vertical: 10),
            //           child: Text(
            //             "New Coupon Board",
            //             style:
            //             Theme.of(context).textTheme.displaySmall?.copyWith(
            //               // fontWeight: FontWeight.w600,
            //               color: Theme.of(context)
            //                   .textTheme
            //                   .displaySmall
            //                   ?.color
            //                   ?.withOpacity(0.5),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            //
            //
            // Padding(
            //   padding: EdgeInsets.only(bottom: 8, top: 16),
            //   child: Text(
            //     "Coupon Boards",
            //     style: Theme.of(context)
            //         .textTheme
            //         .displayMedium
            //         ?.copyWith(fontWeight: FontWeight.w700),
            //   ),
            // ),
            // Divider(thickness: 0.5, height: 20),
            // ListView.separated(
            //   shrinkWrap: true,
            //   // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: fewBoards(userCouponBoards.valueOrNull?.length),
            //   separatorBuilder: (context, index) {
            //     return Divider(thickness: 0.5, height: 20);
            //   },
            //   itemBuilder: (context, index) {
            //     return userCouponBoards.when(data: (items) {
            //       if(refreshingBoard && items.isNotEmpty){
            //         Timer(Duration(seconds: 1), () {
            //           setState(() {
            //             refreshingBoard = false;
            //           });
            //         });
            //       }
            //       if (items.isEmpty) return EmptyPage(
            //         svgSize: 30,
            //         svgPath: VIcons.gridIcon,
            //         subtitle: 'No board created',
            //       );
            //       return refreshingBoard && refreshingIndex == index?
            //       Center(
            //         child: index == 0?Lottie.asset(
            //           userPrefsConfig.value!.preferredDarkTheme ==
            //               VModelAppThemes.grey &&
            //               Theme.of(context).brightness == Brightness.dark
            //               ? 'assets/images/animations/loading_dark_ani.json'
            //               : 'assets/images/animations/shimmer_animation.json',
            //           height: 200,
            //           width: MediaQuery.of(context).size.width / 1.8,
            //           fit: BoxFit.fill,
            //         ):SizedBox.shrink(),
            //       )
            //           :GestureDetector(
            //         onTap: () {
            //           if(addState[items[index].id]==null){
            //             refreshingBoard = true;
            //             refreshingIndex = index;
            //             setState(() {});
            //           VMHapticsFeedback.lightImpact();
            //           ref.read(boardCouponsProvider(widget.username).notifier).addCouponToBoard(widget.couponId,items[index].id!,
            //           ).then((isSuccess) {
            //             print('Success                 ioioioioioioioioioioioioioioioioioioioioioi');
            //             print(isSuccess);
            //             refreshingBoard = true;
            //             setState(() {});
            //             if (!isSuccess) return;
            //             boardsCouponHasBeenAddedIDs.add(items[index].id);
            //             if(addState[items[index].id] == null){
            //               addState[items[index].id] = 1;
            //             }else{
            //               addState[items[index].id] = addState[items[index].id]+1;
            //             }
            //             ref.read(boardCouponsProvider(widget.username).notifier);
            //           });
            //           }
            //         },
            //         child: Container(
            //           color: Colors.transparent,
            //           child: Row(
            //             children: [
            //               Expanded(
            //                 flex: 2,
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       items[index].title!,
            //                       overflow: TextOverflow.ellipsis,
            //                       style: Theme.of(context)
            //                           .textTheme
            //                           .displayMedium
            //                           ?.copyWith(fontWeight: FontWeight.w600),
            //                     ),
            //                     Text(
            //                       "${VMString.bullet} ${(items[index].numberOfCoupons??0)+(addState[items[index].id]??0)} Coupons",
            //                       style: Theme.of(context).textTheme.displaySmall?.copyWith(
            //                         // fontWeight: FontWeight.w600,
            //                         fontSize: 10.sp,
            //                          color: Theme.of(context)
            //                             .textTheme
            //                             .displaySmall
            //                             ?.color
            //                             ?.withOpacity(0.5),
            //                       ),
            //                     )
            //                   ],
            //                 ),
            //               ),
            //               addHorizontalSpacing(16),
            //               addText(
            //                 context,
            //                 id: widget.couponId,
            //                 boardId: items[index].id!,
            //                 index:index
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }, error: (error, stackTrace) {
            //       return Text('Error');
            //     }, loading: () {
            //       return CircularProgressIndicator.adaptive();
            //     });
            //   },
            // ),
            addVerticalSpacing(16),
          ],
        ),
      ),
    );
  }

  int fewBoards(int? total) {
    if (total == null) return 0;
    return min(total, 15);
  }


  // Widget addText(BuildContext context, {required String id, required String boardId, required int index}) {
  //   return Consumer(
  //     builder: (context, ref, child) => GestureDetector(
  //       onTap: () {
  //         if(addState[boardId]==null){
  //           refreshingBoard = true;
  //           refreshingIndex = index;
  //         VMHapticsFeedback.lightImpact();
  //         ref.read(boardCouponsProvider(widget.username).notifier).addCouponToBoard(widget.couponId,boardId,
  //         ).then((isSuccess) {
  //           refreshingBoard = true;
  //           setState(() {});
  //           if (!isSuccess) return;
  //           boardsCouponHasBeenAddedIDs.add(boardId);
  //           if(addState[boardId] == null){
  //             addState[boardId] = 0;
  //           }else{
  //             addState[boardId] = addState[boardId]+1;
  //           }
  //           ref.read(boardCouponsProvider(widget.username).notifier);
  //         });
  //       }
  //       },
  //       child: boardsCouponHasBeenAddedIDs.contains(boardId)
  //           ? Icon(Icons.check)
  //           : Text(
  //         "Add",
  //         style: Theme.of(context).textTheme.displaySmall?.copyWith(
  //           // fontWeight: FontWeight.w600,
  //           color: Theme.of(context)
  //               .textTheme
  //               .displaySmall
  //               ?.color
  //               ?.withOpacity(0.5),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<bool> saveCoupon() async {
    //print(widget.couponId);
// return true;
//   }
//   f()async{
    setState(() {
      savingCoupon = true;
    });
    final connected = await checkConnection();
    if (connected) {
      VMHapticsFeedback.lightImpact();

      final result = await ref.read(boardCouponsProvider(widget.username).notifier).saveCoupon(widget.couponId);

      // ref.invalidate(getsavedCouponProvider);
      try{
        _completionText.value = _saveStateFromSucessResult(result)
            ? "Coupon saved"
            : "Coupon deleted";
      }catch(e){}
      if(widget.unsave==true){
        widget.onSaveToggle.call(widget.unsave==true?true:false);
      }
      setState(() {
        savingCoupon = false;
      });
      // responseDialog(
      //     context,
      //     'Success',
      //     body:widget.unsave==true
      //     ?"Coupon removed from board"
      //     :"Coupon saved to board",
      // );
      SnackBarService().showSnackBar(
          message:  widget.unsave==true
      ?"Coupon removed from board"
          :"Coupon saved to board",
          context: context);
      ref.read(showSavedProvider.notifier).state = !ref.read(showSavedProvider.notifier).state;

      return result;
    } else {
      setState(() {
        savingCoupon = false;
      });
      if (context.mounted) {
        // responseDialog(context, "No connection", body: "Try again");
        SnackBarService().showSnackBarError(
            context: context);
      }
    }

    return false;
  }



  bool _saveStateFromSucessResult(bool success) {
    bool newValue = widget.currentSavedValue;
    if (success) {
      newValue = !widget.currentSavedValue;
    }
    widget.onSaveToggle(newValue);
    return newValue;
  }
}
