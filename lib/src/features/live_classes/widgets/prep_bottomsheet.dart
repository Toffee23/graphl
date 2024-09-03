import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/validators_mixins.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/text_fields/description_text_field.dart';

class PrepBottomSheet extends ConsumerStatefulWidget {
  const PrepBottomSheet({
    Key? key,
    this.onItemTap,
    this.bottomInsetPadding = 15,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  final double bottomInsetPadding;

  @override
  ConsumerState<PrepBottomSheet> createState() => _PrepBottomSheetState();
}

class _PrepBottomSheetState extends ConsumerState<PrepBottomSheet> {
  late final TextEditingController controller;

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
            VWidgetsDescriptionTextFieldWithTitle(
              maxLines: 10,
              minLines: 5,
              // controller: descriptionController,
              label: 'Add a Prep',
              hintText:
                  "Inform your audience on what they need and how to be prepared for your live.",
              validator: (value) => VValidatorsMixin.isMinimumLengthValid(
                  value, 100,
                  field: 'Prep'),
              labelStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
              onChanged: (val) {},
            ),
            addVerticalSpacing(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VWidgetsPrimaryButton(
                  butttonWidth: 40.w,
                  onPressed: () {
                    goBack(context);
                  },
                  buttonTitle: "Discard",
                ),
                VWidgetsPrimaryButton(
                  butttonWidth: 40.w,
                  onPressed: () {},
                  buttonTitle: "Save Prep",
                ),
              ],
            ),
            addVerticalSpacing(24),
          ],
        ),
      ),
    );
  }
}
