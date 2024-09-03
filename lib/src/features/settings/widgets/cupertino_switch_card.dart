import 'package:vmodel/src/vmodel.dart';

import '../../../shared/switch/primary_switch.dart';

class VWidgetsCupertinoSwitchWithText extends StatelessWidget {
  final String? titleText;
  final TextStyle? textStyle;
  final bool? value;
  final Function(bool)? onChanged;

  const VWidgetsCupertinoSwitchWithText(
      {super.key,
      required this.titleText,
      required this.onChanged,
      required this.value,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            titleText!,
            style: textStyle ??
                Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
          ),
        ),
        VWidgetsSwitch(swicthValue: value!, onChanged: onChanged),
      ],
    );
  }
}
