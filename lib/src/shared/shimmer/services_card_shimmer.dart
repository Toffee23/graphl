import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../res/gap.dart';

class ServiceCardShimmerPage extends StatelessWidget {
  final bool showTrailing;
  final bool showTitle;
  final bool showSearchShimmer;
  final int noOfAppBarTrailingBox;

  const ServiceCardShimmerPage(
      {this.showTrailing = true,
      super.key,
      this.showTitle = true,
      this.showSearchShimmer = true,
      this.noOfAppBarTrailingBox = 2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: showTitle
            ? VWidgetsAppBar(
                appbarTitle: '',
                titleWidget: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceVariant,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  child: Container(
                    height: 10,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                trailingIcon: [
                  if (showTrailing)
                    Shimmer.fromColors(
                        baseColor: Theme.of(context).colorScheme.surfaceVariant,
                        highlightColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          child: Row(
                              children:
                                  List.generate(noOfAppBarTrailingBox, (index) {
                            return Container(
                              height: 20,
                              width: 20,
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                            );
                          })),
                        )),
                ],
              )
            : null,
        body: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceVariant,
          highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  addVerticalSpacing(10),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 15,
                        ),
                        // height: MediaQuery.of(context).size.height * 0.1,
                        // width: MediaQuery.of(context).size.width,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        // padding: EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: 140,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF303030),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              )),
        ));
  }
}
