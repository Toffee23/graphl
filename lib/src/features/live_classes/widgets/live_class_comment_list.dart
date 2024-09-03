import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../dashboard/content/data/content_mock_data.dart';

class ClassCommentsList extends StatelessWidget {
  const ClassCommentsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.6),
          Colors.white,
          Colors.white,
        ],
      ).createShader(bounds),
      child: ListView.separated(
          itemCount: 9,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          separatorBuilder: (context, index) {
            return addVerticalSpacing(8);
          },
          itemBuilder: (context, index) {
            return Row(
              children: [
                ProfilePicture(
                  // borderColor: Colors.white,
                  showBorder: true,
                  borderColor: Colors.white,
                  borderWidth: 1,
                  imageBorderPadding: EdgeInsets.zero,
                  displayName: 'Janet Conner',
                  url: liveImages[index],
                  headshotThumbnail: liveImages[index],
                  size: 30,
                ),
                addHorizontalSpacing(8),
                Text(
                  'Janet Joined',
                  style: context.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                )
              ],
            );
          }),
    );
  }
}
