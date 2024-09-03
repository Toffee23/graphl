import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/user_prefs_controller.dart';
import '../../../../../shared/text_fields/dropdown_text_field.dart';

class DefaultFeedViewDropdownInput extends ConsumerStatefulWidget {
  String? value;
  // final Future<void> Function(dynamic) onSave;

  DefaultFeedViewDropdownInput({
    super.key,
    this.value,
    // required this.onSave,
  });

  @override
  ConsumerState<DefaultFeedViewDropdownInput> createState() =>
      _DefaultFeedViewDropdownInputState();
}

class _DefaultFeedViewDropdownInputState
    extends ConsumerState<DefaultFeedViewDropdownInput> {
  var dropdownIdentifyValue = "";
  final isLoading = ValueNotifier(false);
  final options = ['Normal', 'Recommended'];
  bool isDefaultSlides = true;

  @override
  initState() {
    widget.value =
        ref.read(isRecommendedViewNotifier) ? options.last : options.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isRecommendedView = ref.watch(isRecommendedViewNotifier);
    final userPrefsConfig = ref.watch(userPrefsProvider);

    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: "Feed View",
        trailingIcon: [
          ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context, value, _) {
                return VWidgetsTextButton(
                  showLoadingIndicator: value,
                  text: "Done",
                  onPressed: () async {
                    VMHapticsFeedback.lightImpact();
                    isLoading.value = true;
                    // await widget.onSave(widget.value);
                    // VLoader.changeLoadingState(false);
                    ref.read(isRecommendedViewNotifier.notifier).setRecommended(
                        widget.value == 'Normal' ? false : true);
                    isLoading.value = false;
                    if (mounted) goBack(context);
                    // popSheet(context);
                  },
                );
              }),
        ],
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpacing(0),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  VWidgetsDropDownTextField(
                    // fieldLabel: widget.title,
                    // hintText: widget.value == null ? 'select ...' : '',
                    hintText: '',
                    value: widget.value,
                    // value: isDefaultSlides ? options.last : options.first,
                    isExpanded: true,
                    onChanged: (val) {
                      setState(() {
                        // dropdownIdentifyValue = val;
                        widget.value = val;
                      });

                      //print(widget.value);
                    },
                    options: options,
                  ),
                ],
              ),
            )),
            addVerticalSpacing(12),
            ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, value, _) {
                  return VWidgetsPrimaryButton(
                    showLoadingIndicator: value,
                    buttonTitle: "Done",
                    onPressed: () async {
                      // final authNotifier = ref.read(authProvider.notifier);
                      // VLoader.changeLoadingState(true);
                      isLoading.value = true;
                      // await widget.onSave(widget.value);
                      // VLoader.changeLoadingState(false);

                      ref
                          .read(isRecommendedViewNotifier.notifier)
                          .setRecommended(
                              widget.value == 'Normal' ? false : true);

                      isLoading.value = false;
                      if (mounted) goBack(context);
                      // navigateAndReplaceRoute(context, const ProfileSettingPage());
                    },
                    enableButton: true,
                  );
                }),
            addVerticalSpacing(40),
          ],
        ),
      ),
    );
  }
}
