import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import 'live_avatar_class_tile.dart';

class TutorPrepCard extends StatelessWidget {
  final String classLevel;
  final String? profileImage;
  final String? title;
  final String? duration;
  final String? date;
  final String? lastItem;
  final String? candidateType;
  final VoidCallback onItemTap;

  const TutorPrepCard(
      {required this.profileImage,
      required this.title,
      required this.date,
      required this.duration,
      required this.lastItem,
      required this.candidateType,
      required this.classLevel,
      required this.onItemTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onItemTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              width: 0.5,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarClassTitleDateTile(
                  profileImage: profileImage,
                  title: title,
                  date: date,
                ),
                addVerticalSpacing(12),
                Row(
                  children: [
                    BulletText(text: '$duration'),
                    Expanded(child: SizedBox(width: 16)),
                    BulletText(text: '$classLevel'),
                    Expanded(child: SizedBox(width: 16)),
                    BulletText(text: '$lastItem'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
