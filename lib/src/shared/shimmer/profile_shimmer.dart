import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/res/gap.dart';

profileShimmer(BuildContext context,
    [double? paddingRight, double? paddingLeft, double? paddingBottom]) {
  return Shimmer.fromColors(
    // baseColor: const Color(0xffD9D9D9),
    // highlightColor: const Color(0xffF0F1F5),
    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          addVerticalSpacing(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 25,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: const BoxDecoration(
                  // color: Color(0xFF303030),
                  color: Colors.amber,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ],
          ),
          addVerticalSpacing(32),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          bottom: paddingBottom ??= 10, left: 18),
                      height: 85,
                      width: 85,
                      decoration: const BoxDecoration(
                        color: Color(0xFF303030),
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      // padding: EdgeInsets.symmetric(vertical: 5),
                    ),
                    addHorizontalSpacing(15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10, left: 18),
                          height: 25,
                          width: 230,
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),

                          // padding: EdgeInsets.symmetric(vertical: 5),
                        ),
                        addVerticalSpacing(3),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10, left: 18),
                          height: 25,
                          width: 220,
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),

                          // padding: EdgeInsets.symmetric(vertical: 5),
                        ),
                        addVerticalSpacing(3),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10, left: 18),
                          height: 25,
                          width: 220,
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),

                          // padding: EdgeInsets.symmetric(vertical: 5),
                        ),

                        //      Row(
                        //       mainAxisAlignment: MainAxisAlignment.end,
                        //       children: [
                        //         Container(

                        //   height: 25,
                        //   width: 25,
                        //   decoration: const BoxDecoration(
                        //         color: Color(0xFF303030),
                        //         borderRadius: BorderRadius.all(Radius.circular(100)),
                        //   ),
                        //   // padding: EdgeInsets.symmetric(vertical: 5),
                        // ),
                        //       ],
                        //     ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          addVerticalSpacing(12),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Container(
              height: 25,
              width: MediaQuery.of(context).size.width / 1.1,
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                children: [Container()],
              ),
            ),
          ),
          addVerticalSpacing(12),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(15),
                Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [Container()],
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpacing(2),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(15),
                Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [Container()],
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpacing(2),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(15),
                Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [Container()],
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpacing(12),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2.3,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2.3,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
              ],
            ),
          ),
          addVerticalSpacing(6),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    height: 40,

                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
                addHorizontalSpacing(4),
                Flexible(
                  child: Container(
                    height: 40,

                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
                addHorizontalSpacing(4),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                addHorizontalSpacing(4),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
              ],
            ),
          ),
          addVerticalSpacing(12),
          Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Container(
                  height: 30,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Container(
                  height: 30,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  // padding: EdgeInsets.symmetric(vertical: 5),
                ),
              ],
            ),
          ),
          addVerticalSpacing(4),
          Container(
            height: 2,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            // padding: EdgeInsets.symmetric(vertical: 5),
          ),
          addVerticalSpacing(6),
          Row(
            children: [
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
              addHorizontalSpacing(2),
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
              addHorizontalSpacing(2),
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
            ],
          ),
          addVerticalSpacing(2),
          Row(
            children: [
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
              addHorizontalSpacing(2),
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
              addHorizontalSpacing(2),
              Flexible(
                child: Container(
                  height: 202,
                  decoration: const BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
            ],
          ),
        ]),
  );
}
