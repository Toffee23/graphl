import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../core/controller/discard_editing_controller.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/switch/primary_switch.dart';
import '../widgets/timeline_form_widget.dart';

class TimelineFormListview extends ConsumerStatefulWidget {
  const TimelineFormListview({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TimelineFormListviewState();
}

class _TimelineFormListviewState extends ConsumerState<TimelineFormListview> {
  List<Widget> timelineFormWidgets = [];
  bool _timelineEnabled = false;

  @override
  Widget build(BuildContext context) {
    // if (timelineFormWidgets.isEmpty)

    if (!_timelineEnabled)
      return GestureDetector(
        onTap: () {
          VMHapticsFeedback.lightImpact();
          _timelineEnabled = true;

          timelineFormWidgets.add(TimelineForm(
            index: timelineFormWidgets.length + 1,
            answerController: TextEditingController(),
            questionController: TextEditingController(),
            onRemove: () {
              // timelineFormWidgets.removeAt(index);
              setState(() {});
            },
          ));
          ref
              .read(discardProvider.notifier)
              .updateState('isFaq', newValue: _timelineEnabled);
          setState(() {});
        },
        child: Container(
          // margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).buttonTheme.colorScheme!.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Add a Timeline",
                    style: context.textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(10),
              Text(
                "Elevate your lives by showing your fans step by step progression when you go live.",
                style:
                    context.textTheme.displaySmall!.copyWith(fontSize: 11.sp),
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    if (_timelineEnabled)
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  "Timeline",
                  style: VModelTypography1.promptTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              VWidgetsSwitch(
                swicthValue: _timelineEnabled,
                onChanged: (value) {
                  _timelineEnabled = value;

                  ref
                      .read(discardProvider.notifier)
                      .updateState('isFaq', newValue: _timelineEnabled);

                  setState(() {});
                  // WidgetsBinding.instance
                  //     .addPostFrameCallback((timeStamp) {
                  //   _scrollController.animateTo(
                  //       _scrollController.position.maxScrollExtent,
                  //       duration: const Duration(milliseconds: 200),
                  //       curve: Curves.fastEaseInToSlowEaseOut);
                  // });
                },
              )
            ],
          ),
          if (_timelineEnabled)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: 5),
                  itemCount: timelineFormWidgets.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              timelineFormWidgets[index],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                VWidgetsPrimaryButton(
                  onPressed: () {
                    var anserController = TextEditingController();
                    var questionController = TextEditingController();
                    // anserControllers.add(anserController);
                    // questionControllers.add(questionController);
                    timelineFormWidgets.add(TimelineForm(
                      index: timelineFormWidgets.length + 1,
                      answerController: anserController,
                      questionController: questionController,
                      onRemove: () {
                        // timelineFormWidgets.removeAt(index);
                        setState(() {});
                      },
                    ));
                    setState(() {});
                  },
                  buttonTitle: "Add New",
                  buttonTitleTextStyle:
                      Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: Theme.of(context).iconTheme.color,
                            fontWeight: FontWeight.w600,
                            // fontSize: 12.sp,
                          ),
                  buttonColor:
                      Theme.of(context).buttonTheme.colorScheme!.secondary,
                ),
              ],
            ),
        ],
      );
    return SizedBox.shrink();
  }
}
