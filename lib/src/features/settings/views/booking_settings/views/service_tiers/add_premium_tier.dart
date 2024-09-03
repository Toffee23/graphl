import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
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

class AddPremiumTier extends ConsumerStatefulWidget {
  const AddPremiumTier({super.key});

  @override
  ConsumerState<AddPremiumTier> createState() => _AddPremiumTierState();
}

class _AddPremiumTierState extends ConsumerState<AddPremiumTier> {
  bool hasPremiumTier = false;
  final premiumTierTitleController = TextEditingController();
  final premiumTierRevisionsController = TextEditingController();
  final premiumTierPriceController = TextEditingController();
  final premiumTierAddonsController = TextEditingController();
  final premiumTierAddonsPriceController = TextEditingController();
  final premiumTierDescController = TextEditingController();
  String? revision;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (ref.read(premiumTierProvider) != null) {
      premiumTierTitleController.text = ref.read(premiumTierProvider)!.title;
      revision = ref.read(premiumTierProvider)!.revision.toString();
      premiumTierPriceController.text =
          ref.read(premiumTierProvider)!.revision.toString();
      premiumTierAddonsController.text =
          ref.read(premiumTierProvider)!.addons.firstOrNull?.name ?? '';
      premiumTierAddonsPriceController.text =
          ref.read(premiumTierProvider)!.addons.firstOrNull?.price.toString() ??
              '';
      premiumTierDescController.text = ref.read(premiumTierProvider)!.desc;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: 'Add Premium Tier',
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
                controller: premiumTierTitleController,
                fieldValue: premiumTierTitleController.text,
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
                showCurrency: true,
                customValidator: (value) =>
                    VValidatorsMixin.isValidServicePrice(value, field: "Price"),
                fieldTitle: 'Price (\u00A3)',
                fieldType: FormFieldTypes.text,
                formatters: [
                  CurrencyTextInputFormatter.currency(
                    customPattern: '.',
                  ),
                ],
                controller: premiumTierPriceController,
                fieldValue: premiumTierPriceController.text,
                onUpdate: (val) async {
                  setState(() {});
                },
              ),
              NewFormRow(
                input: TextInputType.text,
                fieldTitle: 'Addons',
                fieldType: FormFieldTypes.text,
                controller: premiumTierAddonsController,
                fieldValue: premiumTierAddonsController.text,
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
                controller: premiumTierAddonsPriceController,
                fieldValue: premiumTierAddonsPriceController.text,
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
                  controller: premiumTierDescController,
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
                      if (premiumTierTitleController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier title is required");
                        return;
                      }
                      if (premiumTierPriceController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier price is required");
                        return;
                      }
                      if (revision == null) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier revision is required");
                        return;
                      }
                      if (premiumTierAddonsController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier addons is required");
                        return;
                      }
                      if (premiumTierAddonsPriceController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier addons price required");
                        return;
                      }
                      if (premiumTierDescController.text.isEmpty) {
                        VWidgetShowResponse.showToast(ResponseEnum.warning,
                            message: "A tier description is required");
                        return;
                      }

                      ref.read(premiumTierProvider.notifier).state =
                          ServiceTierModel(
                        tier: ServiceTiers.premium,
                        title: premiumTierTitleController.text,
                        desc: premiumTierDescController.text,
                        price: double.parse(premiumTierPriceController.text),
                        addons: [
                          ServiceTierAddOn(
                            name: premiumTierAddonsController.text,
                            price: double.parse(
                                premiumTierAddonsPriceController.text),
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
