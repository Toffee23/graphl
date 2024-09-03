import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/DateTime.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../model/live_class_type.dart';
import '../widgets/prep_top_card.dart';

class LiveClassPrepPage extends ConsumerStatefulWidget {
  static const routeName = 'liveClassPrepPage';

  const LiveClassPrepPage({
    Key? key,
    this.onItemTap,
    required this.liveClass,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  final LiveClassesInput liveClass;

  @override
  ConsumerState<LiveClassPrepPage> createState() => _LiveClassPrepPageState();
}

class _LiveClassPrepPageState extends ConsumerState<LiveClassPrepPage> {
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
        appbarTitle: 'Preparation',
        trailingIcon: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            addVerticalSpacing(32),
            TutorPrepCard(
              title: widget.liveClass.title,
              profileImage: widget.liveClass.ownersProfilePicture,
              duration: '${widget.liveClass.duration} mins',
              date: formatTime(widget.liveClass.startTime),
              lastItem: 'Prep Incl.',
              candidateType: 'owowo',
              classLevel: widget.liveClass.classDifficulty.name,
              onItemTap: () {},
            ),
            addVerticalSpacing(16),
            Card(
              // decoration: BoxDecoration(
              //   color: Theme.of(context).cardColor,
              // ),

              // color: (Theme.of(context).brightness == Brightness.dark) ,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preparation:',
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    addVerticalSpacing(16),
                    Text(
                      widget.liveClass.preparation!,
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontSize: 11.sp,
                            height: 1.5,
                          ),
                    ),
                    addVerticalSpacing(16),
                    VWidgetsPrimaryButton(
                      // butttonWidth: 30.w,
                      onPressed: () {
                        // navigateToRoute(context, LiveClassPaymentErrorPage());
                        // navigateToRoute(context, LiveClassPaymentSuccessPage());
                        // navigateToRoute(context, UpcomingClassesPage());
                      },
                      enableButton: true,
                      buttonTitle: "Book now",
                    ),
                  ],
                ),
              ),
            ),
            addVerticalSpacing(16),
          ],
        ),
      ),
    );
  }
}
