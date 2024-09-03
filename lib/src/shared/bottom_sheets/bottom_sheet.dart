import 'package:flutter/material.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

class VBottomSheetComponent {
  static Future<T?> actionBottomSheet<T>({
    required BuildContext context,
    required List<VBottomSheetItem> actions,
    VBottomSheetStyle? style,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      // sheetAnimationStyle: AnimationStyle(
      //   curve: Curves.elasticOut,
      //   duration: Duration(milliseconds: 600),
      // ),
      useRootNavigator: true,
      shape: style?.shape ??
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
      barrierColor: style?.barierColor,
      backgroundColor: style?.backgroundColor,
      builder: (context) => VBottomSheetWidget(
        actions: actions,
        style: style,
      ),
    );
  }

  static Future customBottomSheet({
    required BuildContext context,
    required Widget child,
    VBottomSheetStyle? style,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
  }) =>
      showModalBottomSheet(
        context: context,
        
        isScrollControlled: isScrollControlled,
        useRootNavigator: useRootNavigator,
        shape: style?.shape ??
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
        useSafeArea: true,
        barrierColor: style?.barierColor,
        backgroundColor: style?.backgroundColor,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VBottomSheetWidget(
              customChild: child,
              style: style,
            )
          ],
        ),
      );
}

class VBottomSheetWidget extends StatefulWidget {
  const VBottomSheetWidget({
    super.key,
    this.actions,
    this.customChild,
    required this.style,
  });
  final List<VBottomSheetItem>? actions;
  final Widget? customChild;
  final VBottomSheetStyle? style;

  @override
  State<VBottomSheetWidget> createState() => _VBottomSheetWidgetState();
}

class _VBottomSheetWidgetState extends State<VBottomSheetWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: ElasticOutCurve(0.95), // Curves.elasticOut,
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          widget.style?.contentPadding ?? EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          addVerticalSpacing(15),
          const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.actions != null) ...[
                    Flexible(
                      child: ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.actions!.length,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) => InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              overlayColor:
                                  WidgetStatePropertyAll(Colors.transparent),
                              onTap: widget.actions![index].onTap,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (widget.actions![index].icon !=
                                        null) ...[
                                      RenderSvg(
                                        svgPath: widget.actions![index].icon!,
                                        svgHeight: 24,
                                        svgWidth: 24,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      addHorizontalSpacing(16),
                                    ],
                                    Text(
                                      widget.actions![index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                    ),
                  ],
                  if (widget.customChild != null) ...[
                    widget.customChild!,
                  ]
                ],
              )
              // child: SizeTransition(
              //   sizeFactor: _animation,
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       if (widget.actions != null) ...[
              //         Flexible(
              //           child: ListView.separated(
              //             physics: NeverScrollableScrollPhysics(),
              //             itemCount: widget.actions!.length,
              //             shrinkWrap: true,
              //             itemBuilder: ((context, index) => InkWell(
              //                   highlightColor: Colors.transparent,
              //                   splashColor: Colors.transparent,
              //                   overlayColor:
              //                       WidgetStatePropertyAll(Colors.transparent),
              //                   onTap: widget.actions![index].onTap,
              //                   child: Padding(
              //                     padding:
              //                         const EdgeInsets.symmetric(vertical: 6.0),
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.start,
              //                       children: [
              //                         if (widget.actions![index].icon !=
              //                             null) ...[
              //                           RenderSvg(
              //                             svgPath: widget.actions![index].icon!,
              //                             svgHeight: 24,
              //                             svgWidth: 24,
              //                             color:
              //                                 Theme.of(context).iconTheme.color,
              //                           ),
              //                           addHorizontalSpacing(16),
              //                         ],
              //                         Text(
              //                           widget.actions![index].title,
              //                           style: Theme.of(context)
              //                               .textTheme
              //                               .displayLarge!
              //                               .copyWith(
              //                                 fontWeight: FontWeight.w600,
              //                                 color:
              //                                     Theme.of(context).primaryColor,
              //                                 fontSize: 16,
              //                               ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 )),
              //             separatorBuilder: (context, index) => const Divider(),
              //           ),
              //         ),
              //       ],
              //       if (widget.customChild != null) ...[
              //         widget.customChild!,
              //       ]
              //     ],
              //   ),
              // ),
              ),
        ],
      ),
    );
  }
}
