import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../res/gap.dart';

class ServiceSpotlightShimmer extends StatelessWidget {
  const ServiceSpotlightShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      child: Shimmer.fromColors(
          // baseColor: const Color(0xffD9D9D9),
          // highlightColor: const Color(0xffF0F1F5),
          baseColor: Theme.of(context).colorScheme.surfaceVariant,
          highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
          // baseColor: Colors.blue,
          // highlightColor: Colors.purple,
          child:
              // Container(  height: 33.h,
              // color: Color(0xFF303030),
              //  child: SizedBox(height: 24),
              // ),
              Card(
            // padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.1),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            // color: Colors.amber,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 40,
                      // width: SizerUtil.width * 0.40,
                      // margin: EdgeInsets.symmetric(horizontal: widget.isViewAll ? 0 : 5),
                      decoration: BoxDecoration(
                        color: Color(0xFF303030),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black38,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 1.0, left: 1),
                            child: Icon(
                              Icons.bookmark_added,
                              color: Color(0xFF303030),
                            )),
                      ),
                    )
                  ],
                ),
                addVerticalSpacing(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        width: SizerUtil.width * 0.42,
                      ),
                      addVerticalSpacing(5),
                      SizedBox(
                        width: SizerUtil.width * 0.42,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF303030),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                            ),
                            Row(
                              children: [
                                addHorizontalSpacing(8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      addVerticalSpacing(3),
                      SizedBox(
                        width: SizerUtil.width * 0.42,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xFF303030),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                              ),
                            ]),
                      ),
                      addVerticalSpacing(10),
                      // Spacer(),
                      SizedBox(
                        width: SizerUtil.width * 0.42,
                        child: Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              color: Color(0xFF303030),
                            ),
                            addHorizontalSpacing(3),
                            Spacer(),
                            Row(
                              children: [
                                Container(
                                  height: 12,
                                  width: 12,
                                  color: Color(0xFF303030),
                                ),
                                addHorizontalSpacing(5),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
