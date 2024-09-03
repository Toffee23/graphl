import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/splash/views/new_splash.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsBackButton extends StatelessWidget {
  final Color? buttonColor;
  final Function? onTap;
  final Function? onLongPress;
  final bool? deep;
  final double? size;
  const VWidgetsBackButton({
    super.key,
    this.buttonColor,
    this.deep,
    this.onTap,
    this.onLongPress,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (deep == true) {
          context.go('/auth_widget');
        } else {
          onTap == null ? Router.neglect(context, () => context.pop('/login_screen')) : onTap!();
        }
      },
      onLongPress: () {
        if (onLongPress != null) onLongPress!();
      },
      child: InkWell(
        onTap: () {
          if (deep == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NewSplash()),
            );
          } else {
            onTap == null ? Router.neglect(context, () => context.pop('/login_screen')) : onTap!();
          }
        },
        child:
            // RotatedBox(
            // quarterTurns: 2,
            // child:
            SvgPicture.asset(
          VIcons.forwardIcon,
          width: size ?? 13,
          height: size ?? 13,
          fit: BoxFit.scaleDown,
          color: buttonColor ?? Theme.of(context).iconTheme.color,
        ),
        // ),
      ),
    );
  }
}
