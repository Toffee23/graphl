import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/comment/create_new_board_dialogue.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../res/colors.dart';
import '../../../res/icons.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../../shared/switch/primary_switch.dart';

class VWidgetsCupertinoSwitchWithText2 extends StatelessWidget {
  final String? titleText;
  final bool? value;
  final VoidCallback? onTap;
  final Function(bool)? onChanged;
  final bool disabled;
  final String? subTitle;
  final String? trailingText;
  final double fontSize = 16;
  final TextStyle? textStyle;
  final double verticalPadding;
  final bool? addPadding;

  const VWidgetsCupertinoSwitchWithText2(
      {super.key,
      required this.titleText,
      required this.value,
      this.onTap,
      this.onChanged,
      this.trailingText,
      this.subTitle,
      this.textStyle,
      this.verticalPadding = 5,
      this.addPadding,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final color = disabled
        ? Theme.of(context).textTheme.displayMedium!.color?.withOpacity(0.2)
        : null;
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: (addPadding?? true)? !(trailingText != null &&
                                (subTitle ?? '').isNotEmpty)
                            ? EdgeInsets.only(bottom: 8)
                            : null: null,
                        child: Text(
                          titleText!,
                          style: textStyle ??
                              Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                      fontSize: fontSize),
                        ),
                      ),
                      if (trailingText != null && (subTitle ?? '').isNotEmpty)
                        Text(
                          subTitle ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(color: color, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if ((this.trailingText ?? '').isNotEmpty)
                      Text(
                        this.trailingText ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                                fontSize: fontSize),
                      ),
                    if (trailingText == null)
                      VWidgetsSwitch(swicthValue: value!, onChanged: onChanged)
                    else
                      Container(
                        margin: EdgeInsets.only(bottom: 6),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: color,
                          size: 15,
                        ),
                      )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
