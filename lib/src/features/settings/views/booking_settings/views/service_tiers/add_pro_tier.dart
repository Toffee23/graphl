import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/enums/tiers_enum.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/form_fields/enums/form_field_enum.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_row.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_row_for_service_category.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import '../../../../../../core/utils/costants.dart';

class AddProTier extends ConsumerStatefulWidget {
  const AddProTier({super.key});

  @override
  ConsumerState<AddProTier> createState() => _AddProTierState();
}

class _AddProTierState extends ConsumerState<AddProTier> {
  final proTierTitleController = TextEditingController();
  final proTierRevisionsController = TextEditingController();
  final proTierPriceController = TextEditingController();
  final proTierAddonsController = TextEditingController();
  final proTierAddonsPriceController = TextEditingController();
  final proTierDescController = TextEditingController();
  String? revision;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (ref.read(proTierProvider) != null) {
      proTierTitleController.text = ref.read(proTierProvider)!.title;
      revision = ref.read(proTierProvider)!.revision.toString();
      proTierPriceController.text =
          ref.read(proTierProvider)!.revision.toString();
      proTierAddonsController.text =
          ref.read(proTierProvider)!.addons.firstOrNull?.name ?? '';
      proTierAddonsController.text =
          ref.read(proTierProvider)!.addons.firstOrNull?.price.toString() ?? '';
      proTierDescController.text = ref.read(proTierProvider)!.desc;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: 'Add Pro Tier',
        leadingIcon: VWidgetsBackButton(
          onTap: () {
            VMHapticsFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewFormRow(
                input: TextInputType.text,
                fieldTitle: 'Title',
                fieldType: FormFieldTypes.text,
                controller: proTierTitleController,
                fieldValue: proTierTitleController.text,
                onUpdate: (val) async {
                  setState(() {});
                },
              ),
              NewFormRowForServiceCategory(
                options: VConstants.kSserviceTiersRevision,
                fieldTitle: 'Revisions',
                fieldValue: revision,
                customValidator: (p0) {
                  return null;
                },
                onUpdate: (val) {
                  revision = val;

                  setState(() {});
                },
              ),
              NewFormRow(
                fieldValueFormat: (val) => val.formatToPounds(),
                input: TextInputType.number,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      addVerticalSpacing(3),
                      Text(
                        "\u00A3",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                    ],
                  ),
                ),
                customValidator: (value) =>
                    VValidatorsMixin.isValidServicePrice(value, field: "Price"),
                fieldTitle: 'Price (\u00A3)',
                showCurrency: true,
                fieldType: FormFieldTypes.text,
                formatters: [
                  CurrencyTextInputFormatter.currency(
                    customPattern: '.',
                  ),
                ],
                controller: proTierPriceController,
                fieldValue: proTierPriceController.text,
                onUpdate: (val) async {
                  setState(() {});
                },
              ),
              NewFormRow(
                input: TextInputType.text,
                fieldTitle: 'Addons',
                fieldType: FormFieldTypes.text,
                controller: proTierAddonsController,
                fieldValue: proTierAddonsController.text,
                onUpdate: (val) async {
                  setState(() {});
                },
              ),
              NewFormRow(
                fieldValueFormat: (val) => val.formatToPounds(),
                input: TextInputType.number,
                showCurrency: true,
                customValidator: (value) =>
                    VValidatorsMixin.isValidServicePrice(value, field: "Price"),
                fieldTitle: 'Addons Price (\u00A3)',
                fieldType: FormFieldTypes.text,
                formatters: [
                  CurrencyTextInputFormatter.currency(
                    customPattern: '.',
                  ),
                ],
                controller: proTierAddonsPriceController,
                fieldValue: proTierAddonsPriceController.text,
                onUpdate: (val) async {
                  setState(() {});
                },
              ),
              addVerticalSpacing(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: VWidgetsDescriptionTextFieldWithTitle(
                  maxLines: 5,
                  minLines: 1,
                  maxLength: 5000,
                  showCounter: true,
                  controller: proTierDescController,
                  label: 'Tier Description',
                  hintText:
                      'Provide a clear and detailed description of this service tier you are offering.',
                  validator: (value) => VValidatorsMixin.isMinimumLengthValid(
                      value, 100,
                      field: 'Service description'),
                  labelStyle: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: VmodelColors.mainColor),
                  onChanged: (val) {},
                ),
              ),
              addVerticalSpacing(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Consumer(builder: (context, ref, widget) {
                  return VWidgetsPrimaryButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "Please fix all errors on the form");
                        return;
                      }
                      if (proTierTitleController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier title is required");
                        return;
                      }
                      if (proTierPriceController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier price is required");
                        return;
                      }
                      if (revision == null) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier revision is required");
                        return;
                      }
                      if (proTierAddonsController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier addons is required");
                        return;
                      }
                      if (proTierAddonsPriceController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier addon price is required");
                        return;
                      }
                      if (proTierDescController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier description is required");
                        return;
                      }

                      ref.read(proTierProvider.notifier).state =
                          ServiceTierModel(
                        tier: ServiceTiers.standard,
                        title: proTierTitleController.text,
                        desc: proTierDescController.text,
                        price: double.parse(proTierPriceController.text),
                        addons: [
                          ServiceTierAddOn(
                            name: proTierAddonsController.text,
                            price:
                                double.parse(proTierAddonsPriceController.text),
                            desc: '',
                          ),
                        ],
                        revision: int.parse(revision!),
                      );
                      Navigator.pop(context);
                    },
                    buttonTitle: 'Add Tier',
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
