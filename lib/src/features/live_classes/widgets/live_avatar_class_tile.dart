import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/vmodel.dart';

class AvatarClassTitleDateTile extends StatelessWidget {
  const AvatarClassTitleDateTile({
    super.key,
    required this.profileImage,
    required this.title,
    required this.date,
  });

  final String? profileImage;
  final String? title;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final colorWithOpacity =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RoundedSquareAvatar(
          url: profileImage,
          thumbnail: profileImage,
          radius: 400,
        ),
        addHorizontalSpacing(10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title!, // e.msg.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                )),
                  ),
                ],
              ),
              // addVerticalSpacing(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${date}',
                      // location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall //!
                          ?.copyWith(fontSize: 11.sp, color: colorWithOpacity),
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

class BulletText extends StatelessWidget {
  const BulletText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${VMString.bullet} $text', // e.msg.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}
