import 'package:vmodel/src/features/dashboard/content/data/content_mock_data.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class StackedClassAttendeesAvatars extends StatelessWidget {
  const StackedClassAttendeesAvatars({
    super.key,
    required this.dataLength,
  });

  final int dataLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: List.generate(dataLength, (index) {
            return Container(
              height: 30,
              width: 30,
              margin: EdgeInsets.only(left: 8.0 * (dataLength - 1 - index)),
              child: ProfilePicture(
                showBorder: true,
                borderColor: Colors.white,
                borderWidth: 1,
                imageBorderPadding: EdgeInsets.zero,
                displayName: 'Janet Conner',
                url: liveImages[index],
                headshotThumbnail: liveImages[index],
                size: 30,
              ),
            );
          }),
        ),
        addHorizontalSpacing(4),
        Text(
          'Michael and 300 others joined',
          style: context.textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
