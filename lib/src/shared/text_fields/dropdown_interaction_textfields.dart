// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/vmodel.dart';

import 'dropdown_text_field.dart';

class InteractionDropdown<T> extends ConsumerStatefulWidget {
  final String title;
  T value;
  final Function(T) onDone;
  List<T> dropdownValues;
  final String Function(T)? itemToString;

  InteractionDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.onDone,
    required this.dropdownValues,
    required this.itemToString,
  });

  @override
  ConsumerState<InteractionDropdown<T>> createState() =>
      _GenderFieldDropdownState<T>();
}

class _GenderFieldDropdownState<T> extends ConsumerState<InteractionDropdown<T>> {
  final showLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          appbarTitle: widget.title,
          trailingIcon: [
            ValueListenableBuilder<bool>(
                valueListenable: showLoading,
                builder: (context, value, child) {
                  return VWidgetsTextButton(
                    text: "Done",
                    showLoadingIndicator: value,
                    onPressed: () async {
                      VMHapticsFeedback.lightImpact();
                      dismissKeyboard();
                      widget.onDone(widget.value);

                      if (context.mounted) goBack(context);
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
                    VWidgetsDropDownTextField<T>(
                        // fieldLabel: 'Gender',
                        // hintText: 'Gender',
                        hintText: '',
                        value: widget.value,
                        onChanged: (val) {
                          setState(() {
                            
                            // dropdownIdentifyValue = val;
                            // widget.value = val;
                            widget.value = val;
                          });
                        },
                        // options: widget.options,
                        options: widget.dropdownValues),
                  ],
                ),
              )),
              addVerticalSpacing(12),
              ValueListenableBuilder<bool>(
                  valueListenable: showLoading,
                  builder: (context, value, child) {
                    return VWidgetsPrimaryButton(
                      buttonTitle: "Done",
                      showLoadingIndicator: value,
                      onPressed: () async {
                        widget.onDone(widget.value);
                        if (context.mounted) {
                          goBack(context);
                        }
                      },
                      // enableButton: true,
                    );
                  }),
              addVerticalSpacing(40),
            ],
          ),
        ));
  }
}
