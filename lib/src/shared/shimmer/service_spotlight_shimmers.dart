import 'package:shimmer/shimmer.dart';

import '../../res/res.dart';
import '../../vmodel.dart';

///Discver service spotlight shimmers
class ServiceSpotlightShimmers extends StatelessWidget {
  const ServiceSpotlightShimmers({super.key});

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
            height: 145,
            width: 35.w,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          addHorizontalSpacing(4),
          Container(
            height: 145,
            width: 35.w,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          // CircleAvatar(),
        ],
      ),
    );
  }
}