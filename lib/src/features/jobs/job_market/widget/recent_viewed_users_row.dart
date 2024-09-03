import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class RecentViewedUsersSection extends ConsumerStatefulWidget {
  const RecentViewedUsersSection({
    super.key,
    required this.users,
    required this.title,
    required this.onViewAllTap,
    required this.onTap,
  });
  final String title;
  final List<VAppUser> users;
  final VoidCallback onViewAllTap;
  final Function(String username) onTap;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HorizontalCouponSectionState();
}

class _HorizontalCouponSectionState extends ConsumerState<RecentViewedUsersSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: context.textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(onTap: () => widget.onViewAllTap(), child: Icon(Icons.arrow_forward_rounded))
            ],
          ),
        ),
        Container(
          height: 80,
          margin: EdgeInsets.only(bottom: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: widget.users.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) {
              return addHorizontalSpacing(8);
            },
            itemBuilder: (context, index) {
              // if (index == widget.users.length && widget.users.length>10) {
              //   return Container(
              //     width: 45,
              //     height: 45,
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       color:
              //           Colors.primaries[index % Colors.primaries.length],
              //       borderRadius: BorderRadius.circular(10.0),
              //     ),
              //     child: Text(
              //       "VIEW MORE",
              //       style: Theme.of(context)
              //           .textTheme
              //           .bodySmall
              //           ?.copyWith(color: Colors.white),
              //     ),
              //   );
              // }

              return GestureDetector(
                onTap: () {
                  widget.onTap(widget.users[index].username);
                },
                child: UnconstrainedBox(
                  child: ProfilePicture(
                    url: widget.users[index].thumbnailUrl,
                    headshotThumbnail: widget.users[index].thumbnailUrl,
                    size: 60,
                    showBorder: true,
                    borderWidth: 1,
                    borderColor: VmodelColors.darkThemeCardColor,
                    profileRing: widget.users[index].profileRing,
                    //widget.postData?.postedBy.profileRing,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
