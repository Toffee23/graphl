import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';

/// [VCustomExpansionTileWidget] is widget that takes in a custom widget called [child] that can be expanded and retracted
///
/// [VCustomExpansionTileWidget] takes in [toggleValue] and callback function [onChanged] that returns the [toggleValue]
class VCustomExpansionTileWidget extends StatefulWidget {
  const VCustomExpansionTileWidget({
    super.key,
    required this.toggleValue,
    required this.title,
    required this.onChanged,
    required this.child,
    this.toogleIcon,
    this.customTitle,
    this.color,
  });

  /// By defaults this value is false
  final bool toggleValue;

  final String title;

  /// call back function toggling [toggleValue]
  final Function(bool value) onChanged;

  /// a custom child widget for the expansion tile
  final Widget child;

  ///a custom icon for action button
  final Widget? toogleIcon;

  /// custom title widget for tile
  final Widget? customTitle;

  /// custom bakground [color] for the [VCustomExpansionTileWidget] and its null by default value
  final Color? color;

  @override
  State<VCustomExpansionTileWidget> createState() =>
      _VCustomExpansionTileWidgetState();
}

class _VCustomExpansionTileWidgetState
    extends State<VCustomExpansionTileWidget> {
  late bool toggleValue = widget.toggleValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.color,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => toggleValue = !toggleValue);
              widget.onChanged(toggleValue);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.customTitle != null)
                  widget.customTitle!
                else
                  Text(
                    widget.title,
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                // widget.toogleIcon ??
                if (toggleValue)
                  Text(
                    'close',
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
          if (toggleValue) widget.child,
        ],
      ),
    );
  }
}

/// Custom child for [VCustomExpansionTileWidget]
/// you can use any other widget of choice but this is for a specific ui pattern
class VCustomExpansionTileChild extends StatelessWidget {
  const VCustomExpansionTileChild(
      {super.key, required this.title, required this.onTap, this.value});

  ///[title] for custom widget
  final String title;

  /// callback function to [onTap]
  final VoidCallback onTap;

  /// entered [value] for tile
  final String? value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black12,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            if (value == null) ...[
              Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.white,
              ),
              addHorizontalSpacing(10)
            ],
            Text(
              title,
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (value != null) ...[
              addHorizontalSpacing(10),
              Text(
                value!,
                style: context.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// [VServiceFeildValueContainer] shows the custom widget for entered feild value
class VServiceFeildValueContainer extends StatelessWidget {
  const VServiceFeildValueContainer(
      {super.key,
      required this.title,
      required this.subTitle,
      this.endText,
      this.onTap});

  /// [title] for feild
  final String title;

  /// [subTitle] for feild can also be the feild value
  final String subTitle;

  /// end item for the widget
  final String? endText;

  ///nullable [onTap] callback action
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.black12,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            addHorizontalSpacing(5),
            Text(
              subTitle,
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (endText != null) ...[
              Spacer(),
              Text(
                endText!,
                style: context.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
