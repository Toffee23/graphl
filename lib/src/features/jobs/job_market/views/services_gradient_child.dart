import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/vmodel.dart';

class GradientChild extends StatelessWidget {
  const GradientChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore', //\nDiscounted\nServices',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
              ),
              addVerticalSpacing(4),
              Text(
                'Discounted',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
              ),
              addVerticalSpacing(4),
              Text(
                'Services',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
              ),
              addVerticalSpacing(4),
              Text(
                'Browse through discounted services experience quality services on a bargain.',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
              ),
            ],
          ),
        ),
        addHorizontalSpacing(8),
        RoundedSquareAvatar(
          url: VConstants.testImage,
          thumbnail: '',
          size: UploadAspectRatio.wide.sizeFromX(33.w),
        )
      ],
    );
  }
}
