import 'package:flutter/widgets.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';

class ReviewsOutlinedButton extends StatelessWidget {
  const ReviewsOutlinedButton({
    super.key,
    required this.text,
    this.onTap,
    // this.loading =f
  });
  final String text;
  final VoidCallback? onTap;
  // final bool loading;```````````

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 25,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: context.appTheme.primaryColor,
              width: 1.2,
            )),
        alignment: Alignment.center,
        child: Text(
          text,
          style: context.appTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.appTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
