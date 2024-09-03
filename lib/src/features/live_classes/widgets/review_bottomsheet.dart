import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/modal_pill_widget.dart';

class ClassReviewBottomSheet extends ConsumerStatefulWidget {
  const ClassReviewBottomSheet({
    Key? key,
    this.onItemTap,
    this.bottomInsetPadding = 15,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  final double bottomInsetPadding;

  @override
  ConsumerState<ClassReviewBottomSheet> createState() =>
      _ClassReviewBottomSheetState();
}

class _ClassReviewBottomSheetState
    extends ConsumerState<ClassReviewBottomSheet> {
  late final TextEditingController controller;
  final maxReviewLength = 500;
  int rating = 0;

  final ratingText = [
    'Negative Rating',
    'Negative Rating',
    'Average Rating',
    'Positive Rating',
    'Positive Rating',
  ];
  @override
  initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final coloWithOpacity =
        Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        // bottom: VConstants.bottomPaddingForBottomSheets,
        bottom: widget.bottomInsetPadding,
      ),
      constraints: BoxConstraints(
        maxHeight: SizerUtil.height * 0.95,
        minHeight: SizerUtil.height * 0.2,
        minWidth: SizerUtil.width,
      ),
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            addVerticalSpacing(15),
            const Align(
                alignment: Alignment.center, child: VWidgetsModalPill()),
            addVerticalSpacing(25),
            Text(
              "Tell us what you think of this live.",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            addVerticalSpacing(16),
            Text("Write a feedback"),
            addVerticalSpacing(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () {
                    setState(() {
                      rating = index;
                    });
                  },
                  icon: RenderSvg(
                    svgPath: index <= rating
                        ? VIcons.bookingRoundedFilledStar
                        : VIcons.bookingRoundedOutlineStar,
                  ),
                ),
              ),
            ),
            addVerticalSpacing(8),
            Text(
              "${ratingText[rating]}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontSize: 11.sp, color: coloWithOpacity),
            ),
            addVerticalSpacing(16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    maxLength: maxReviewLength,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Write a review...',
                      border: InputBorder.none,
                      // errorText: 'Hello',
                      counterText: '',
                      hintStyle:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontSize: 11.sp,
                                color: Theme.of(context).hintColor,
                              ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${maxReviewLength - controller.text.length} characters remaining",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      VWidgetsTextButton(text: "Save"),
                    ],
                  ),
                ],
              ),
            ),
            addVerticalSpacing(24),
          ],
        ),
      ),
    );
  }
}
