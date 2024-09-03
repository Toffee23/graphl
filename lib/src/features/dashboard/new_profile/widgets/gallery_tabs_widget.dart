import '../../../../vmodel.dart';

class GalleryTabs extends StatelessWidget {
  const GalleryTabs({super.key, required this.tabs});
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final isScrollable = tabs.length > 1;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        width: double.infinity,
        // width: tabs.length > 1 ? double.infinity : MediaQuery.of(context).size.width / 3,
        child: TabBar(
          labelColor: Theme.of(context).tabBarTheme.labelColor,
          labelStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor.withOpacity(1),
              ),
          // labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor:
              Theme.of(context).tabBarTheme.unselectedLabelColor,
          unselectedLabelStyle: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          indicatorPadding: EdgeInsets.only(bottom: 0),
          indicator: CustomTabIndicator(
              color: Theme.of(context).indicatorColor, indicatorHeight: 1.5),
          // indicatorColor: Theme.of(context).indicatorColor,
          // indicatorSize: TabBarIndicatorSize.tab,
          isScrollable:
              true, // Setting isScrollable based on the number of tabs removing the grey color
          tabs: tabs,
          // tabAlignment: TabAlignment.center,
        ),
      ),
    );
  }
}

class CustomTabIndicator extends Decoration {
  final double indicatorHeight;
  final Color color;

  CustomTabIndicator({required this.indicatorHeight, required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
        indicatorHeight: indicatorHeight, color: color);
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final double indicatorHeight;
  final Color color;

  _CustomTabIndicatorPainter(
      {required this.indicatorHeight, required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;

    final double xPos = offset.dx;
    final double yPos = configuration.size!.height - indicatorHeight;
    final double width = configuration.size!.width;

    final Rect rect = Rect.fromLTWH(xPos, yPos, width, indicatorHeight);
    canvas.drawRect(rect, paint);
  }
}
