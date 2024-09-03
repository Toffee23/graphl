import 'package:vmodel/src/vmodel.dart';

import '../../res/res.dart';

class VWidgetsAddImageWidget extends StatelessWidget {
  final Size size;
  final double radius;
  final Widget? imageWidget;
  final VoidCallback? onTap;

  const VWidgetsAddImageWidget({
    super.key,
    this.size = const Size(100, 142),
    this.radius = 8,
    this.imageWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade300,
      ),
      child: TextButton(
        onPressed: () async {
          onTap?.call();
        },
        style: TextButton.styleFrom(
          backgroundColor: VmodelColors.vModelprimarySwatch.withOpacity(0.3),
          shape: const CircleBorder(),
          maximumSize: const Size(64, 36),
        ),
        child: Icon(Icons.add, color: VmodelColors.white),
      ),
    );
  }
}
