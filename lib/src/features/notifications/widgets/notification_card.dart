import 'package:cached_network_image/cached_network_image.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';

class VWidgetsNotificationCard extends StatelessWidget {
  final String? profileImageUrl;
  final String? notificationText;
  final String displayName;
  final String? date;
  final String? username;
  final bool checkProfilePicture;
  final VoidCallback onUserTapped;
  final String? profileRing;
  final bool isRead;
  final String? thumbnail;

  const VWidgetsNotificationCard({
    required this.profileImageUrl,
    required this.notificationText,
    required this.checkProfilePicture,
    required this.displayName,
    required this.date,
    this.username,
    required this.onUserTapped,
    this.profileRing,
    this.isRead = true,
    this.thumbnail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //print('[ososos $displayName $profileImageUrl');
    String getTruncatedText(String text, int maxLength) {
      if (text.length > maxLength) {
        return text.substring(0, maxLength) + "...";
      } else {
        return text;
      }
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.only(right: 8),
            color: isRead ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(),
                SizedBox(height: 8,),
                Row(
                  children: [
                    GestureDetector(
                      onTap: username != null && username == 'vmodel' ? null : onUserTapped,
                      child: Padding(
                        padding: const VWidgetsPagePadding.verticalSymmetric(1),
                        child: ProfilePicture(
                          url: profileImageUrl,
                          headshotThumbnail: profileImageUrl,
                          displayName: displayName,
                          size: 50,
                          showBorder: false,
                          profileRing: profileRing,
                        ),
                      ),
                    ),
                    addHorizontalSpacing(12),
                    Flexible(
                      child: GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text: "${notificationText!.split(" ").first}",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.sp,
                                          ),
                                    ),
                                    TextSpan(
                                      text: thumbnail != null ? "${getTruncatedText(notificationText!.replaceAll(notificationText!.split(" ").first, ""), 40)}" :
                                        "${notificationText!.replaceAll(notificationText!.split(" ").first, "")}",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10.sp,
                                          ),
                                    ),
                                     if (thumbnail != null)
                                    TextSpan(
                                      text: " "
                                    ),
                                   if (thumbnail != null)
                                    TextSpan(text: "• ", 
                                       style: VModelTypography1.normalTextStyle.copyWith(
                                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                    if (thumbnail != null)
                                    TextSpan(
                                       text: date,
                                      style: VModelTypography1.normalTextStyle.copyWith(
                                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 9.sp,
                                      ),
                                    )
                                    ]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // addHorizontalSpacing(5),
                            // if (thumbnail != null)
                            // Text(
                            //       date!,
                            //       style: VModelTypography1.normalTextStyle.copyWith(
                            //         color: Theme.of(context).primaryColor.withOpacity(0.4),
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 9.sp,
                            //       ),
                            //       maxLines: 1,
                            //     ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (thumbnail != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(imageUrl: thumbnail!, height: 50, width: 80, fit: BoxFit.cover),
                                  ),
                                 Row(
                                  children: [
                                    if (thumbnail == null)
                                   Text( "• ", 
                                       style: VModelTypography1.normalTextStyle.copyWith(
                                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                if (thumbnail == null)
                                Text(
                                  date!,
                                  style: VModelTypography1.normalTextStyle.copyWith(
                                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9.sp,
                                  ),
                                  maxLines: 1,
                                ),
                                  ],
                                 )
                              ],
                            ),
                              
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
