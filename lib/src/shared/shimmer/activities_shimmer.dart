import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/res/gap.dart';

class ActivitiesShimmerPage extends StatelessWidget {
  final bool showTrailing;
  const ActivitiesShimmerPage({this.showTrailing = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Shimmer.fromColors(
      // baseColor: const Color(0xffD9D9D9),
      // highlightColor: const Color(0xffF0F1F5),
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalSpacing(18),
              Expanded(
                child: ListView.separated(
                    itemCount: 14,
                    separatorBuilder: (context, index) {
                      return addVerticalSpacing(16);
                    },
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF303030),
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                addVerticalSpacing(4),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          )),
    ));
  }
}

// jobShimmer(BuildContext context,
//     [double? paddingRight, double? paddingLeft, double? paddingBottom]) {
//   return Shimmer.fromColors(
//     // baseColor: const Color(0xffD9D9D9),
//     // highlightColor: const Color(0xffF0F1F5),
//     baseColor: Theme.of(context).colorScheme.surfaceVariant,
//     highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             addVerticalSpacing(18),
//             Container(
//               padding: const EdgeInsets.only(
//                 bottom: 15,
//               ),
//               height: MediaQuery.of(context).size.height * 0.1,
//               width: MediaQuery.of(context).size.width,
//               // padding: EdgeInsets.symmetric(vertical: 5),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF303030),
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                 ),
//                 child: Column(
//                   children: [Container()],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(itemBuilder: (context, index) {
//                 return Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.only(
//                         bottom: 10,
//                       ),
//                       height: MediaQuery.of(context).size.height * 0.15,
//                       width: MediaQuery.of(context).size.width,
//                       // padding: EdgeInsets.symmetric(vertical: 5),
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF303030),
//                           borderRadius: BorderRadius.all(Radius.circular(15)),
//                         ),
//                         child: Column(
//                           children: [Container()],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           ]),
//     ),
//   );
// }
