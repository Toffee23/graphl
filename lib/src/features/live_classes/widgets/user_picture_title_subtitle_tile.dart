import 'package:vmodel/src/vmodel.dart';

import '../../../res/res.dart';
import '../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';

class ContentUserLocation extends StatelessWidget {
  const ContentUserLocation({
    super.key,
    this.topText,
    this.bottomText,
    this.topWidget,
    this.bottomWidget,
    this.displayName,
    this.profilePicture,
  });

  final String? topText;
  final String? profilePicture;
  final String? displayName;
  final String? bottomText;
  final Widget? topWidget;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.displaySmall;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                // navigateToRoute(
                //   context,
                //   OtherProfileRouter(
                //     username: "${widget.service.user?.username}",
                //   ),
                // );
              },
              child: ProfilePicture(
                showBorder: false,
                displayName: displayName,
                url: profilePicture,
                headshotThumbnail: profilePicture,
                size: 46,
              ),
            ),
          ],
        ),
        addHorizontalSpacing(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              topWidget ??
                  GestureDetector(
                    onTap: () {
                      // navigateToRoute(
                      //     context, OtherUserProfile(username: ""));
                    },
                    child: topText == null
                        ? SizedBox.shrink()
                        : Text(
                            topText!,
                            style: textTheme?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.2.sp,
                              // color: VmodelColors.primaryColor,
                            ),
                          ),
                  ),
              addVerticalSpacing(4),
              bottomWidget ??
                  Row(
                    children: [
                      Text(
                        bottomText ?? '',
                        style: textTheme?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: textTheme.color?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
