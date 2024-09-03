import 'package:shimmer/shimmer.dart';

import '../../res/res.dart';
import '../../vmodel.dart';


///Discver popular videos shimmers
class PopularVideoShimmer extends StatelessWidget {
  const PopularVideoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
    // baseColor: const Color(0xffD9D9D9),
    // highlightColor: const Color(0xffF0F1F5),
    baseColor: Theme.of(context).colorScheme.surfaceVariant,
    highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // addVerticalSpacing(20),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(4),
                Container(
                  height: 40,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(4),
                Flexible(
                  child: Container(
                    height: 40,
                    width: 1100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
                addHorizontalSpacing(4),
              ],
            ),
          ),
          addVerticalSpacing(6),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(4),
                Container(
                  height: 40,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(4),
                Flexible(
                  child: Container(
                    height: 40,
                    width: 1100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
                addHorizontalSpacing(4),
              ],
            ),
          ),
          addVerticalSpacing(16),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    height: 202,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                addHorizontalSpacing(5),
                Flexible(
                  child: Container(
                    height: 202,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpacing(12),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    height: 202,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                addHorizontalSpacing(5),
                Flexible(
                  child: Container(
                    height: 202,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpacing(12),
          Container(
            height: 130,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
          addVerticalSpacing(12),
         ]),
  );
  }
}
