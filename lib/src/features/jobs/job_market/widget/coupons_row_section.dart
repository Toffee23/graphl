
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/shared/shimmer/horizontal_coupon_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';
import '../controller/coupons_controller.dart';
import '../widget/hottest_coupon_tile.dart';

class HorizontalCouponSection extends ConsumerStatefulWidget {
  const HorizontalCouponSection({
    super.key,
    required this.title,
    this.trailingTitleWidget,
    this.autoScroll = true,
  });
  final String title;
  final Widget? trailingTitleWidget;
  final bool autoScroll;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HorizontalCouponSectionState();
}

class _HorizontalCouponSectionState extends ConsumerState<HorizontalCouponSection> {
  late List<MaterialColor> mColors;
  bool isEmptyOrError = false;

  @override
  initState() {
    super.initState();
  }

  void updateIsEmpty(bool value) {
    isEmptyOrError = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hottestCouponsSimple = ref.watch(hottestCouponsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: context.textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              widget.trailingTitleWidget ?? SizedBox.shrink(),
            ],
          ),
        ),
        Container(
          height: isEmptyOrError ? 0 : 100,
          margin: EdgeInsets.only(bottom: 16),
          child: hottestCouponsSimple.when(
            data: (value) {
              if (value.isEmpty) {
                updateIsEmpty(true);
              }
              return SizedBox(
                width: 95.w,
                child: CarouselSlider.builder(
                    // scrollDirection: Axis.horizontal,
                    // physics: BouncingScrollPhysics(),
                    options: CarouselOptions(
                      scrollDirection: Axis.horizontal,
                      enableInfiniteScroll: false,
                      autoPlay: widget.autoScroll,
                      enlargeCenterPage: false,
                      enlargeFactor: 0,
                      viewportFraction: 0.65,
                      autoPlayAnimationDuration: Duration(seconds: 20),
                      padEnds: false,
                      scrollPhysics: BouncingScrollPhysics(),
                      // autoPlayInterval: Duration.zero,
                      // height: 28.h,
                    ),
                    itemCount: value.length,
                    // padding: EdgeInsets.symmetric(horizontal: 16),
                    // separatorBuilder: (context, index) {
                    //   return addHorizontalSpacing(8);
                    // },
                    itemBuilder: (context, index, pageIndex) {
                      // if (index == value.length) {
                      //   return InkWell(
                      //     onTap: () {
                      //       context.push('/hottest_coupon_list');
                      //     },
                      //     child: Container(
                      //       width: 30.w,
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //         // color: mColors[index % mColors.length],
                      //         color: Colors.black,
                      //         borderRadius: BorderRadius.circular(10.0),
                      //       ),
                      //       child: Text(
                      //         "VIEW MORE",
                      //         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                      //       ),
                      //     ),
                      //   );
                      // }

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: HottestCouponTile(
                            index: index,
                            date: value[index].dateCreated,
                            username: value[index].owner!.username!,
                            thumbnail: value[index].owner!.profilePictureUrl!,
                            couponId: value[index].id!,
                            userSaved: value[index].userSaved,
                            couponTitle: value[index].title!,
                            couponCode: value[index].code!,
                            onLikeToggle: (bool _) {
                              // ref.invalidate(hottestCouponsProvider);
                            }),
                      );
                    }),
              );
            },
            loading: () {
              updateIsEmpty(false);
              return HorizontalCouponShimmer();
            },
            error: (error, stackTrace) {
              updateIsEmpty(true);

              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
