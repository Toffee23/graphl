import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HListBuilderViewAll extends ConsumerStatefulWidget {
  final String title;
  final VoidCallback? onViewAllTap;
  final String username;
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double? height;
  final EdgeInsetsGeometry titleViewAllPadding;
  final bool autoScroll;

  const HListBuilderViewAll({
    Key? key,
    required this.username,
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
    this.height,
    this.titleViewAllPadding = EdgeInsets.zero,
    this.onViewAllTap,
    this.autoScroll = true,
  }) : super(key: key);

  @override
  ConsumerState<HListBuilderViewAll> createState() => _ServiceSubListState();
}

class _ServiceSubListState extends ConsumerState<HListBuilderViewAll> {
  bool? isSaved;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final _currentUser = ref.watch(appUserProvider).valueOrNull;
    final _iscurrentUser = ref.read(appUserProvider.notifier).isCurrentUser(_currentUser?.username);
    return Column(
      children: [
        addVerticalSpacing(10),
        GestureDetector(
          onTap: () {
            widget.onViewAllTap?.call();
          },
          child: Padding(
            padding: widget.titleViewAllPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Text(
                //   "View all".toUpperCase(),
                //   style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                // ),
              ],
            ),
          ),
        ),
        addVerticalSpacing(9),
        if (widget.itemCount <= 0)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "No data for ${widget.title}",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(),
            ),
          ),
        if (widget.itemCount > 0)
          SizedBox(
            height: widget.height ?? 35.h,
            child: CarouselSlider.builder(
                // physics: BouncingScrollPhysics(),

                options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  enableInfiniteScroll: false,
                  autoPlay: widget.autoScroll,
                  enlargeCenterPage: false,
                  enlargeFactor: 0,
                  viewportFraction: 0.5,
                  autoPlayAnimationDuration: Duration(seconds: 20),
                  height: 28.h,
                  padEnds: false,
                  scrollPhysics: BouncingScrollPhysics(),
                ),
                itemCount: widget.itemCount,
                itemBuilder: (context, index, pageIndex) => widget.itemBuilder(context, index) ?? Container()),
          ),
        addVerticalSpacing(5),
      ],
    );
  }
}
