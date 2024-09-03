import 'package:vmodel/src/vmodel.dart';


class RoundedSquareAvatarAsset extends StatelessWidget {
  final String? img;
  final Size? size;
  final double radius;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const RoundedSquareAvatarAsset({
    super.key,
    required this.img,
    this.size,
    this.radius = 8,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size?.width ?? 50,
      height: size?.height ?? 50,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
      ),
      child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          child: Image.asset(
            img.toString(),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          )),
    );
  }
}
