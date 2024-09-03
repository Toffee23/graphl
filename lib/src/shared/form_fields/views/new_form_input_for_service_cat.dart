import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/shared/form_fields/enums/form_field_enum.dart';

import '../../../vmodel.dart';
import '../../appbar/appbar.dart';

class NewFormInputForServiceCategory extends StatefulWidget {
  const NewFormInputForServiceCategory({
    super.key,
    this.options,
    this.fieldValue,
    required this.title,
    this.formatter,
    this.inputType,
    this.customValidate,
    required this.fieldType,
    this.controller,
    this.customInputFeild,
    this.prefixText,
  });

  final List<String>? options;
  final FormFieldTypes fieldType;
  final String title;
  final String? prefixText;
  final TextInputType? inputType;
  final String? Function(String?)? customValidate;
  final List<TextInputFormatter>? formatter;
  final TextEditingController? controller;
  final Widget? customInputFeild;
  final String? fieldValue;

  @override
  State<NewFormInputForServiceCategory> createState() =>
      _NewFormInputForServiceCategoryState();
}

class _NewFormInputForServiceCategoryState
    extends State<NewFormInputForServiceCategory> {
  TextEditingController _fieldController = TextEditingController();
  late String? finalValue = widget.fieldValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(
            onTap: () {
              VMHapticsFeedback.lightImpact();
              goBack(context);
            },
          ),
          appbarTitle: widget.title,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SafeArea(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              shrinkWrap: true,
              itemCount: widget.options?.length ?? 0,
              itemBuilder: (context, index) {
                final item = widget.options?[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      finalValue = item;
                    });
                    dismissKeyboard();
                    Navigator.pop(context, finalValue);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: item == finalValue
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7),
                              ),
                        ),
                        Container(
                          height: 20,
                          width: 20,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: item == finalValue
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item == finalValue
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        // Radio<String?>(
                        //   activeColor: Theme.of(context).primaryColor,
                        //   value: item,
                        //   groupValue: finalValue,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       finalValue = value;
                        //     });
                        //     dismissKeyboard();
                        //     Navigator.pop(context, finalValue);
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
