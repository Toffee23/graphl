import 'dart:async';
import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vmodel/src/features/dashboard/new_profile/controller/user_jobs_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/jobs_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_row.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_field.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/cache/credentials.dart';
import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/deliverables_type.dart';
import '../../../../core/utils/enum/ethnicity_enum.dart';
import '../../../../core/utils/enum/license_type.dart';
import '../../../../core/utils/enum/size_enum.dart';
import '../../../../res/SnackBarService.dart';
import '../../../../shared/slider/range_slider.dart';
import '../../job_market/controller/job_controller.dart';
import '../../job_market/model/job_post_model.dart';
import '../controller/create_job_controller.dart';

final dates = StateProvider.autoDispose<List>((ref) => []);

class CreateJobSecondPage extends ConsumerStatefulWidget {
  // final String isPricePerService;
  const CreateJobSecondPage({
    super.key,
    this.isEdit = false,
    required this.jobType,
    //  required this.isPricePerService
  });
  final String jobType;
  //final JobPostModel? job;
  final bool isEdit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateJobSecondPageState();
}

class _CreateJobSecondPageState extends ConsumerState<CreateJobSecondPage> {
  double slideValue = 18;
  double amountSlide = 0;
  bool done = false;
  String jobType = "On-site";
  String duration = "Full-Day";
  String arrivalTime = "Morning";
  String gender = "Male";
  Ethnicity ethnicity = Ethnicity.values.first;
  String budget = "Per Day";
  String identifiedGender = "Indentified Gender";
  String heightInches = "1";
  String heightFeet = "5";
  ModelSize size = ModelSize.values.first; //= "XL";
  // String complexion = "Dark/Melanin";
  bool isDigitalContent = true;
  bool hasAdvancedRequirements = false;
  // String usageType = VConstants.kUsageTypes.first; //"Usage type";
  LicenseType usageType = LicenseType.values.first; //"Usage type";
  DeliverablesType deliverableType =
      DeliverablesType.values.first; //"Usage type";
  String usageLength = VConstants.kUsageLengthOptions.first; //"Usage Length";
  List<String> _usageLengthOptions = [];
  RangeValues _ageRangeValues = const RangeValues(18, 30);
  Map<String, dynamic> _selectedLocation = {};
  String _placeId = "";
  var username;

  TextEditingController dateTime = TextEditingController();
  // final _locationController = TextEditingController();
  final _deliverablesController = TextEditingController();
  final _heightController = TextEditingController();
  bool _showButtonLoader = false;

  final _formKey = GlobalKey<FormState>();

  JobPostModel? _job;
  bool _isFirstLoad = true;

  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final postalCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    var vcred = VCredentials.inst;
    username = vcred.getUsername();
    //Taking out the last option from the usage length options
    _usageLengthOptions = VConstants.kUsageLengthOptions
        .sublist(0, VConstants.kUsageLengthOptions.length - 1);

    _job = ref.read(singleJobProvider);

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => (_job != null) ? initWithExistingJobData() : null,
    );
  }

  void initWithExistingJobData() {
    _selectedLocation = _job?.jobLocation?.toMap() ?? {};

    //   ref.read(jobDataProvider.notifier).state.copyWith(
    // location: {
    //   "latitude": "0",
    //   "longitude": "0",
    //   "locationName": _selectedLocation,
    // },
    _deliverablesController.text = _job?.deliverablesType ?? "";
    isDigitalContent = _job?.isDigitalContent ?? false;
    usageType = LicenseType.licenseTypeByApiValue(_job?.usageType?.name ?? '');
    deliverableType =
        DeliverablesType.licenseTypeByApiValue(_job?.deliverablesType ?? '');
    usageLength =
        _job?.usageLength?.name ?? VConstants.kUsageLengthOptions.first;
    hasAdvancedRequirements = _job?.hasAdvancedRequirements ?? false;
    ethnicity = _job?.ethnicity ?? Ethnicity.values.first;
    if ((_job?.minAge ?? 0) > 0 && (_job?.maxAge ?? 0) > 0) {
      _ageRangeValues = RangeValues(
          _job?.minAge.toDouble() ?? 0.0, _job?.maxAge.toDouble() ?? 0.0);
    }
    _heightController.text = _job?.talentHeight?['value'] ?? '';
    size = _job?.size ?? ModelSize.values.first;
  }

  @override
  Widget build(BuildContext context) {
    _job = ref.watch(singleJobProvider);

    if (widget.isEdit) {
      // if (_job != null) {
      //   initWithExistingJobData();
      // }
      _isFirstLoad = false;
    }
    final tempJobData = ref.watch(jobDataProvider);

    return Portal(
      child: Stack(
        children: [
          Scaffold(
            appBar: VWidgetsAppBar(
              appBarHeight: 50,
              leadingIcon: const VWidgetsBackButton(),
              appbarTitle: widget.isEdit ? "Update a job" : "Create a job",
            ),
            body: SingleChildScrollView(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visibility(
                    //   visible: widget.jobType == 'Remote' ? false : true,
                    //   child: Column(
                    //     children: [
                    //       addVerticalSpacing(25),
                    //       NewFormRow(
                    //         customValidator: (value) {
                    //           return null;
                    //         },
                    //         fieldTitle: 'Street Address',
                    //         // fieldType: FormFieldTypes.text,
                    //         // controller: TextEditingController(),
                    //         fieldType: FormFieldTypes.custom,
                    //         customInputFeild: PlacesAutocompletionField(
                    //           hintText: "Start typing address...",
                    //           initialValue: _selectedLocation['streetAddress'],
                    //           isFollowerTop: false,
                    //           fullLocation: false,
                    //           onItemSelected: (value) {
                    //             logger.f(value);
                    //             if (!mounted) return;
                    //             _selectedLocation = value;
                    //             city.text = value['city'];
                    //             state.text = value['county'];
                    //             country.text = value['country'];
                    //             postalCode.text = value['postalCode'];
                    //             setState(() {});
                    //           },
                    //           postOnChanged: (String value) {},
                    //         ),
                    //         onUpdate: (val) async {},
                    //         fieldValue:
                    //             _selectedLocation['streetAddress'] ?? '',
                    //       ),
                    //       NewFormRow(
                    //         customValidator: widget.jobType == 'Remote'
                    //             ? (_) => null
                    //             : (value) => VValidatorsMixin.isNotEmpty(value,
                    //                 field: "City is required"),
                    //         fieldTitle: 'City',
                    //         fieldType: FormFieldTypes.text,
                    //         controller: city,
                    //         fieldValue: city.text,
                    //         onUpdate: (val) {
                    //           _selectedLocation['city'] = val;
                    //         },
                    //       ),
                    //       // VWidgetsTextFieldNormal(
                    //       //   onChanged: (val) {
                    //       //     _selectedLocation['city'] = val;
                    //       //   },
                    //       //   textCapitalization: TextCapitalization.sentences,
                    //       //   controller: city,
                    //       //   labelText: 'City',
                    //       //   hintText: 'Miami Beach',
                    //       //   validator: widget.jobType == 'Remote' ? null : (value) => VValidatorsMixin.isNotEmpty(value, field: "City is required"),
                    //       // ),
                    //       // addVerticalSpacing(8),
                    //       NewFormRow(
                    //         customValidator: widget.jobType == 'Remote'
                    //             ? (_) => null
                    //             : (value) => VValidatorsMixin.isNotEmpty(value,
                    //                 field: "County is required"),
                    //         fieldTitle: 'County',
                    //         fieldType: FormFieldTypes.text,
                    //         controller: state,
                    //         fieldValue: state.text,
                    //         onUpdate: (val) {
                    //           _selectedLocation['county'] = val;
                    //         },
                    //       ),
                    //       // VWidgetsTextFieldNormal(
                    //       //   onChanged: (val) {
                    //       //     _selectedLocation['county'] = val;
                    //       //   },
                    //       //   textCapitalization: TextCapitalization.sentences,
                    //       //   controller: state,
                    //       //   labelText: 'County',
                    //       //   hintText: 'Florida',
                    //       //   validator: widget.jobType == 'Remote' ? null : (value) => VValidatorsMixin.isNotEmpty(value, field: "State is required"),
                    //       // ),
                    //       NewFormRow(
                    //         customValidator: widget.jobType == 'Remote'
                    //             ? (_) => null
                    //             : (value) => VValidatorsMixin.isNotEmpty(value,
                    //                 field: "Country is required"),
                    //         fieldTitle: 'Country',
                    //         fieldType: FormFieldTypes.text,
                    //         controller: country,
                    //         fieldValue: country.text,
                    //         onUpdate: (val) {
                    //           _selectedLocation['country'] = val;
                    //         },
                    //       ),
                    //       // VWidgetsTextFieldNormal(
                    //       //   onChanged: (val) {
                    //       //     _selectedLocation['country'] = val;
                    //       //   },
                    //       //   textCapitalization: TextCapitalization.sentences,
                    //       //   controller: country,
                    //       //   labelText: 'Country',
                    //       //   hintText: 'United States',
                    //       //   validator: widget.jobType == 'Remote' ? null : (value) => VValidatorsMixin.isNotEmpty(value, field: "Coutry is required"),
                    //       // ),
                    //       NewFormRow(
                    //         customValidator: widget.jobType == 'Remote'
                    //             ? (_) => null
                    //             : (value) => VValidatorsMixin.isNotEmpty(value,
                    //                 field: "Postal Code is required"),
                    //         fieldTitle: 'Postal Code',
                    //         fieldType: FormFieldTypes.text,
                    //         controller: postalCode,
                    //         fieldValue: postalCode.text,
                    //         onUpdate: (val) {
                    //           _selectedLocation['postalCode'] = val;
                    //         },
                    //       ),
                    //       // VWidgetsTextFieldNormal(
                    //       //   onChanged: (val) {
                    //       //     _selectedLocation['postalCode'] = val;
                    //       //   },
                    //       //   textCapitalization: TextCapitalization.sentences,
                    //       //   controller: postalCode,
                    //       //   labelText: 'Postal Code',
                    //       //   hintText: '33139',
                    //       //   validator: widget.jobType == 'Remote' ? null : (value) => VValidatorsMixin.isNotEmpty(value, field: "Postal code is required"),
                    //       // ),
                    //       // const Divider(thickness: 1),
                    //     ],
                    //   ),
                    // ),
                    addVerticalSpacing(25),
                    // VWidgetsDescriptionTextFieldWithTitle(
                    //   controller: _deliverablesController,
                    //   label: "Deliverables type (Required)",
                    //   hintText: "Eg. What do you expect to receive?",
                    //   validator: VValidatorsMixin.isNotEmpty,
                    //   // isIncreaseHeightForErrorText: true,
                    //   minLines: 4,
                    //   //keyboardType: TextInputType.emailAddress,
                    //   //onSaved: (){},
                    // ),
                    NewFormRow(
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
                            .singleWhere((type) => type.simpleName == absVal);
                        setState(() {});
                      },
                    ),
                    // VWidgetsDropDownTextField<DeliverablesType>(
                    //   fieldLabel: "Deliverables type (Required)",
                    //   hintText: "",
                    //   onChanged: (val) {
                    //     setState(() {
                    //       deliverableType = val;
                    //     });
                    //   },
                    //   value: deliverableType,
                    //   // options: const ["Usage type", "Usage type 2"],
                    //   options: DeliverablesType.values,
                    //   getLabel: (DeliverablesType value) => value.simpleName,
                    // ),
                    // addVerticalSpacing(8),
                    NewFormRow(
                      customValidator: (p0) {
                        return null;
                      },
                      options: const ["Yes", "No"],
                      fieldTitle: 'Digital content?',
                      fieldValue: isDigitalContent ? 'Yes' : 'No',
                      onUpdate: (val) async {
                        setState(() {
                          isDigitalContent = val == 'Yes' ? true : false;
                        });
                      },
                    ),
                    // VWidgetsDropDownTextField<bool>(
                    //   fieldLabel: "Are you receiving any digital content?",
                    //   hintText: "",
                    //   onChanged: (val) {
                    //     setState(() {
                    //       isDigitalContent = val;
                    //     });
                    //   },
                    //   value: isDigitalContent,
                    //   // options: const ["Yes", "No"],
                    //   options: const [false, true],
                    //   // getLabel: (String value) => value,
                    //   customDisplay: (value) => value ? "Yes" : "No",
                    // ),
                    if (isDigitalContent)
                      Column(
                        children: [
                          NewFormRow(
                            customValidator: (p0) {
                              return null;
                            },
                            options: LicenseType.values
                                .map((type) => type.simpleName)
                                .toList(),
                            fieldTitle: 'License',
                            fieldValue: usageType.simpleName,
                            onUpdate: (val) async {
                              usageType = LicenseType.values.singleWhere(
                                  (type) => type.simpleName == val);
                              setState(() {});
                            },
                          ),
                          NewFormRow(
                            customValidator: (p0) {
                              return null;
                            },
                            options: _usageLengthOptions,
                            fieldTitle: 'Usage Length',
                            fieldValue: usageLength,
                            onUpdate: (val) async {
                              setState(() {
                                usageLength = val!;
                              });
                            },
                          ),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          // Flexible(
                          //   child: VWidgetsDropDownTextField<LicenseType>(
                          //     fieldLabel: "License Type",
                          //     hintText: "",
                          //     onChanged: (val) {
                          //       setState(() {
                          //         usageType = val;
                          //       });
                          //     },
                          //     value: usageType,
                          //     // options: const ["Usage type", "Usage type 2"],
                          //     options: LicenseType.values,
                          //     getLabel: (LicenseType value) => value.simpleName,
                          //   ),
                          // ),
                          // addHorizontalSpacing(10),
                          // Flexible(
                          //   child: VWidgetsDropDownTextField(
                          //     fieldLabel: "",
                          //     hintText: "",
                          //     onChanged: (val) {
                          //       setState(() {
                          //         usageLength = val;
                          //       });
                          //     },
                          //     value: usageLength,
                          //     // options: const ["Usage Length", "Usage Length 2"],
                          //     options: _usageLengthOptions,
                          //     getLabel: (String value) => value,
                          //   ),
                          // ),
                          //   ],
                          // ),
                        ],
                      ),

                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: hasAdvancedRequirements,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        childrenPadding: EdgeInsets.zero,
                        tilePadding: EdgeInsets.zero,
                        onExpansionChanged: (value) {
                          hasAdvancedRequirements = value;
                          setState(() {});
                        },
                        trailing: Icon(
                          hasAdvancedRequirements
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 32,
                        ),
                        // iconColor: VmodelColors.primaryColor,
                        title: Text("Advanced Requirements",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor)),
                        children: [
                          addVerticalSpacing(25),
                          VWidgetsDropDownTextField<Ethnicity>(
                            fieldLabel: "Ethnicity",
                            hintText: "",
                            options: Ethnicity
                                .values, //const ["Black/African", "Asian"],
                            onChanged: (val) {
                              setState(() {
                                ethnicity = val;
                              });
                            },
                            value: ethnicity,
                            getLabel: (Ethnicity value) => value.simpleName,
                          ),
                          addVerticalSpacing(25),
                          // Text(
                          //   "Age Range",
                          //   style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          //       fontWeight: FontWeight.w600,
                          //       color: Theme.of(context).primaryColor),
                          // ),
                          // addVerticalSpacing(20),
                          // VWidgetsSlider<double>(
                          //   startLabel: "18",
                          //   endLabel: "32",
                          //   sliderValue: slideValue,
                          //   sliderMinValue: 18,
                          //   sliderMaxValue: 32,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       slideValue = value;
                          //     });
                          //   },
                          // ),
                          VWidgetsRangeSlider(
                            title: "Age Range",
                            sliderValue: _ageRangeValues,
                            sliderMinValue: 1,
                            sliderMaxValue: 100,
                            onChanged: (RangeValues value) {
                              setState(() {
                                _ageRangeValues = value;
                              });
                            },
                          ),

                          addVerticalSpacing(25),

                          SizedBox(
                            height: 75,
                            //color: Colors.green,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: VWidgetsPrimaryTextFieldWithTitle(
                                    label: "Height (cm)",
                                    hintText: "Ex. 190",
                                    minLines: 1,
                                    // maxLength: 3,
                                    controller: _heightController,
                                    // validator: VValidatorsMixin.isNotEmpty,
                                    isIncreaseHeightForErrorText: true,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      // setState(() {});
                                    },
                                    //onSaved: (){},
                                  ),
                                ),

                                //         SizedBox(
                                //           width: 75,
                                //           child: VWidgetsDropDownTextField(
                                //             fieldLabel: "Height",
                                //             hintText: "",
                                //             value: heightFeet,
                                //             onChanged: (val) {
                                //               setState(() {
                                //                 heightFeet = val;
                                //               });
                                //             },
                                //             options: const ["3", "4", "5", "6", "7", "8", "9"],
                                //             getLabel: (String value) => value,
                                //           ),
                                //         ),
                                //         addHorizontalSpacing(5),
                                //         SizedBox(
                                //           width: 75,
                                //           child: VWidgetsDropDownTextField(
                                //             fieldLabel: "",
                                //             hintText: "",
                                //             value: heightInches,
                                //             onChanged: (val) {
                                //               setState(() {
                                //                 heightInches = val;
                                //               });
                                //             },
                                //             options: const [
                                //               "1",
                                //               "2",
                                //               "3",
                                //               "4",
                                //               "5",
                                //               "6",
                                //               "7",
                                //               "8",
                                //               "9",
                                //               "10",
                                //               "11",
                                //               "12"
                                //             ],
                                //             getLabel: (String value) => value,
                                //           ),
                                //         ),
                                addHorizontalSpacing(40),
                                Flexible(
                                  child: VWidgetsDropDownTextField<ModelSize>(
                                    fieldLabel: "Size",
                                    hintText: "",
                                    onChanged: (val) {
                                      setState(() {
                                        size = val;
                                      });
                                    },
                                    value: size,
                                    // options: const ["S", "M", "L", "XL", "XXL"],
                                    options: ModelSize.values,
                                    getLabel: (ModelSize value) =>
                                        value.simpleName,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    addVerticalSpacing(25),
                    VWidgetsPrimaryButton(
                      enableButton: true,
                      showLoadingIndicator: _showButtonLoader,
                      onPressed: () async {
                        await _onCreateOrUpdate();
                      },
                      buttonTitle: widget.isEdit ? "Update" : "Create",
                    ),
                    addVerticalSpacing(50)
                  ],
                ),
              ),
            ),
          ),
          // if (_isLoading) LoaderProgress(done: done, loading: _isLoadingState)
        ],
      ),
    );
  }

  Future<LatLng?> getLatLngFromPlaceId(String placeId, String apiKey) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey');

    final timeout = const Duration(milliseconds: 3000);

    try {
      final response = await http.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Future<void> _onCreateOrUpdate() async {
  //
  //   LatLng? latlng;
  //   if(_placeId.isNotEmpty) {
  //     latlng = await getLatLngFromPlaceId(_placeId, VUrls.mapsApiKey);
  //   }
  // }

  final jobCreateLoadingProvider = StateProvider.autoDispose((ref) => true);
  Future<void> _onCreateOrUpdate() async {
    if (!_formKey.currentState!.validate()) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message: "Please fill all required fields");
      return;
    }
    _toggleButtonLoader();

    final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
          location: widget.jobType == 'Remote' ? null : _selectedLocation,
          deliverablesType: deliverableType.apiValue,
          isDigitalContent: isDigitalContent,
          usageType: isDigitalContent ? usageType.apiValue : null,
          usageLength: isDigitalContent ? usageLength : null,
          ethnicity: hasAdvancedRequirements ? ethnicity : null,
          minAge: hasAdvancedRequirements ? _ageRangeValues.start.round() : 0,
          maxAge: hasAdvancedRequirements ? _ageRangeValues.end.round() : 0,
          height: _getHeight,
          size: hasAdvancedRequirements ? size : null,
          // complexion: complexion,
        );
    ref.read(jobDataProvider.notifier).state = temp;

    // VLoader.changeLoadingState(true);

    if (widget.isEdit == false) {
      showAnimatedDialog(
        barrierColor: Colors.black54,
        context: context,
        child: Consumer(builder: (context, ref, child) {
          return LoaderProgress(
            done: !ref.watch(jobCreateLoadingProvider),
            loading: ref.watch(jobCreateLoadingProvider),
          );
        }),
      );

      final success = await ref
          .read(createJobNotifierProvider.notifier)
          .createJob(isAdvanced: hasAdvancedRequirements);

      if (success) {
        ref.invalidate(createJobNotifierProvider);
        //invalidate main jobs page
        ref.invalidate(jobsProvider);
        //invalidate user jobs
        ref.invalidate(userJobsProvider(null));
        ref.invalidate(jobDataProvider);
        _toggleButtonLoader();
        ref.read(jobCreateLoadingProvider.notifier).state = false;
        await Future.delayed(Duration(seconds: 2), () async {});
        SnackBarService().showSnackBar(
            message: "Job created successfully", context: context);
        Navigator.of(context).pop();
        if (mounted) {
          goBack(context);
          goBack(context);
        }
      } else {
        Navigator.of(context).pop();
      }
    } else {
      showAnimatedDialog(
        barrierColor: Colors.black54,
        context: context,
        child: Consumer(builder: (context, ref, child) {
          return LoaderProgress(
            done: !ref.watch(jobCreateLoadingProvider),
            loading: ref.watch(jobCreateLoadingProvider),
          );
        }),
      );
      final success = await ref
          .read(createJobNotifierProvider.notifier)
          .updateJob(
              jobId: _job?.id ?? '', isAdvanced: hasAdvancedRequirements);

      if (success) {
        ref.invalidate(createJobNotifierProvider);
        ref.invalidate(jobDataProvider);
        //invalidate main jobs page
        ref.invalidate(jobsProvider);
        //invalidate user jobs
        await ref.refresh(userJobsProvider(null).future);
        ref.invalidate(jobDetailProvider(_job?.id));
        ref.read(jobCreateLoadingProvider.notifier).state = false;
        await Future.delayed(Duration(seconds: 2), () async {});
        SnackBarService().showSnackBar(
            message: "Job updated successfully", context: context);
        Navigator.of(context).pop();
        if (mounted) {
          goBack(context);
          goBack(context);
        }
      } else {
        Navigator.of(context).pop();
      }
    }

    _toggleButtonLoader();
  }

//if (_isLoading) LoaderProgress(animation: _animation, done: _done)
  void _toggleButtonLoader() {
    _showButtonLoader = !_showButtonLoader;
    setState(() {});
  }

  Map<String, dynamic>? get _getHeight {
    // check for height text is empty
    // if empty, it should return zero
    // todo: check if height is zero is allowed

    return {"value": int.parse(_heightController.text.isEmpty ? '0' : _heightController.text), "unit": "cm"};

    /*if (_heightController.text.isNotEmpty) {
      return {"value": int.parse(_heightController.text), "unit": "cm"};
    }
    return null;*/

  }
}
