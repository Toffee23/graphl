import 'package:shimmer/shimmer.dart';

import '../../res/res.dart';
import '../../vmodel.dart';

class TopicShimmersPage extends StatelessWidget {
  const TopicShimmersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // baseColor: const Color(0xffD9D9D9),
      // highlightColor: const Color(0xffF0F1F5),
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      child: Row(
        children: [
          Container(
            height: 30,
            width: 35.w,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(44)),
            ),
          ),
          addHorizontalSpacing(4),
          Container(
            height: 30,
            width: 35.w,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(44)),
            ),
          ),
          // CircleAvatar(),
        ],
      ),
    );
  }
}
