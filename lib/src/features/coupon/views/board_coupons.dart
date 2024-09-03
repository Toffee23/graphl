import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/coupon/controller/saved_coupon_controller.dart';
import 'package:vmodel/src/features/coupon/widget/coupon_tile.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../shared/picture_styles/rounded_square_avatar.dart';

class BoardCoupons extends ConsumerStatefulWidget {
   BoardCoupons({super.key,required this.boardTitle, required this.currentUser, required this.boardId});
  final String boardTitle;
  dynamic currentUser;
  int boardId;

  @override
  ConsumerState<BoardCoupons> createState() => _BoardCouponsState();
}

class _BoardCouponsState extends ConsumerState<BoardCoupons>
    with TickerProviderStateMixin {
  final _isSearchBarVisible = ValueNotifier<bool>(false);
  bool isSearchActive = false;
  var deletedCoupons = [];
  ScrollController _scrollController = ScrollController();
  final refreshController = RefreshController();

  List<MaterialColor> _colors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    // Colors.lime,
    // Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.purple,
    Colors.pink,
    Colors.red,
  ];
  int couponView = 0;


  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {

    final boardCoupons = ref.watch(boardCouponProvider(widget.boardId));
    final hh = MediaQuery.of(context).size.height;
    final wh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: '${widget.boardTitle} board',
        trailingIcon: [

        ],
      ),
      body: SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            VMHapticsFeedback.lightImpact();
          await ref.refresh(boardCouponProvider(widget.boardId));
            refreshController.refreshCompleted();
        },
        child: Container(
            child:boardCoupons.when(
                data: (items) {
                  if (items.isEmpty) return Container(
                      width: wh,
                      height: MediaQuery.of(context).size.height*.7,
                      child:EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No coupon saved'));
                  return  Container(
                    width: wh,
                    height: MediaQuery.of(context).size.height*.7,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 1.0,
                          mainAxisSpacing: 12.0,
                          mainAxisExtent: 70),
                      itemBuilder: (context, index) {
                        //print(items[index]);
                        if(deletedCoupons.contains(items[index].id!)){
                        return BoardCouponTile(
                          index:index,
                          couponId:items[index].id!,
                          couponTitle:items[index].title!,
                          couponCode:items[index].code!,
                          username:items[index].owner!.username,
                          date:items[index].dateCreated,
                          onSaveToggle: (value){
                            //print('coupon removed');
                            if(!value) deletedCoupons.add(items[index].id!);
                            return;
                          },
                        );
                        }else{
                          return SizedBox.shrink();
                        }

                      },
                      itemCount: items.length,
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return Container(
                      width: wh,
                      height: MediaQuery.of(context).size.height*.7,
                      child:Text('Error'));
                },
                loading: () {
                  return Center(child:  CircularProgressIndicator.adaptive(),);
                }
            )
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      height: 50,
      // color: Colors.red,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          Center(
            child: RenderSvg(
              svgHeight: 30,
              svgWidth: 30,
              svgPath: VIcons.documentLike,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          addVerticalSpacing(6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "No Contents Yet",
              textAlign: TextAlign.center,
              style: context.textTheme.displayLarge!.copyWith(fontSize: 11.sp),
            ),
          )
        ],
      ),
    );
  }

  Widget defaultBoard({
    required String title,
    required String thumbnail,
    required String assetPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: context.textTheme.displayMedium!.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          addVerticalSpacing(10),
          RoundedSquareAvatar(
            url: thumbnail,
            thumbnail: thumbnail,
            size: UploadAspectRatio.portrait.sizeFromX(43.w),
            errorWidget: ColoredBox(
              color: VmodelColors.jobDetailGrey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceBoard({
    required String title,
    required String thumbnail,
    VoidCallback? onTap,
    bool isEmpty = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: context.textTheme.displayMedium!.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          addVerticalSpacing(10),
          // if (!isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  height: 120,
                  width: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: AssetImage(VConstants.patternedImage),
                        fit: BoxFit.cover),
                  ),
                  alignment: Alignment.topLeft,
                  // child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: RenderSvg(
                  //     svgPath: VIcons.business,
                  //     color: VmodelColors.white,
                  //     svgWidth: 30,
                  //     svgHeight: 30,
                  //   ),
                  // ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Welcome to the Business Hub!",
                      //   style:
                      //       Theme.of(context).textTheme.displayLarge!.copyWith(
                      //             color: VmodelColors.white,
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 12.sp,
                      //           ),
                      // ),
                      addVerticalSpacing(4),
                      Text(
                        "View all your saved services",
                        textAlign: TextAlign.center,
                        style:
                        Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: VmodelColors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // if (isEmpty)
          //   RoundedSquareAvatar(
          //     url: thumbnail,
          //     thumbnail: thumbnail,
          //     size: Size(80.w, 120),
          //     errorWidget: ColoredBox(
          //       color: VmodelColors.jobDetailGrey.withOpacity(0.3),
          //     ),
          //   ),
        ],
      ),
    );
  }
}