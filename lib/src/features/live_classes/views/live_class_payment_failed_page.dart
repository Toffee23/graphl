import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class LiveClassPaymentErrorPage extends StatelessWidget {
  const LiveClassPaymentErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final elementColor = Colors.white;
    return Scaffold(
      backgroundColor: VmodelColors.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RenderSvgWithoutColor(
                svgPath: VIcons.emojiSad,
                color: elementColor,
                svgHeight: 48,
                svgWidth: 48,
              ),
              addVerticalSpacing(16),
              Text(
                'Oops!',
                style: context.textTheme.displayMedium?.copyWith(
                  fontSize: 17.sp,
                  color: elementColor,
                ),
              ),
              addVerticalSpacing(16),
              Text(
                "Sorry, we couldn't confirm your \npayment ",
                style: context.textTheme.displayMedium?.copyWith(
                  color: elementColor,
                ),
              ),
              addVerticalSpacing(16),
              VWidgetsPrimaryButton(
                butttonWidth: 30.w,
                buttonColor: elementColor,
                buttonTitleTextStyle: context.textTheme.displayMedium?.copyWith(
                  color: VmodelColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () {
                  goBack(context);
                },
                enableButton: true,
                buttonTitle: "Home",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
