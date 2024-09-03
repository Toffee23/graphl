import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/solid_circle.dart';

class TimelineItemTile extends StatelessWidget {
  const TimelineItemTile({
    super.key,
    required this.index,
    required this.title,
    required this.desc,
    required this.duration,
    this.isCompledOrActive = false,
    this.isLast = false,
    this.isNextStepActive = false,
  });

  final bool isLast;
  final bool isNextStepActive;
  final bool isCompledOrActive;
  final int index;
  final String title;
  final String desc;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        context.textTheme.displayMedium?.color?.withOpacity(0.5);

    final stepColor = Theme.of(context).colorScheme.onSurface;
    return Stack(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // decoration: BoxDecoration(
          //   border: Border(
          //     right: BorderSide(width: 0.5),
          //   ),
          // ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$index. ${title}',
                            style: context.textTheme.displayMedium?.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isCompledOrActive ? null : inactiveColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        addHorizontalSpacing(4),
                        Text(
                          '${VMString.bullet} ${duration}',
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textTheme.displayMedium?.color
                                ?.withOpacity(0.5),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  addHorizontalSpacing(32),
                  SolidCircle(
                      radius: 16,
                      //  color: Colors.red,
                      color:
                          //  Colors.white,
                          // Theme.of(context).iconTheme.color ??
                          isCompledOrActive
                              ? stepColor
                              : stepColor.withOpacity(0.3)
                      // Theme.of(context).colorScheme.onSurface
                      // ??
                      // Colors.transparent,
                      ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.only(right: 16),
                decoration: isLast
                    ? null
                    : BoxDecoration(
                        border: Border(
                          right: BorderSide(
                              width: 1,
                              color: isCompledOrActive && isNextStepActive
                                  ? stepColor
                                  : stepColor.withOpacity(0.3)),
                        ),
                      ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            desc,
                            style: context.textTheme.displayMedium?.copyWith(
                              fontSize: 11.sp,
                              color: isCompledOrActive ? null : inactiveColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(16)
                  ],
                ),
              ),
            ],
          ),
        ),
        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     SolidCircle(radius: 18, color: Colors.red),
        //     Container(
        //       width: 2.8,
        //       height: 50,
        //       // constraints: BoxConstraints(minHeight: ),
        //       color: Colors.blue,        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     SolidCircle(radius: 18, color: Colors.red),
        //     Container(
        //       width: 2.8,
        //       height: 50,
        //       // constraints: BoxConstraints(minHeight: ),
        //       color: Colors.blue,
        //     )
        //   ],
        // ),
        //     )
        //   ],
        // ),
      ],
    );
  }
}
