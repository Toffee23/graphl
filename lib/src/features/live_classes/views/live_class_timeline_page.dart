import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/dashboard/content/data/content_mock_data.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/solid_circle.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../widgets/prep_top_card.dart';
import '../widgets/timeline_tile.dart';

class LiveClassTimelinePage extends ConsumerStatefulWidget {
  static const routeName = 'liveClassTimelinePage';

  const LiveClassTimelinePage({
    Key? key,
    this.onItemTap,
  }) : super(key: key);
  final ValueChanged? onItemTap;

  @override
  ConsumerState<LiveClassTimelinePage> createState() => _LiveClassTimelinePageState();
}

class _LiveClassTimelinePageState extends ConsumerState<LiveClassTimelinePage> {
  final index = 1;
  // @override
  // initState() {
  //   super.initState();

  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        // backgroundColor: Colors.white,
        // appbarTitle: 'Timeline',
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SolidCircle(radius: 8, color: Colors.green),
            addHorizontalSpacing(4),
            Flexible(
              child: Text(
                'Timeline',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailingIcon: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            addVerticalSpacing(32),
            TutorPrepCard(
              title: 'Jollof rice class by Janet Douglas',
              profileImage: VConstants.testPetImage,
              duration: '110 mins',
              date: 'Monday, 22nd January 2024, 7pm',
              lastItem: 'Prep Incl.',
              candidateType: 'owowo',
              classLevel: 'Intermediate',
              onItemTap: () {},
            ),
            addVerticalSpacing(16),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: mockTimeline.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 90.w,
                            child: TimelineItemTile(
                              index: index + 1,
                              title: mockTimeline[index]['title'] ?? '',
                              desc: mockTimeline[index]['desc'] ?? '',
                              duration: mockTimeline[index]['dur'] ?? '',
                              isCompledOrActive: index < 4, //hardcoded for demo
                              isLast: index == mockTimeline.length - 1,
                              isNextStepActive: index < 3, //hardcoded for demo
                            ),
                          );
                        }),
                    addVerticalSpacing(16),
                    VWidgetsPrimaryButton(
                      onPressed: () {
                        // context.push('/live_class_prep_page',extra: widget.liveClass);
                        // navigateToRoute(context, LiveClassPrepPage());
                      },
                      buttonTitle: "How to prepare",
                    ),
                    addVerticalSpacing(8),
                    VWidgetsPrimaryButton(
                      onPressed: () {},
                      enableButton: true,
                      buttonTitle: "Book now",
                    ),
                  ],
                ),
              ),
            ),
            addVerticalSpacing(42),
          ],
        ),
      ),
    );
  }
}
