import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../model/live_class_type.dart';


class LiveClassPaymentSuccessPage extends StatelessWidget {
  LiveClassPaymentSuccessPage({
    required this.liveClass,
});
  final LiveClassesInput liveClass;

  @override
  Widget build(BuildContext context) {
    final elementColor = Colors.white;
    return Scaffold(
      backgroundColor: context.theme.primaryColor,
      body: Stack(
        children: [
          RoundedSquareAvatar(
            url: VConstants.testImage,
            thumbnail: '',
            radius: 0,
            size: Size(100.w, 100.h),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: kCupertinoModalBarrierColor,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Success!',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          color: elementColor,
                        ),
                      ),
                      addVerticalSpacing(16),
                      Text(
                        "You booking has been completed!",
                        style: context.textTheme.displayMedium?.copyWith(
                          color: elementColor,
                        ),
                      ),
                      addVerticalSpacing(16),
                      VWidgetsPrimaryButton(
                        butttonWidth: 30.w,
                        buttonColor: elementColor,
                        buttonTitleTextStyle:
                            context.textTheme.displayMedium?.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                            ..pop()
                            ..pop()
                            ..pop()
                            ..pop();
                        },
                        enableButton: true,
                        buttonTitle: "Done",
                      ),
                      addVerticalSpacing(16),
                      VWidgetsPrimaryButton(
                        butttonWidth: 30.w,
                        buttonColor: elementColor,
                        buttonTitleTextStyle:
                            context.textTheme.displayMedium?.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () {
                          context.push('/live_class_video_page');
                        },
                        enableButton: true,
                        buttonTitle: "Continue to class",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
