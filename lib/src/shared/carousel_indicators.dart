import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../vmodel.dart';

class VWidgetsCarouselIndicator extends StatelessWidget {
  const VWidgetsCarouselIndicator({
    Key? key,
    required this.currentIndex,
    required this.totalIndicators,
    this.dotsHeight = 5.95,
    this.dotsWidth = 5.92,
    this.margin = const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.525),
    this.padding,
    this.activeStrokeWidth = 2.6,
    this.activeDotScale = 1.3,
    this.maxVisibleDots = 5,
    this.radius = 8,
    this.spacing = 10,
    this.width,
  }) : super(key: key);

  final double? width;
  final int currentIndex;
  final int totalIndicators;
  final double dotsHeight;
  final double dotsWidth;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final double activeStrokeWidth;
  final double activeDotScale;
  final int maxVisibleDots;
  final double radius;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: margin,
      padding: padding,
      width: width,
      // color: Colors.red,
      child: AnimatedSmoothIndicator(
        // controller: pgController,
        activeIndex: currentIndex,
        count: totalIndicators,
        effect: ScrollingDotsEffect(
          activeStrokeWidth: activeStrokeWidth,
          activeDotScale: activeDotScale,
          maxVisibleDots: maxVisibleDots,
          radius: radius,
          spacing: spacing,
          dotHeight: dotsHeight,
          dotWidth: dotsWidth,
          dotColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          activeDotColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
    // return Wrap(
    //   // mainAxisAlignment: MainAxisAlignment.center,
    //   alignment: WrapAlignment.center,
    //   children: List.generate(totalIndicators, (index) {
    //     return Container(
    //       width: width,
    //       height: height,
    //       margin: margin,
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         // color: VmodelColors.primaryColor
    //         // color: Colors.pink
    //         color: Theme.of(context)
    //             .colorScheme
    //             .onSurface
    //             .withOpacity(currentIndex == index ? 1 : 0.2),
    //       ),
    //     );
    //   }).toList(),
    // );
  }
}
