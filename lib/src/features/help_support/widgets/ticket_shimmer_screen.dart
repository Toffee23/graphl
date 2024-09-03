import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class TicketShimmerPage extends StatelessWidget {
  const TicketShimmerPage(
      {super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: VWidgetsAppBar(
          appbarTitle: '',
          leadingIcon: Shimmer.fromColors(
            // baseColor: const Color(0xffD9D9D9),
            // highlightColor: const Color(0xffF0F1F5),
              baseColor: Theme.of(context).colorScheme.surfaceVariant,
              highlightColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: CircleAvatar(),
              )),
          titleWidget: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceVariant,
            highlightColor:
            Theme.of(context).colorScheme.onSurfaceVariant,
            child: Container(
              height: 20,
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
        body: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceVariant,
          highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  addVerticalSpacing(18),
                  Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 2,
                                  shadowColor: Theme.of(context).colorScheme.onBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(height: 40,),
                                        addVerticalSpacing(10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 7,
                                              child: Container(),
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 15,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      // color: Theme.of(context).colorScheme.onBackground,
                                        color: Theme.of(context).colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Container(),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )
                  ),
                ],
              )),
        ));
  }
}
