import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? appbarTitle;
  final Widget? leadingIcon;
  final List<Widget>? trailingIcon;
  final Color? backgroundColor;
  final double? appBarHeight;
  final double? leadingWidth;
  final TextStyle? style;
  final Widget? titleWidget;
  final Widget? optionalTitle;
  final double? elevation;
  final PreferredSize? customBottom;
  final bool? centerTitle;
  final ShapeBorder? shape;
  final bool? deep;
  final bool isFeedScreen;

  const VWidgetsAppBar({
    this.appbarTitle,
    this.centerTitle,
    this.deep,
    this.leadingIcon,
    this.titleWidget,
    this.trailingIcon,
    this.backgroundColor,
    this.appBarHeight,
    super.key,
    this.leadingWidth,
    this.style,
    this.elevation,
    this.shape,
    this.optionalTitle,
    this.customBottom,
    this.isFeedScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle ?? true,
      automaticallyImplyLeading: false,
      leading: leadingIcon,
      leadingWidth: leadingWidth,
      elevation: elevation ?? 0,
      toolbarHeight: appBarHeight,
      // backgroundColor: backgroundColor ?? VmodelColors.background,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      bottom: customBottom,
      shape: isFeedScreen
          ? Border(
              bottom: BorderSide(
                color: context.isDarkMode ? VmodelColors.navbarDarkColor : VmodelColors.navbarColor,
              ),
            )
          : null,
      title: titleWidget ??
          Text(
            appbarTitle!,
            style: style ??
                Theme.of(context).textTheme.displayLarge!.copyWith(
                      // color: VmodelColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
          ),

      actions: [...?trailingIcon],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? kToolbarHeight);
}
