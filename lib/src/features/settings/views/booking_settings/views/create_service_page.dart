import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/enum/service_pricing_enum.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/extensions/hex_color.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/jobs/create_jobs/controller/create_job_controller.dart';
import 'package:vmodel/src/features/jobs/create_jobs/model/ai_desc_type_enum.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/enums/tiers_enum.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/service_tiers/add_premium_tier.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/service_tiers/add_pro_tier.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/faq_textfeilds.dart';
import 'package:vmodel/src/features/settings/views/verification/views/blue-tick/widgets/text_field.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/custom_expansion_tile.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_input.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_row_for_service_category.dart';
import 'package:vmodel/src/shared/popup_dialogs/input_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/discard_editing_controller.dart';
import '../../../../../core/utils/costants.dart';
import '../../../../../core/utils/enum/deliverables_type.dart';
import '../../../../../core/utils/enum/work_location.dart';
import '../../../../../res/SnackBarService.dart';
import '../../../../../shared/form_fields/enums/form_field_enum.dart';
import '../../../../../shared/form_fields/views/new_form_row.dart';
import '../../../../../shared/loader/loader_progress.dart';
import '../../../../../shared/popup_dialogs/popup_without_save.dart';
import '../controllers/service_images_controller.dart';
import '../widgets/service_image_listview.dart';

/// [CreateServicePage] handles the creation of services
class CreateServicePage extends ConsumerStatefulWidget {
  const CreateServicePage({
    super.key,
    this.servicePackage,
    this.onUpdateSuccess,
  });

  /// default value is null attach object if updating a service using [ServicePackageModel]
  final ServicePackageModel? servicePackage;

  /// callback for services update
  final ValueChanged<ServicePackageModel>? onUpdateSuccess;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewCreateServicePageState();
}

class _NewCreateServicePageState extends ConsumerState<CreateServicePage> {
  final priceController = TextEditingController();
  final depositController = TextEditingController();
  final discountController = TextEditingController();
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  DeliverablesType deliverableType =
      DeliverablesType.values.first; //"Usage type";

  late String _selectedDelivery = '';
  String? _selectedUsageType = '';
  String? _selectedUsageLength = '';
  WorkLocation? _serviceLocation;
  var _selectedPricingOption = ServicePeriod.hour;
  final _formKey = GlobalKey<FormState>();
  String deliveryTitle = 'Delivery';
  String usageTypeTitle = 'License type';
  String usageLengthTitle = 'License length';
  bool isvaluevalid = true;
  bool _isDigitalContent = false;
  bool _isAddtionalOfferingServices = false;
  bool _isfaq = false;
  bool _isDiscounted = true;
  bool _showButtonLoader = false;
  // int _percentDiscount = 0;
  bool _isPopupClosed = false;
  bool travelPolicy = false;

  bool expressDelivery = false;
  String? _selectedExpressDelivery;
  final expressPriceController = TextEditingController();

  String imageName = "";
  String? _serviceBannerUrl;
  XFile? image;
  List<XFile> serviceImages = [];
  List<Map> categoryList = [];

  List<Widget> faqTextFields = [];
  List<TextEditingController> anserControllers = [TextEditingController()];
  List<TextEditingController> questionControllers = [TextEditingController()];
  List<FocusNode> focusNodes = [FocusNode()];
  final _scrollController = ScrollController();
  String lastValidInput = '';

  bool generateDesc = false;

  final travelFeeController = TextEditingController();
  final travelPolicyController = TextEditingController();

  bool hasTier = false;

  final standardTierAddonsController = TextEditingController();
  final standardTierAddonsPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(serviceProvider);
    for (var data in VConstants.tempCategories) {
      categoryList.add({"item": data, "selected": false});
    }
    if (widget.servicePackage == null) {
      _selectedDelivery = VConstants.kDeliveryOptions.first;
      _selectedUsageType = VConstants.kUsageTypes.first;
      _selectedUsageLength = VConstants.kUsageLengthOptions.first;

      faqTextFields.add(FAQTextField(
        questionNumber: 1,
        answerController: anserControllers[0],
        questionController: questionControllers[0],
        questionFocusNode: focusNodes[0],
      ));
    } else {
      if (widget.servicePackage!.faq != null) {
        if (widget.servicePackage!.faq!.isNotEmpty) {
          anserControllers.clear();
          questionControllers.clear();
          focusNodes.clear();
          for (int index = 0;
              index < widget.servicePackage!.faq!.length;
              index++) {
            anserControllers.add(TextEditingController(
                text: widget.servicePackage!.faq![index].answer));
            questionControllers.add(TextEditingController(
                text: widget.servicePackage!.faq![index].question));
            focusNodes.add(FocusNode());
          }
          for (var i = 0; i < questionControllers.length; i++) {
            faqTextFields.add(
              FAQTextField(
                questionNumber: i + 1,
                answerController: anserControllers[i],
                questionController: questionControllers[i],
                questionFocusNode: focusNodes[i],
              ),
            );
          }
          _isfaq = true;
          setState(() {});
        } else {
          if (faqTextFields.isEmpty)
            faqTextFields.add(FAQTextField(
              questionNumber: 1,
              answerController: anserControllers[0],
              questionController: questionControllers[0],
              questionFocusNode: focusNodes[0],
            ));
        }
      } else {
        if (faqTextFields.isEmpty)
          faqTextFields.add(FAQTextField(
            questionNumber: 1,
            answerController: anserControllers[0],
            questionController: questionControllers[0],
            questionFocusNode: focusNodes[0],
          ));
      }

      _selectedDelivery = widget.servicePackage!.delivery;
      _selectedUsageType = _getOptionFromApiString(
          VConstants.kUsageTypes, widget.servicePackage?.usageType);
      _selectedUsageLength = widget.servicePackage?.usageLength;
      _selectedPricingOption = ServicePeriod.hour;
      // _selectedPricingOption = widget.servicePackage!.servicePricing;
      priceController.text = widget.servicePackage!.price.toInt().toString();
      // depositController.text = widget.servicePackage!.price.toInt().toString();
      titleController.text = widget.servicePackage!.title.toString();
      // _serviceBannerUrl = widget.servicePackage!.bannerUrl;
      descriptionController.text =
          widget.servicePackage!.description.toString();
      _serviceLocation = widget.servicePackage!.serviceLocation;
      _isAddtionalOfferingServices = widget.servicePackage!.hasAdditional;
      _isDigitalContent = widget.servicePackage!.isDigitalContentCreator;
      discountController.text = widget.servicePackage?.percentDiscount != null
          ? widget.servicePackage!.percentDiscount.toString()
          : '';
      depositController.text = widget.servicePackage?.percentDiscount != null
          ? widget.servicePackage!.initialDeposit.toString()
          : '';

      deliverableType = DeliverablesType.licenseTypeByApiValue(
          widget.servicePackage?.deliverablesType ?? '');
    }

    titleController.addListener(() {
      //print("is text ${isText(titleController.text)}");
      if (titleController.text.isNotEmpty) {
        if (!containsEmoji(titleController.text)) {
          //print("is imojie");
          titleController.clear();
        } else {
          //print("Is text");
        }
      } else {
        lastValidInput = titleController.text;
      }
      setState(() {});
    });
    initDiscardProvider();
  }

  bool isText(String input) {
    final alphanumericPattern = RegExp(r'^[A-Za-z0-9]+$');
    return alphanumericPattern.hasMatch(input);
  }

  bool containsEmoji(String text) {
    // Define a regular expression pattern to match emojis
    final RegExp regexEmoji = RegExp(
        r'(\\u00a9|\\u00ae|[\\u2000-\\u3300]|\\ud83c[\\ud000-\\udfff]|\\ud83d[\\ud000-\\udfff]|\\ud83e[\\ud000-\\udfff])');
    return regexEmoji.hasMatch(text);
  }

  initDiscardProvider() {
    //print('[discard******] init discard again');
    ref.read(discardProvider.notifier).initialState('delivery',
        initial: _selectedDelivery, current: _selectedDelivery);
    ref.read(discardProvider.notifier).initialState('usageType',
        initial: _selectedUsageType, current: _selectedUsageType);
    ref.read(discardProvider.notifier).initialState('usageLength',
        initial: _selectedUsageLength, current: _selectedUsageLength);
    ref.read(discardProvider.notifier).initialState('pricingOption',
        initial: _selectedPricingOption, current: _selectedPricingOption);
    ref.read(discardProvider.notifier).initialState('price',
        initial: priceController.text, current: priceController.text);
    ref.read(discardProvider.notifier).initialState('title',
        initial: titleController.text, current: titleController.text);
    ref.read(discardProvider.notifier).initialState('description',
        initial: descriptionController.text,
        current: descriptionController.text);
    ref.read(discardProvider.notifier).initialState('serviceType',
        initial: _serviceLocation, current: _serviceLocation);
    ref.read(discardProvider.notifier).initialState('discount',
        initial: discountController.text, current: discountController.text);
    ref.read(discardProvider.notifier).initialState('isDiscount',
        initial: _isDiscounted, current: _isDiscounted);
    // ref.read(discardProvider.notifier).initialState('deposit',
    //     initial: depositController.text, current: depositController.text);
    ref.read(discardProvider.notifier).initialState('banners',
        initial: [...ref.read(serviceImagesProvider)],
        current: [...ref.read(serviceImagesProvider)]);
    ref
        .read(discardProvider.notifier)
        .initialState('isFaq', initial: _isfaq, current: _isfaq);
  }

  @override
  dispose() {
    _scrollController.dispose();

    titleController.dispose();
    // if (context.mounted) {
    //   ref.invalidate(discardProvider);
    //   ref.invalidate(serviceImagesProvider);
    // }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _toggleButtonLoader() {
    _showButtonLoader = !_showButtonLoader;
    setState(() {});
  }

  void addToListIfNotExist(List<String> options, String value) {
    // if (value.isEmpty) return;
    // setState(() {
    //   // Create a copy of the options list to make it modifiable
    //   final List<String> modifiableOptions = List.from(options);

    //   // Check if the value already exists before adding
    //   if (!modifiableOptions.contains(value)) {
    //     modifiableOptions.add(value);
    //   }
    // });
  }

  String _getOptionFromApiString(List<String> options, String? value) {
    if (value == null) return options.first;
    return options
        .firstWhere((element) => element.toLowerCase() == value.toLowerCase());
  }

  ServiceType? serviceType;
  ServiceType? serviceSubType;

  @override
  Widget build(BuildContext context) {
    // final userState = ref.watch(appUserProvider);
    // final user = userState.valueOrNull;
    // final services = ref.watch(userServices(user!.username));
    // final myServices = ref.watch(servicePackagesProvider(null));
    final images = ref.watch(serviceImagesProvider);
    ref.watch(discardProvider);

    return WillPopScope(
      onWillPop: () async {
        return onPopPage(context, ref, onDiscard: () {
          ref.read(proTierProvider.notifier).state = null;
          ref.read(premiumTierProvider.notifier).state = null;
          ref.invalidate(serviceImagesProvider);
          ref.invalidate(discardProvider);
          if (context.mounted) {
            goBack(context);
          }
        });
      },
      child: Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(
            onTap: () {
              VMHapticsFeedback.lightImpact();
              onPopPage(context, ref, onDiscard: () {
                ref.read(proTierProvider.notifier).state = null;
                ref.read(premiumTierProvider.notifier).state = null;
                ref.invalidate(serviceImagesProvider);
                ref.invalidate(discardProvider);
                if (context.mounted) {
                  goBack(context);
                }
              });
            },
          ),
          appbarTitle: widget.servicePackage == null
              ? "Create a new service"
              : "Update service",
          // trailingIcon: [
          //   VWidgetsTextButton(
          //     text: widget.servicePackage == null ? "Create" : "Update",
          //     showLoadingIndicator: _showButtonLoader,
          //     onPressed: () async {
          //       // showDialog(
          //       //     context: context,
          //       //     builder: (BuildContext context) {
          //       //       return CreatedSuccessDialogue();
          //       //     });
          //       await _onCreateOrUpdate(images);
          //     },
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const VWidgetsPagePadding.horizontalSymmetric(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpacing(20),
                // addVerticalSpacing(16),
                if (images.isNotEmpty)
                  Row(
                    children: [
                      Text("Sample Images",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(1),
                              )),
                    ],
                  ),
                if (images.isNotEmpty) addVerticalSpacing(8),
                if (images.isNotEmpty)
                  Row(
                    children: [
                      Flexible(
                          child: ServiceImageListView(
                        fileImages: images,
                        addMoreImages: () {
                          ref.read(serviceImagesProvider.notifier).pickImages();
                        },
                      )),
                    ],
                  ),
                if (images.isEmpty)
                  Row(
                    children: [
                      Text("Service banner(s)",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(1),
                              )),
                    ],
                  ),
                if (images.isEmpty) addVerticalSpacing(8),
                if (images.isEmpty)
                  Flexible(
                    child: Container(
                      width: SizerUtil.width,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .secondary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        height: 90,
                        width: 90,
                        // margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Column(
                          children: [
                            addVerticalSpacing(05),
                            TextButton(
                              onPressed: () => ref
                                  .read(serviceImagesProvider.notifier)
                                  .pickImages(),
                              style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .secondary,
                                  shape: const CircleBorder(),
                                  maximumSize: const Size(80, 50),
                                  minimumSize: const Size(80, 50)),
                              child: Icon(
                                Icons.add,
                                color: VmodelColors.white,
                                size: 26,
                              ),
                            ),
                            addVerticalSpacing(05),
                            Text("Tip: Add up to 10 photos",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.5),
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ),

                addVerticalSpacing(16),
                VWidgetsTextFieldNormal(
                  // minLines: 1,
                  // maxLines: 3,
                  // isDense: true,
                  // contentPadding:
                  //     const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  onChanged: (val) {
                    ref
                        .read(discardProvider.notifier)
                        .updateState('title', newValue: val);
                    setState(() {
                      // if (val.length >= 60) {
                      //   setState(() {
                      //     titleController.clear();
                      //   });
                      // }
                    });
                  },
                  inputFormatters: [
                    UppercaseLimitTextInputFormatter(),
                  ],
                  textCapitalization: TextCapitalization.sentences,
                  controller: titleController,
                  // isIncreaseHeightForErrorText: true,
                  // heightForErrorText: 80,
                  labelText: 'Title',
                  hintText: 'Glamour Shoot',
                  validator: (value) =>
                      VValidatorsMixin.isNotEmpty(value, field: "Service name"),
                ),
                addVerticalSpacing(10),
                VWidgetsDescriptionTextFieldWithTitle(
                  maxLines: 5,
                  minLines: 1,
                  maxLength: 5000,
                  showCounter: true,
                  controller: descriptionController,
                  endIcon: (titleController.text.isNotEmpty &&
                          _serviceLocation != null)
                      ? InkWell(
                          onTap: () async {
                            setState(() => generateDesc = true);
                            final gen = await ref
                                .read(createJobNotifierProvider.notifier)
                                .genDesc(
                                  titleController.text,
                                  _serviceLocation!.simpleName,
                                  AIDescType.service,
                                );
                            setState(() => generateDesc = false);
                            gen.fold(
                              (p0) => SnackBarService()
                                  .showSnackBar(message: p0, context: context),
                              (p0) => descriptionController.text = p0,
                            );
                          },
                          child: generateDesc
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ))
                              : RenderSvg(svgPath: VIcons.magicpen))
                      : Container(),
                  label: ' Description',
                  hintText:
                      'Provide a clear and detailed description of the service you are offering.',
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
                  onChanged: (val) {
                    ref.read(discardProvider.notifier).updateState(
                          'description',
                          newValue: val,
                        );
                  },
                ),
                addVerticalSpacing(15),

                // Column(
                //   children: [
                //     VWidgetsDropDownTextField<ServiceType>(
                //       prefixText: "",
                //       hintText: "",
                //       options: ref.watch(serviceTypeProvider).valueOrNull ??
                //           [], // VConstants.kDeliveryType,
                //       fieldLabel: "Service Type",
                //       onChanged: (val) {
                //         serviceType = val;
                //         ref
                //             .read(discardProvider.notifier)
                //             .updateState('serviceType', newValue: serviceType);
                //         if (serviceSubType != null) {
                //           serviceSubType = null;
                //         }
                //         setState(() {});
                //       },
                //       value: serviceType,
                //       customDisplay: (value) => value.name,
                //     ),
                //     if (serviceType != null &&
                //         serviceType!.subType.isNotEmpty) ...[
                //       VWidgetsDropDownTextField<ServiceType>(
                //         options:
                //             serviceType!.subType, // VConstants.kDeliveryType,
                //         hintText: '',
                //         fieldLabel: "Service SubType",
                //         onChanged: (val) {
                //           serviceSubType = val;
                //           ref.read(discardProvider.notifier).updateState(
                //               'serviceSubType',
                //               newValue: serviceType);
                //           setState(() {});
                //         },
                //         value: serviceSubType,
                //         customDisplay: (value) => value.name,
                //       ),
                //     ]
                //   ],
                // ),
                NewFormRowForServiceCategory(
                  options: (ref.watch(serviceTypeProvider).valueOrNull ?? [])
                      .map((type) => type.name)
                      .toList(),
                  fieldTitle: 'Service Category',
                  fieldValue: serviceType?.name,
                  customValidator: (p0) {
                    return null;
                  },
                  onUpdate: (val) {
                    var inputtedType =
                        (ref.watch(serviceTypeProvider).valueOrNull ?? [])
                            .firstWhere((type) => type.name == val);
                    serviceType = inputtedType;
                    ref
                        .read(discardProvider.notifier)
                        .updateState('serviceType', newValue: serviceType);
                    if (serviceSubType != null) {
                      serviceSubType = null;
                    }
                    setState(() {});
                  },
                ),
                if (serviceType != null && serviceType!.subType.isNotEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NewFormRowForServiceCategory(
                        options: serviceType?.subType
                            .map((type) => type.name)
                            .toList(),
                        fieldTitle: 'Service Sub Category',
                        fieldValue: serviceSubType?.name,
                        customValidator: (p0) {
                          return null;
                        },
                        onUpdate: (val) {
                          var inputtedType = serviceType?.subType
                              .firstWhere((type) => type.name == val);
                          serviceSubType = inputtedType;
                          ref.read(discardProvider.notifier).updateState(
                              'serviceSubType',
                              newValue: serviceType);
                          setState(() {});
                        },
                      ),
                      addVerticalSpacing(10),
                    ],
                  ),

                NewFormRowForServiceCategory(
                  customValidator: (p0) {
                    return null;
                  },
                  options:
                      WorkLocation.values.map((val) => val.simpleName).toList(),
                  fieldTitle: 'Location',
                  fieldValue: _serviceLocation?.simpleName,
                  hintText: 'Select',
                  onUpdate: (val) {
                    var inputtedType = WorkLocation.values
                        .firstWhere((type) => type.simpleName == val);
                    _serviceLocation = inputtedType;
                    ref.read(discardProvider.notifier).updateState(
                        'serviceLocation',
                        newValue: _serviceLocation);
                    setState(() {});
                  },
                ),

                NewFormRowForServiceCategory(
                  options: VConstants.kDeliveryOptions,
                  customValidator: (p0) {
                    return null;
                  },
                  fieldTitle: deliveryTitle,
                  fieldValue: _selectedDelivery,
                  onUpdate: (val) async {
                    var absVal = val ?? '';
                    if (absVal.isNotEmpty && absVal.contains("Other")) {
                      final specifiedValue =
                          await showInputPopup(deliveryTitle);
                      if (specifiedValue != null && specifiedValue.isNotEmpty) {
                        addToListIfNotExist(
                            VConstants.kDeliveryOptions, specifiedValue);
                        _selectedDelivery = specifiedValue;
                      }
                    } else {
                      _selectedDelivery = absVal;
                    }
                    ref
                        .read(discardProvider.notifier)
                        .updateState('delivery', newValue: _selectedDelivery);
                    setState(() {});
                  },
                ),

                NewFormRowForServiceCategory(
                  options: ServicePeriod.values
                      .map((period) => period.tileDisplayName)
                      .toList(),
                  customValidator: (p0) {
                    return null;
                  },
                  fieldTitle: 'Pricing',
                  fieldValue: _selectedPricingOption.tileDisplayName,
                  onUpdate: (val) async {
                    _selectedPricingOption = ServicePeriod.values
                        .firstWhere((type) => type.tileDisplayName == val);
                    ref.read(discardProvider.notifier).updateState(
                        'pricingOption',
                        newValue: _selectedPricingOption);
                    setState(() {});
                  },
                ),
                NewFormRow(
                  showCurrency: true,
                  fieldValueFormat: (val) => val.formatToPounds(),
                  input: TextInputType.number,
                  customValidator: (value) =>
                      VValidatorsMixin.isValidServicePrice(value,
                          field: "Price"),
                  fieldTitle: 'Price',
                  fieldType: FormFieldTypes.text,
                  formatters: [
                    CurrencyTextInputFormatter.currency(
                      customPattern: '.',
                    ),
                  ],
                  controller: priceController,
                  fieldValue: "\u00A3" + priceController.text,
                  onUpdate: (val) async {
                    ref
                        .read(discardProvider.notifier)
                        .updateState('price', newValue: val);
                    setState(() {});
                  },
                ),

                NewFormRow(
                  input: TextInputType.text,
                  fieldTitle: 'Addons',
                  fieldType: FormFieldTypes.text,
                  controller: standardTierAddonsController,
                  fieldValue: standardTierAddonsController.text,
                  onUpdate: (val) async {
                    setState(() {});
                  },
                ),
                NewFormRow(
                  fieldValueFormat: (val) => val.formatToPounds(),
                  input: TextInputType.number,
                  showCurrency: true,
                  customValidator: (value) =>
                      VValidatorsMixin.isValidServicePrice(value,
                          field: "Price"),
                  fieldTitle: 'Addons Price (\u00A3)',
                  fieldType: FormFieldTypes.text,
                  formatters: [
                    CurrencyTextInputFormatter.currency(
                      customPattern: '.',
                    ),
                  ],
                  controller: standardTierAddonsPriceController,
                  fieldValue: standardTierAddonsPriceController.text,
                  onUpdate: (val) async {
                    setState(() {});
                  },
                ),
                NewFormRowForServiceCategory(
                  customValidator: (p0) {
                    return null;
                  },
                  options: DeliverablesType.values
                      .map((type) => type.simpleName)
                      .toList(),
                  fieldTitle: 'Deliverables',
                  fieldValue: deliverableType.simpleName,
                  onUpdate: (val) async {
                    var absVal = val ?? '';

                    deliverableType = DeliverablesType.values
                        .firstWhere((type) => type.simpleName == absVal);
                    setState(() {});
                  },
                ),
                addVerticalSpacing(10),

                if (deliverableType == DeliverablesType.content)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NewFormRowForServiceCategory(
                        options: VConstants.kUsageTypes,
                        customValidator: (p0) {
                          return null;
                        },
                        fieldTitle: usageTypeTitle,
                        fieldValue: _selectedUsageType,
                        onUpdate: (initVal) async {
                          var val = initVal;
                          if ((val?.isNotEmpty ?? false) &&
                              (val?.contains("Other") ?? false)) {
                            final specifiedValue =
                                await showInputPopup(usageTypeTitle);
                            if (specifiedValue != null &&
                                specifiedValue.isNotEmpty) {
                              addToListIfNotExist(
                                  VConstants.kUsageTypes, specifiedValue);
                              _selectedUsageType = specifiedValue;
                            }
                          } else {
                            _selectedUsageType = val;
                          }

                          ref.read(discardProvider.notifier).updateState(
                              'usageType',
                              newValue: _selectedUsageType);
                          setState(() {});
                        },
                      ),
                      addVerticalSpacing(10),
                      NewFormRowForServiceCategory(
                        options: VConstants.kUsageLengthOptions,
                        customValidator: (p0) {
                          return null;
                        },
                        fieldTitle: usageLengthTitle,
                        fieldValue: _selectedUsageLength ?? '',
                        onUpdate: (initVal) async {
                          var val = initVal;
                          if ((val?.isNotEmpty ?? false) &&
                              (val?.contains("Other") ?? false)) {
                            final specifiedValue =
                                await showInputPopup(usageLengthTitle);

                            if (specifiedValue != null &&
                                specifiedValue.isNotEmpty) {
                              addToListIfNotExist(
                                  VConstants.kUsageTypes, specifiedValue);
                              _selectedUsageLength = specifiedValue;
                            } else {
                              _selectedUsageLength = null;
                            }
                          } else {
                            _selectedUsageLength = val;
                          }
                          ref.read(discardProvider.notifier).updateState(
                                'usageLength',
                                newValue: _selectedUsageLength,
                              );

                          setState(() {});
                        },
                      ),
                      addVerticalSpacing(10),
                    ],
                  ),

                addVerticalSpacing(20),

                VCustomExpansionTileWidget(
                  toggleValue: hasTier,
                  color: '33649f'.fromHex,
                  title: 'Add Tiers',
                  onChanged: (tier) {
                    setState(() => hasTier = tier);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        if (ref.watch(proTierProvider) != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: "02bbd3".fromHex,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Pro Tier Added',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            )),
                                    Spacer(),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => navigateToRoute(
                                            context,
                                            AddProTier(),
                                          ),
                                          child: Text('Edit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                        ),
                                        addHorizontalSpacing(15),
                                        InkWell(
                                          onTap: () => ref
                                              .read(proTierProvider.notifier)
                                              .state = null,
                                          child: Text('Remove',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                addVerticalSpacing(10),
                                VServiceFeildValueContainer(
                                  title: 'Addons',
                                  subTitle: ref
                                          .watch(proTierProvider)!
                                          .addons
                                          .firstOrNull
                                          ?.name ??
                                      '',
                                  endText: ref
                                          .watch(proTierProvider)!
                                          .addons
                                          .firstOrNull
                                          ?.price
                                          .toString()
                                          .formatToPounds() ??
                                      '• Free',
                                ),
                                addVerticalSpacing(8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    VServiceFeildValueContainer(
                                      title: 'Revisions',
                                      subTitle: ref
                                                  .watch(proTierProvider)!
                                                  .revision ==
                                              0
                                          ? 'None'
                                          : ref
                                              .watch(proTierProvider)!
                                              .revision
                                              .toString(),
                                    ),
                                    VServiceFeildValueContainer(
                                      title: 'Price',
                                      subTitle: ref
                                          .watch(proTierProvider)!
                                          .price
                                          .toString()
                                          .formatToPounds(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else
                          VCustomExpansionTileChild(
                              title: 'Add Pro tier',
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  AddProTier(),
                                );
                              }),
                        addVerticalSpacing(10),
                        if (ref.watch(premiumTierProvider) != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Premium Tier Added',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            )),
                                    Spacer(),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => navigateToRoute(
                                            context,
                                            AddPremiumTier(),
                                          ),
                                          child: Text('Edit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                        ),
                                        addHorizontalSpacing(15),
                                        InkWell(
                                          onTap: () => ref
                                              .read(
                                                  premiumTierProvider.notifier)
                                              .state = null,
                                          child: Text('Remove',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                addVerticalSpacing(10),
                                VServiceFeildValueContainer(
                                  title: 'Addons',
                                  subTitle: ref
                                          .watch(premiumTierProvider)!
                                          .addons
                                          .firstOrNull
                                          ?.name ??
                                      '',
                                  endText: ref
                                          .watch(premiumTierProvider)!
                                          .addons
                                          .firstOrNull
                                          ?.price
                                          .toString()
                                          .formatToPounds() ??
                                      '• Free',
                                ),
                                addVerticalSpacing(8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    VServiceFeildValueContainer(
                                      title: 'Revisions',
                                      subTitle: ref
                                                  .watch(premiumTierProvider)!
                                                  .revision ==
                                              0
                                          ? 'None'
                                          : ref
                                              .watch(premiumTierProvider)!
                                              .revision
                                              .toString(),
                                    ),
                                    VServiceFeildValueContainer(
                                      title: 'Price',
                                      subTitle: ref
                                          .watch(premiumTierProvider)!
                                          .price
                                          .toString()
                                          .formatToPounds(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else
                          VCustomExpansionTileChild(
                              title: 'Add Premium tier',
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  AddPremiumTier(),
                                );
                              }),
                      ],
                    ),
                  ),
                ),

                addVerticalSpacing(10),
                VCustomExpansionTileWidget(
                  toggleValue: expressDelivery,
                  title: 'Express Delivery',
                  color: '784af5'.fromHex,
                  onChanged: (hasExpressDelivery) {
                    setState(() => expressDelivery = hasExpressDelivery);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                          title: 'Price:',
                          value: expressPriceController.text.isNotEmpty
                              ? expressPriceController.text.formatToPounds()
                              : null,
                          onTap: () async {
                            final value = await navigateToRoute<String?>(
                                context,
                                NewFormInput(
                                  title: 'Price (\u00A3)',
                                  showCurrency: true,
                                  controller: expressPriceController,
                                  fieldValue: expressPriceController.text,
                                  fieldType: FormFieldTypes.text,
                                  formatter: [
                                    CurrencyTextInputFormatter.currency(
                                      customPattern: '.',
                                    ),
                                  ],
                                ));
                            setState(() {});
                          }),
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                        title: 'Delivery:',
                        value: _selectedExpressDelivery,
                        onTap: () async {
                          if (_selectedExpressDelivery == null) {
                            _selectedExpressDelivery = null;
                          } else if (!VConstants.kExpresssDeliveryOptions
                              .contains(_selectedExpressDelivery)) {
                            _selectedExpressDelivery =
                                VConstants.kExpresssDeliveryOptions.last;
                          } else {
                            _selectedExpressDelivery = _selectedExpressDelivery;
                          }
                          final val = await navigateToRoute<String?>(
                              context,
                              NewFormInput(
                                title: 'Delivery',
                                fieldType: FormFieldTypes.dropdown,
                                fieldValue: _selectedExpressDelivery,
                                options: VConstants.kExpresssDeliveryOptions,
                              ));
                          if ((val?.isNotEmpty ?? false) &&
                              (val?.contains("Custom") ?? false)) {
                            final specifiedValue = await showInputPopup(
                                deliveryTitle,
                                hintSuffix: "(in hours)");
                            if (specifiedValue != null &&
                                specifiedValue.isNotEmpty) {
                              // Use the copied list to add the new value
                              addToListIfNotExist(
                                  List.from(
                                      VConstants.kExpresssDeliveryOptions),
                                  specifiedValue);
                              _selectedExpressDelivery =
                                  specifiedValue + " hours";
                            } else {
                              _selectedExpressDelivery = null;
                            }
                          } else {
                            _selectedExpressDelivery = val;
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(10),
                VCustomExpansionTileWidget(
                  toggleValue: _isAddtionalOfferingServices,
                  title: 'Discount',
                  color: '7f2b27'.fromHex,
                  onChanged: (hasDiscount) {
                    setState(() => _isAddtionalOfferingServices = hasDiscount);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    });
                  },
                  child: Column(
                    children: [
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                          title: 'Discounted Service:',
                          value: _isDiscounted ? 'Yes' : 'No',
                          onTap: () async {
                            final val = await navigateToRoute<String?>(
                                context,
                                NewFormInput(
                                  title: 'Discounted Service',
                                  fieldType: FormFieldTypes.dropdown,
                                  fieldValue: _isDiscounted ? 'Yes' : 'No',
                                  options: const ["Yes", "No"],
                                ));
                            setState(() {
                              _isDiscounted = val == 'Yes' ? true : false;
                            });
                            ref.read(discardProvider.notifier).updateState(
                                'isDiscount',
                                newValue: _isDiscounted);
                          }),
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                          title: 'Discount:',
                          value: discountController.text.isNotEmpty
                              ? discountController.text.formatToPercentage()
                              : null,
                          onTap: () async {
                            final value = await navigateToRoute<String?>(
                                context,
                                NewFormInput(
                                  title: '% Discount',
                                  prefixIconText: "%",
                                  showCurrency: true,
                                  controller: discountController,
                                  fieldValue: discountController.text,
                                  fieldType: FormFieldTypes.text,
                                  formatter: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                ));
                            setState(() {});
                          }),
                    ],
                  ),
                ),

                addVerticalSpacing(10),
                VCustomExpansionTileWidget(
                  toggleValue: travelPolicy,
                  title: 'Travel Fee',
                  color: '007b8a'.fromHex,
                  onChanged: (hasTravelPolicy) {
                    setState(() => travelPolicy = hasTravelPolicy);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    });
                  },
                  child: Column(
                    children: [
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                          title: 'Price:',
                          value: travelFeeController.text.isNotEmpty
                              ? travelFeeController.text.formatToPounds()
                              : null,
                          onTap: () async {
                            final value = await navigateToRoute<String?>(
                                context,
                                NewFormInput(
                                  title: 'Price (\u00A3)',
                                  showCurrency: true,
                                  controller: travelFeeController,
                                  fieldValue: travelFeeController.text,
                                  fieldType: FormFieldTypes.text,
                                  formatter: [
                                    CurrencyTextInputFormatter.currency(
                                      customPattern: '.',
                                    ),
                                  ],
                                ));
                            setState(() {});
                          }),
                      addVerticalSpacing(10),
                      VCustomExpansionTileChild(
                          title: 'Travel Policy',
                          value: travelPolicyController.text.isNotEmpty
                              ? travelPolicyController.text.formatToPounds()
                              : null,
                          onTap: () async {
                            final value = await navigateToRoute<String?>(
                                context,
                                NewFormInput(
                                  title: 'Travel Policy',
                                  controller: travelPolicyController,
                                  fieldValue: travelPolicyController.text,
                                  fieldType: FormFieldTypes.text,
                                ));
                            setState(() {});
                          }),
                    ],
                  ),
                ),

                addVerticalSpacing(10),
                VCustomExpansionTileWidget(
                  toggleValue: _isfaq,
                  title: 'FAQ',
                  color: '483650'.fromHex,
                  onChanged: (hasFAQ) {
                    setState(() => _isfaq = hasFAQ);
                    ref
                        .read(discardProvider.notifier)
                        .updateState('isFaq', newValue: !_isfaq);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.fastEaseInToSlowEaseOut);
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 5),
                        itemCount: faqTextFields.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Question ${index + 1}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(1),
                                            )),
                                    faqTextFields[index],
                                  ],
                                ),
                              ),
                              if (faqTextFields.length > 1)
                                VWidgetsPrimaryButton(
                                  onPressed: () {
                                    faqTextFields.removeAt(index);
                                    setState(() {});
                                  },
                                  buttonTitle: "Remove",
                                  buttonTitleTextStyle: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                        color:
                                            Theme.of(context).iconTheme.color,
                                        fontWeight: FontWeight.w600,
                                        // fontSize: 12.sp,
                                      ),
                                  buttonColor: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .secondary,
                                ),
                            ],
                          );
                        },
                      ),
                      VWidgetsPrimaryButton(
                        onPressed: () {
                          var anserController = TextEditingController();
                          var questionController = TextEditingController();
                          var questionFocusNode = FocusNode();
                          anserControllers.add(anserController);
                          questionControllers.add(questionController);
                          focusNodes.add(questionFocusNode);
                          faqTextFields.add(FAQTextField(
                            questionNumber: faqTextFields.length + 1,
                            answerController: anserController,
                            questionController: questionController,
                            questionFocusNode: questionFocusNode,
                          ));
                          setState(() {});

                          //Focus on newly added textfield
                          questionFocusNode.requestFocus();
                        },
                        buttonTitle: "Add New",
                        buttonTitleTextStyle:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: Theme.of(context).iconTheme.color,
                                  fontWeight: FontWeight.w600,
                                  // fontSize: 12.sp,
                                ),
                        buttonColor: Theme.of(context)
                            .buttonTheme
                            .colorScheme!
                            .secondary,
                      ),
                    ],
                  ),
                ),

                addVerticalSpacing(10),

                // GestureDetector(
                // onTap: () {
                //   _isfaq = true;
                //   ref.read(discardProvider.notifier).updateState('isFaq', newValue: _isfaq);
                //   setState(() {});

                //   //Focus on newly added textfield
                //   focusNodes[faqTextFields.length - 1].requestFocus();
                // },
                //   child: Container(
                //     // margin: EdgeInsets.symmetric(horizontal: 16),
                //     padding: EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Text(
                //               "Add FAQ",
                //               style: context.textTheme.displayMedium!.copyWith(
                //                 fontWeight: FontWeight.w600,
                //               ),
                //             ),
                //           ],
                //         ),
                //         addVerticalSpacing(10),
                //         Text(
                //           "${VMString.bullet} Introducing Service FAQ: In-depth Qs and As",
                //           style: context.textTheme.displaySmall!.copyWith(fontSize: 11.sp),
                //           maxLines: 2,
                //         ),
                //         addVerticalSpacing(5),
                //         Text(
                //           "${VMString.bullet} Enhance Service Clarity: Custom FAQ Section",
                //           style: context.textTheme.displaySmall!.copyWith(fontSize: 11.sp),
                //           maxLines: 2,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                addVerticalSpacing(24),
                VWidgetsPrimaryButton(
                  // butttonWidth: double.infinity,
                  showLoadingIndicator: _showButtonLoader,
                  buttonTitle:
                      widget.servicePackage == null ? 'Create' : 'Update',
                  enableButton: true,
                  onPressed: () async {
                    VMHapticsFeedback.lightImpact();
                    await _onCreateOrUpdate(images);
                  },
                ),
                addVerticalSpacing(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget squareCard(String title, String subTitle) {
    return Container(
      padding: const EdgeInsets.all(8), // 44.w
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            width: 0.3,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.grey),
      ),
      width: 160,
      height: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          addVerticalSpacing(
            15,
          ),
          Text(
            // 'Create a\nclass now',
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
          ),
          addVerticalSpacing(12),
          Flexible(
            child: Text(
              // 'Create your custom class and earn from your skills!',
              subTitle,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 11.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  final _createServiceLoadingProider = StateProvider.autoDispose((ref) => true);
  Future<void> _onCreateOrUpdate(List images) async {
    List<Map<String, dynamic>> faqs = [];
    if (faqTextFields.isNotEmpty)
      for (int index = 0; index < questionControllers.length; index++) {
        if (questionControllers[index].text.isNotEmpty) {
          faqs.add({
            "answer": anserControllers[index].text,
            "question": questionControllers[index].text,
          });
        }
      }

    final price = double.tryParse(priceController.text) ?? 0.0;
    final travelFee = double.tryParse(travelFeeController.text);
    final expressDeliveryPrice = double.tryParse(expressPriceController.text);

    final travelPolicy = travelPolicyController.text.isEmpty
        ? null
        : travelPolicyController.text;

    if (!_formKey.currentState!.validate()) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message: "Please fill all required fields");
      return;
    }
    if (image == null) {
      if (images.isEmpty) {
        VWidgetShowResponse.showToast(ResponseEnum.warning,
            message: "Service image is required");
        return;
      }
    }

    if (serviceType == null || serviceSubType == null) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message: "Select a service type");
      return;
    }
    List<ServiceTierModel> serviceTiers = [];

    debugPrint('what is here: ${standardTierAddonsPriceController.text}');

    //todo: please check if zero is accepted in this model

    serviceTiers.add(
      ServiceTierModel(
        tier: ServiceTiers.basic,
        title: ServiceTiers.basic.simpleName,
        desc: descriptionController.text,
        price: price,
        addons: [
          ServiceTierAddOn(
            name: standardTierAddonsController.text,
            price: double.parse(standardTierAddonsPriceController.text.isEmpty ? '0.0' : standardTierAddonsPriceController.text), // check if zero is accepted
            desc: '',
          ),
        ],
        revision: 1,
      ),
    );
    if (ref.read(proTierProvider) != null) {
      serviceTiers.add(ref.read(proTierProvider)!);
    }
    if (ref.read(premiumTierProvider) != null) {
      serviceTiers.add(ref.read(premiumTierProvider)!);
    }

    if (_serviceLocation == null) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message: "Select a service location");
      return;
    }
    // if (standardTierTitleController.text.isNotEmpty) {
    //   if (standardTierPriceController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Standard Service tier price is required");
    //     return;
    //   }

    //   if (standardTierAddonsController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Standard Service tier addon is required");
    //     return;
    //   }

    //   if (standardTierDescController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Standard Service tier description is required");
    //     return;
    //   }

    //   serviceTiers.add(
    // ServiceTierModel(
    //   tier: ServiceTiers.standard,
    //   title: standardTierTitleController.text,
    //   desc: standardTierDescController.text,
    //   price: double.parse(standardTierPriceController.text),
    //   addons: [
    //     ServiceTierAddOn(
    //       name: standardTierAddonsController.text,
    //       price: 0,
    //       desc: '',
    //     ),
    //   ],
    //   revision: int.parse(standardTierRevisionsController.text),
    // ),
    //   );
    // }

    // if (premiumTierTitleController.text.isNotEmpty) {
    //   if (premiumTierPriceController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Premium Service tier price is required");
    //     return;
    //   }

    //   if (premiumTierAddonsController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Premium Service tier addon is required");
    //     return;
    //   }

    //   if (premiumTierDescController.text.isEmpty) {
    //     VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Premium Service tier description is required");
    //     return;
    //   }

    //   serviceTiers.add(
    //     ServiceTierModel(
    //       tier: ServiceTiers.premium,
    //       title: premiumTierTitleController.text,
    //       desc: premiumTierDescController.text,
    //       price: double.parse(premiumTierPriceController.text),
    //       addons: [
    //         ServiceTierAddOn(
    //           name: premiumTierAddonsController.text,
    //           price: 0,
    //           desc: '',
    //         ),
    //       ],
    //       revision: int.parse(premiumTierRevisionsController.text),
    //     ),
    //   );
    // }
    logger.f(serviceTiers.map((x) => x.toJson(x)).toList());

    // VLoader.changeLoadingState(true);
    _toggleButtonLoader();
    showAnimatedDialog(
      barrierColor: Colors.black54,
      context: context,
      child: Consumer(builder: (context, ref, child) {
        return LoaderProgress(
          done: !ref.watch(_createServiceLoadingProider),
          loading: ref.watch(_createServiceLoadingProider),
        );
      }),
    );
    bool successful = false;
    if (widget.servicePackage == null) {
      successful =
          await ref.read(servicePackagesProvider(null).notifier).addPackage(
                deliveryTimeline: _selectedDelivery,
                serviceLocation: _serviceLocation!.apiValue,
                serviceSubType: serviceSubType!,
                serviceType: serviceType!,
                description: descriptionController.text.trim(),
                period: _selectedPricingOption.simpleName,
                price: price,
                title: titleController.text.trim(),
                deliverablesType: deliverableType.apiValue,
                usageLength: _selectedUsageLength,
                usageType: _selectedUsageType?.toLowerCase(),
                isDigitalContent: _isDigitalContent,
                hasAddtionalSerices: _isAddtionalOfferingServices,
                percentDiscount: int.tryParse(discountController.text.trim()),
                image: image,
                deposit: double.tryParse(depositController.text.trim()),
                faqs: faqs,
                travelFee: travelFee,
                travelPolicy: travelPolicy,
                expressDelivery: _selectedExpressDelivery,
                expressDeliveryPrice: expressDeliveryPrice,
                tiers: serviceTiers,
              );
    } else {
      //print('Updating a service package View');
      if (!_isDigitalContent) {
        _selectedUsageLength = VConstants.kUsageLengthOptions.first;
        _selectedUsageType = VConstants.kUsageTypes.first;
      }

      successful = await ref
          .read(servicePackagesProvider(null).notifier)
          .updatePackage(
            widget.servicePackage!.copyWith(
              delivery: _selectedDelivery,
              description: descriptionController.text.trim(),
              serviceLocation: _serviceLocation,
              servicePricing: _selectedPricingOption,
              price: price,
              deliverablesType: deliverableType.apiValue,
              faq: faqs
                  .map((e) =>
                      FAQModel(question: e['question'], answer: e['answer']))
                  .toList(),
              title: titleController.text.trim(),
              usageLength: _selectedUsageLength,
              usageType: _selectedUsageType?.toLowerCase(),
              isDigitalContentCreator: _isDigitalContent,
              hasAdditional: _isAddtionalOfferingServices,
              percentDiscount: _isAddtionalOfferingServices
                  ? int.tryParse(discountController.text.trim())
                  : 0,
              initialDeposit: int.tryParse(depositController.text.trim()),
            ),
            onSuccessCallback: widget.onUpdateSuccess,
            image: image,
          );
    }

    _toggleButtonLoader();

    if (successful) {
      // dispose service tiers provider on successfull response
      ref.read(proTierProvider.notifier).state = null;
      ref.read(premiumTierProvider.notifier).state = null;

      //change loader state to false
      ref.read(_createServiceLoadingProider.notifier).state = false;

      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
        if (mounted) {
          goBack(context);
        }
      });

      SnackBarService().showSnackBar(
          message: widget.servicePackage == null
              ? "Service created successfully"
              : "Service updated successfully",
          context: context);
    } else {
      Navigator.of(context).pop();
    }
  }

  // _isDigitalContent() {}

  Future<String?> showInputPopup(String title, {String hintSuffix = ""}) async {
    final controller = TextEditingController();
    final result = await showAnimatedDialog<String>(
        context: context,
        child: (VWidgetsInputPopUp(
          popupTitle: title,
          popupField: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Please specify $hintSuffix',
            ),
            controller: controller,
            // decoration: (InputDecoration(hintText: '')),
          ),
          onPressedYes: () async {
            Navigator.pop(context, controller.text.trim());
          },
        )));

    return result;
  }

  depositDialog(BuildContext context) {
    _isPopupClosed = false;
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isPopupClosed) goBack(context);
    });

    return showAnimatedDialog(
      context: context,
      child: VWidgetsPopUpWithoutSaveButton(
        popupTitle: Text(
          'Adding a deposit means your clients must pay this'
          ' deposit to book your service',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
        ),
      ),
    ).then((value) => _isPopupClosed = true);
  }

  void _removeImage() {
    if (image != null || _serviceBannerUrl != null) {
      try {
        // Delete the picked file
        _serviceBannerUrl = '';
        image = null;
        //print('Image removed successfully');
      } catch (e) {
        //print('Error removing image: $e');
      }
      if (mounted) setState(() {});
    }
  }
}
