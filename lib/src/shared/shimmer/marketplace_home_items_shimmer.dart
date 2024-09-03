import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../res/gap.dart';

class MarketplaceHomeItemsShimmerPage extends StatelessWidget {
  final bool showTrailing;
  final bool showTitle;
  const MarketplaceHomeItemsShimmerPage(
      {this.showTrailing = true, super.key, this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
        child: Column(
          children: [
           
            addVerticalSpacing(10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 200,
                width : double.infinity - 30,
                child: ListView.builder(
                  
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 115,
                            width : double.infinity - 30,
                          
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Column(
                                children: [Container()],
                              ),
                            ),
                          ),
                        
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
