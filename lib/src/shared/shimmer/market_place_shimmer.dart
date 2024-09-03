import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../res/gap.dart';

class MarketPlaceShimmer extends StatelessWidget {
  const MarketPlaceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: VWidgetsAppBar(
          appbarTitle: '',
          // leadingIcon: Shimmer.fromColors(
          //     // baseColor: const Color(0xffD9D9D9),
          //     // highlightColor: const Color(0xffF0F1F5),
          //     baseColor: Theme.of(context).colorScheme.surfaceVariant,
          //     highlightColor:
          //         Theme.of(context).colorScheme.onSurfaceVariant,
          //     child: const Padding(
          //       padding: EdgeInsets.all(9),
          //       child: CircleAvatar(),
          //     )),
          centerTitle: false,
          titleWidget: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceVariant,
            highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
            child: Container(
              height: 20,
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          trailingIcon: [
            Shimmer.fromColors(baseColor: Theme.of(context).colorScheme.surfaceVariant, highlightColor: Theme.of(context).colorScheme.onSurfaceVariant, child: const CircleAvatar()),
            SizedBox(
              width: 15,
            )
          ],
        ),
        body: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceVariant,
          highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpacing(18),
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surfaceVariant,
                      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      child: Container(
                        height: 35,
                        width: MediaQuery.sizeOf(context).width / 0.95,
                        decoration: const BoxDecoration(
                          color: Color(0xFF303030),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                    addVerticalSpacing(20),
                    Container(
                      height: 15,
                      width: 150,
                      decoration: const BoxDecoration(
                        color: Color(0xFF303030),
                        borderRadius: BorderRadius.all(Radius.circular(4.5)),
                      ),
                    ),
                    addVerticalSpacing(10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        ),
                        addHorizontalSpacing(10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    addVerticalSpacing(20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        ),
                        addHorizontalSpacing(10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    addVerticalSpacing(15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 15,
                          width: 150,
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(4.5)),
                          ),
                        ),
                        Container(
                          height: 15,
                          width: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(4.5)),
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        ),
                        addHorizontalSpacing(10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 200,
                            width: SizerUtil.width * 0.40,
                            // width: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // if(showSearchShimmer)
                    // Container(
                    //   padding: const EdgeInsets.only(
                    //     bottom: 15,
                    //   ),
                    //   height: MediaQuery.of(context).size.height * 0.1,
                    //   width: MediaQuery.of(context).size.width,
                    //   // padding: EdgeInsets.symmetric(vertical: 5),
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       color: Color(0xFF303030),
                    //       borderRadius: BorderRadius.all(Radius.circular(15)),
                    //     ),
                    //     child: Column(
                    //       children: [Container()],
                    //     ),
                    //   ),
                    // ),
                    // Expanded(
                    //     child: GridView.builder(
                    //   itemCount: 10,
                    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2,
                    //     crossAxisSpacing: 10,
                    //     mainAxisSpacing: 8,
                    //     childAspectRatio: 1,
                    //   ),
                    //   itemBuilder: (BuildContext context, int index) {
                    //     return Container(
                    //       padding: const EdgeInsets.only(
                    //         bottom: 10,
                    //       ),
                    //       height: 150,
                    //       width: SizerUtil.width * 0.40,
                    //       // width: MediaQuery.of(context).size.width,
                    //       // padding: EdgeInsets.symmetric(vertical: 5),
                    //       child: Container(
                    //         decoration: const BoxDecoration(
                    //           color: Color(0xFF303030),
                    //           borderRadius: BorderRadius.all(Radius.circular(15)),
                    //         ),
                    //         child: Column(
                    //           children: [Container()],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // )

                    //     // ListView.builder(
                    //     //     itemCount: 10,
                    //     //     itemBuilder: (context, index) {
                    //     //       return Column(
                    //     //         children: [
                    //     //           Container(
                    //     //             padding: const EdgeInsets.only(
                    //     //               bottom: 10,
                    //     //             ),
                    //     //             height:
                    //     //                 MediaQuery.of(context).size.height * 0.15,
                    //     //             width: MediaQuery.of(context).size.width,
                    //     //             // padding: EdgeInsets.symmetric(vertical: 5),
                    //     //             child: Container(
                    //     //               decoration: const BoxDecoration(
                    //     //                 color: Color(0xFF303030),
                    //     //                 borderRadius:
                    //     //                     BorderRadius.all(Radius.circular(15)),
                    //     //               ),
                    //     //               child: Column(
                    //     //                 children: [Container()],
                    //     //               ),
                    //     //             ),
                    //     //           ),
                    //     //         ],
                    //     //       );
                    //     //     }),
                    //     ),
                  ],
                ),
              )),
        ));
  }
}
