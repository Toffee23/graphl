import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class MarketPlaceGradientContainer extends StatelessWidget {
  const MarketPlaceGradientContainer({
    super.key,
    required this.child,
    this.height = 160,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 83.w,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            VmodelColors.gr2,
            VmodelColors.gr1,
            VmodelColors.gr0,
          ],
        ),
      ),
      child: child,
    );
  }
}
