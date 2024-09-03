
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';


class CouponBoardsWidget extends ConsumerStatefulWidget {
  const CouponBoardsWidget(
      {super.key,
      required this.boardId,
      required this.title,
      required this.createdAt,
      required this.numberOfCoupons,
      required this.code,
      required this.color,
      required this.onTap,
      });

  final int boardId;
  final DateTime createdAt;
  final int numberOfCoupons;
  final String code;
  final String title;
  final Color? color;
  final Function() onTap;

  @override
  ConsumerState<CouponBoardsWidget> createState() =>
      CouponBoardsWidgetState();
}
class CouponBoardsWidgetState
    extends ConsumerState<CouponBoardsWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {

    return  Padding(
      // padding: const EdgeInsets.all(8.0),
      padding: EdgeInsets.zero,
      child: Container(
        height: 80,
    width: SizerUtil.width,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    // color: widget.color,
    ),
    child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
          onTap: () {
            widget.onTap.call();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addVerticalSpacing(10),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 12.sp,
                      color: VmodelColors.white,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8,),
                Text(
                  widget.numberOfCoupons.toString()+ ' Coupons saved',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 8.sp,
                      color: VmodelColors.white.withOpacity(.8),
                      fontWeight: FontWeight.w400),
                ),
                addVerticalSpacing(4),
              ],
            ),
          ),
        ),
      )),
    );
  }

}
