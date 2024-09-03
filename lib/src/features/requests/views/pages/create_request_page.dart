import 'dart:collection';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/booking/controller/calendar_event.dart';
import 'package:vmodel/src/features/create_posts/views/chip_input_field.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/discover_controller.dart';
import 'package:vmodel/src/features/jobs/create_jobs/controller/create_job_controller.dart';
import 'package:vmodel/src/features/jobs/create_jobs/model/ai_desc_type_enum.dart';
import 'package:vmodel/src/features/jobs/create_jobs/model/job_data.dart';
import 'package:vmodel/src/features/jobs/create_jobs/widgets/selected_date_time_slots_widget.dart';
import 'package:vmodel/src/features/jobs/create_jobs/widgets/selected_date_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/service_image_listview.dart';
import 'package:vmodel/src/features/settings/views/verification/views/blue-tick/widgets/text_field.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/form_fields/enums/form_field_enum.dart';
import 'package:vmodel/src/shared/form_fields/views/new_form_row.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/switch/primary_switch.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/enum/gender_enum.dart';
import '../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../res/ui_constants.dart';
import '../../../../shared/popup_dialogs/popup_without_save.dart';
import '../../../authentication/register/provider/user_types_controller.dart';

class CreateRequestFirstPage extends ConsumerStatefulWidget {
  const CreateRequestFirstPage({
    super.key,
    this.user,
  });

  final VAppUser? user;

  @override
  ConsumerState<CreateRequestFirstPage> createState() => _CreateJobFirstPageState();
}

class _CreateJobFirstPageState extends ConsumerState<CreateRequestFirstPage> {
  double slideValue = 18;
  double amountSlide = 0;
  bool creativeBriefSwitchValue = false;
  WorkLocation? jobType;
  ServiceType? categoryType;
  ServiceType? subCategory;
  late ServicePeriod priceType;
  String talentType = "Model";
  String duration = "Full-Day";
  String arrivalTime = "Morning";
  String ethinicity = "Asian";
  String budget = "Per Day";
  String identifiedGender = "Indentified Gender";
  String height = "5'11";
  String weight = "XL";
  String complexion = "Dark/Melanin";
  String deliveryDateType = "Range";

  Gender preferredGender = Gender.values.first;
  TextEditingController dateTime = TextEditingController();

  // @override
  // bool get wantKeepAlive => true;

  DateTime _focusedDay = DateTime.now();

  Set<DateTime> _selectedDays = {};

  ValueNotifier<List<Event>>? _selectedEvents;

  final Duration _dateTimeRes = const Duration();

  final _currencyFormatter = NumberFormat.simpleCurrency(locale: "en_GB");
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _titleController = TextEditingController();
  // final _talentNumberController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _briefTextController = TextEditingController();
  final _briefLinkController = TextEditingController();
  bool _isMultipleApplicants = false;
  bool _isPopupClosed = false;
  String? _briefFile;
  XFile? pickedBriefFile;
  List<JobDeliveryDate> mySelectedDates = [];
  String lastValidInput = '';
  final maxDescLength = 5000;

  JobPostModel? _job;

  final usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay));
    _selectedDays = LinkedHashSet<DateTime>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    priceType = ServicePeriod.values.last;

    _briefTextController.addListener(() {
      setState(() {});
    });
    _titleController.addListener(() {
      if (_titleController.text.isNotEmpty) {
        if (!containsEmoji(_titleController.text)) {
          _titleController.clear();
        } else {}
      } else {
        lastValidInput = _titleController.text;
      }
      setState(() {});
    });

    _job = ref.read(singleJobProvider);
  }

  @override
  void dispose() {
    _selectedEvents!.dispose();
    _priceController.dispose();
    _titleController.dispose();
    // _talentNumberController.dispose();
    _shortDescriptionController.dispose();
    _briefTextController.dispose();
    _briefLinkController.dispose();
    try {
      ref.invalidate(jobDataProvider);
    } catch (e) {}
    super.dispose();
  }

  void getSavedJobTemp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final pref = VModelSharedPrefStorage();
    if (prefs.containsKey("temp_job")) {
      var data = await pref.getJson("temp_job");
      shoGetDraftPompt(data);
    } else {}
  }

  void saveJobTemp(var data) async {
    final pref = VModelSharedPrefStorage();
    await pref.putJson("temp_job", data);
  }

  bool generateDesc = false;

  void showSaveDraftPompt(JobDataModel tempJobData, BuildContext context) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: SizerUtil.height * 0.25,
            width: SizerUtil.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                addVerticalSpacing(20),
                VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    saveJobTemp(tempJobData);
                    Navigator.of(context, rootNavigator: true).pop();
                    goBack(context);
                  },
                  enableButton: true,
                  buttonTitle: "Save Draft",
                ),
                addVerticalSpacing(10),
                VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    goBack(context);
                    ref.invalidate(createJobNotifierProvider);
                    GoRouter.of(context).pop();
                  },
                  enableButton: true,
                  buttonTitle: "Discard Changes",
                ),
                addVerticalSpacing(10),
                VWidgetsPrimaryButton(
                  buttonColor: Colors.transparent,
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    goBack(context);
                  },
                  enableButton: true,
                  buttonTitle: "Go back",
                ),
              ],
            ),
          ),
        ));
  }

  void shoGetDraftPompt(var data) {
    showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: SizerUtil.height * 0.25,
            width: SizerUtil.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                addVerticalSpacing(20),
                VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    ref.read(jobDataProvider.notifier).state = JobDataModel.fromJson(data);
                    goBack(context);
                  },
                  enableButton: true,
                  buttonTitle: "Load Saved Draft",
                ),
                addVerticalSpacing(10),
                VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    goBack(context);
                    ref.invalidate(createJobNotifierProvider);
                    goBack(context);
                  },
                  enableButton: true,
                  buttonTitle: "Discard Draft",
                ),
              ],
            ),
          ),
        ));
  }

  bool isText(String input) {
    final alphanumericPattern = RegExp(r'^[A-Za-z0-9]+$');
    return alphanumericPattern.hasMatch(input);
  }

  bool containsEmoji(String text) {
    // Define a regular expression pattern to match emojis
    final RegExp regexEmoji = RegExp(r'(\\u00a9|\\u00ae|[\\u2000-\\u3300]|\\ud83c[\\ud000-\\udfff]|\\ud83d[\\ud000-\\udfff]|\\ud83e[\\ud000-\\udfff])');
    return regexEmoji.hasMatch(text);
  }

  late String username = widget.user?.username ?? '';

  @override
  Widget build(BuildContext context) {
    mySelectedDates = ref.watch(createJobNotifierProvider);
    final calculatedDuration = ref.watch(calculatedTotalDurationProvider);
    final timeOptions = ref.watch(timeOpProvider);
    final userTypes = ref.watch(accountTypesProvider);
    final allUserTypes = userTypes.valueOrNull;
    final tempJobData = ref.watch(jobDataProvider);

    final calendarChevronIconColor = Theme.of(context).primaryColor.withOpacity(0.5);

    final images = ref.watch(jobRequestImagesProvider);
    //print(tempJobData);/ Selected day
    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: VWidgetsBackButton(
          onTap: () {
            if (tempJobData!.jobTitle.isEmpty) {
              goBack(context);
            } else {
              showSaveDraftPompt(tempJobData, context);
            }
          },
        ),
        appbarTitle: "Create a request",
        // trailingIcon: [
        //   VWidgetsTextButton(
        //     text: "Continue",
        //     showLoadingIndicator: false,
        //     onPressed: () async {
        //       _onContinue();
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpacing(20),
              if (images.isNotEmpty)
                Row(
                  children: [
                    Text("Sample Images",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor.withOpacity(1),
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
                        ref.read(jobRequestImagesProvider.notifier).pickImages();
                      },
                    )),
                  ],
                ),
              if (images.isEmpty)
                Row(
                  children: [
                    Text("Requests banner(s)",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor.withOpacity(1),
                            )),
                  ],
                ),
              if (images.isEmpty) addVerticalSpacing(8),
              if (images.isEmpty)
                Container(
                  width: SizerUtil.width,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme!.secondary, borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: 90,
                    width: 90,
                    // margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 05),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).scaffoldBackgroundColor),
                    child: Column(
                      children: [
                        addVerticalSpacing(05),
                        TextButton(
                          onPressed: () => ref.read(jobRequestImagesProvider.notifier).pickImages(),
                          style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).buttonTheme.colorScheme!.secondary, shape: const CircleBorder(), maximumSize: const Size(80, 50), minimumSize: const Size(80, 50)),
                          child: Icon(
                            Icons.add,
                            color: VmodelColors.white,
                            size: 26,
                          ),
                        ),
                        addVerticalSpacing(05),
                        Text("Tip: Add up to 10 photos",
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                )),
                      ],
                    ),
                  ),
                ),
              addVerticalSpacing(16),
              VWidgetChipsField(
                maxNumberOfChips: 1,
                initialValue: widget.user != null ? [widget.user!] : [],
                onChanged: (data) {
                  username = data.first.username;

                  //print('featured${featured.length}');
                },
                suggestions: (query) async {
                  if (query.isEmpty && username.isNotEmpty) {
                    return [];
                  }
                  final users = await ref.read(discoverProvider.notifier).usersFeatured(query);

                  return users;
                },
              ),
              addVerticalSpacing(15),
              VWidgetsTextFieldNormal(
                labelText: 'Job Title',
                controller: _titleController,
                inputFormatters: [
                  UppercaseLimitTextInputFormatter(),
                ],
                textCapitalization: TextCapitalization.sentences,
                hintText: 'Eg. Modelling Job',
                onChanged: (p0) {
                  final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                        jobTitle: p0!.trim(),
                      );
                  ref.read(jobDataProvider.notifier).state = temp;
                  setState(() {});
                },
                validator: (value) => VValidatorsMixin.isNotEmpty(value),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              addVerticalSpacing(15),
              Column(
                children: [
                  VWidgetsDescriptionTextFieldWithTitle(
                    controller: _shortDescriptionController,
                    label: "Add description",
                    hintText: "Write a short overview of who you’re looking for...",
                    endIcon: (_titleController.text.isNotEmpty && jobType != null)
                        ? InkWell(
                            onTap: () async {
                              setState(() => generateDesc = true);
                              final gen = await ref.read(createJobNotifierProvider.notifier).genDesc(
                                    _titleController.text,
                                    jobType!.simpleName,
                                    AIDescType.job,
                                  );
                              setState(() => generateDesc = false);
                              gen.fold(
                                (p0) => SnackBarService().showSnackBar(message: p0, context: context),
                                (p0) => _shortDescriptionController.text = p0,
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
                    minLines: 4,
                    maxLength: maxDescLength,
                    // validator: (value) => VValidatorsMixin.isMinimumLengthValid(
                    //     value, 100,
                    //     field: 'Job description'),
                    onChanged: (p0) {
                      final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                            shortDescription: p0,
                          );
                      ref.read(jobDataProvider.notifier).state = temp;
                    },
                    //onSaved: (){},
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${maxDescLength - _shortDescriptionController.text.length} characters remaining",
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              ),
              addVerticalSpacing(15),
              Column(
                children: [
                  NewFormRow(
                    options: WorkLocation.values.map((x) => x.simpleName).toList(),
                    fieldTitle: 'Job Type',
                    fieldValue: jobType?.simpleName,
                    onUpdate: (val) {
                      setState(() {
                        // dropdownIdentifyValue = val;
                        jobType = WorkLocation.values.singleWhere((x) => x.simpleName == val);
                        if (!jobType!.simpleName.contains('Remote')) {
                          Future.delayed(const Duration(milliseconds: 2), () => jobDialog(context));
                        }
                        final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                              jobType: jobType?.simpleName,
                            );
                        ref.read(jobDataProvider.notifier).state = temp;
                        //print(tempJobData);
                      });
                    },
                  ),
                  NewFormRow(
                    options: ref.watch(serviceTypeProvider).valueOrNull?.map((x) => x.name).toList() ?? [],
                    fieldTitle: 'Service Category',
                    fieldValue: categoryType?.name,
                    onUpdate: (val) {
                      setState(() {
                        categoryType = ref.read(serviceTypeProvider).requireValue.where((x) => x.name == val!).single;

                        subCategory = null;
                      });
                      final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                            category: ref.read(serviceTypeProvider).requireValue.where((x) => x.name == val!).single,
                          );
                      ref.read(jobDataProvider.notifier).state = temp;
                    },
                  ),
                  // Row(
                  //   children: [
                  //     Flexible(
                  //       child: VWidgetsDropdownNormal<WorkLocation>(
                  //         fieldLabel: "Job Type",
                  //         hintText: jobType == null ? "Select..." : null,
                  //         hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                  //         items: WorkLocation.values,
                  //         value: jobType,
                  //         validator: (val) {
                  //           if (jobType == null) {
                  //             return '';
                  //           }
                  //           return null;
                  //         },
                  //         itemToString: (val) => val.simpleName,
                  //         onChanged: (val) {
                  //           setState(() {
                  //             // dropdownIdentifyValue = val;
                  //             jobType = val!;
                  //             if (!jobType!.name.contains('Remote')) {
                  //               Future.delayed(const Duration(milliseconds: 2), () => jobDialog(context));
                  //             }
                  //             final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                  //                   jobType: jobType!.apiValue,
                  //                 );
                  //             ref.read(jobDataProvider.notifier).state = temp;
                  //             //print(tempJobData);
                  //           });
                  //         },
                  //       ),
                  //     ),
                  //     addHorizontalSpacing(15),
                  //     Flexible(
                  //       child: VWidgetsDropdownNormal<ServiceType>(
                  //         fieldLabel: "Category",
                  //         isExpanded: true,
                  //         hintText: categoryType == null ? "Select..." : null,
                  //         hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  //         items: ref.watch(serviceTypeProvider).valueOrNull ?? [],
                  //         value: categoryType,
                  //         validator: (val) {
                  //           if (categoryType == null) {
                  //             return '';
                  //           }
                  //           return null;
                  //         },
                  //         itemToString: (val) => val.name,
                  //         onChanged: (val) {
                  //           setState(() {
                  //             // dropdownIdentifyValue = val;
                  //             categoryType = val!;
                  //           });
                  //           final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                  //                 category: val!,
                  //               );
                  //           ref.read(jobDataProvider.notifier).state = temp;
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
              if (categoryType != null) ...[
                NewFormRow(
                  options: categoryType?.subType.map((x) => x.name).toList() ?? [],
                  fieldTitle: 'Service Sub Category',
                  fieldValue: subCategory?.name,
                  customValidator: (p0) {
                    return null;
                  },
                  onUpdate: (val) {
                    setState(() {
                      // dropdownIdentifyValue = val;
                      subCategory = categoryType?.subType.where((x) => x.name == val!).single;
                    });
                    final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                          subCategory: categoryType?.subType.where((x) => x.name == val!).single,
                        );
                    ref.read(jobDataProvider.notifier).state = temp;
                  },
                ),
                // addVerticalSpacing(10),
                // VWidgetsDropdownNormal<ServiceType>(
                //   fieldLabel: "Sub Category",
                //   isExpanded: true,
                //   hintText: subCategory == null ? "Select..." : null,
                //   hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                //   items: categoryType?.subType ?? [],
                //   value: subCategory,
                //   validator: (val) {
                //     return null;
                //   },
                //   itemToString: (val) => val.name,
                //   onChanged: (val) {
                //     setState(() {
                //       // dropdownIdentifyValue = val;
                //       subCategory = val!;
                //     });
                //     final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                //           subCategory: val!,
                //         );
                //     ref.read(jobDataProvider.notifier).state = temp;
                //   },
                // ),
              ],
              NewFormRow(
                options: ServicePeriod.values.map((period) => period.tileDisplayName).toList(),
                fieldTitle: 'Pricing Option',
                fieldValue: priceType.tileDisplayName,
                onUpdate: (val) async {
                  if (priceType != val) {
                    ref.invalidate(createJobNotifierProvider);
                  }

                  setState(() {
                    priceType = ServicePeriod.values.where((x) => x.tileDisplayName == val!).single;
                  });
                  final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                        priceOption: priceType.simpleName,
                      );
                  ref.read(jobDataProvider.notifier).state = temp;
                },
              ),
              NewFormRow(
                fieldValueFormat: (val) => val.formatToPounds(),
                input: TextInputType.number,
                customValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'price is required';
                  } else {
                    final price = double.tryParse(value) ?? 0;
                    if (price < 5.0 || price > 10000000) {
                      return 'Invalid value';
                    }
                  }
                  return null;
                },
                fieldTitle: 'Price',
                fieldType: FormFieldTypes.text,
                formatters: [
                  CurrencyTextInputFormatter.currency(
                    customPattern: '.',
                  ),
                ],
                controller: _priceController,
                fieldValue: _priceController.text,
                onUpdate: (val) async {
                  final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                        priceValue: double.parse(_priceController.text.trim()),
                      );
                  ref.read(jobDataProvider.notifier).state = temp;
                },
              ),
              // addVerticalSpacing(10),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Flexible(
              //         child: VWidgetsDropdownNormal(
              //             fieldLabel: 'Price',
              //             itemToString: (val) => val.toString(),
              //             items: ServicePeriod.values,
              //             onChanged: (val) {
              //               if (priceType != val) {
              //                 ref.invalidate(createJobNotifierProvider);
              //               }

              //               setState(() {
              //                 priceType = val!;
              //               });
              //               final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
              //                     priceOption: priceType.simpleName,
              //                   );
              //               ref.read(jobDataProvider.notifier).state = temp;
              //             },
              //             value: priceType,
              //             validator: (val) {
              //               return null;
              //             })),
              //     addHorizontalSpacing(10),
              //     Flexible(
              //         child: Column(
              //       children: [
              //         VWidgetsTextFieldNormal(
              //           contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              //           labelText: '',
              //           hintText: "250".formatToPounds(),
              //           controller: _priceController,
              //           validator: (value) {
              //             if (value == null || value.isEmpty) {
              //               return 'price is required';
              //             } else {
              //               final price = double.tryParse(value) ?? 0;
              //               if (price < 5.0 || price > 10000000) {
              //                 return 'Invalid value';
              //               }
              //             }
              //             return null;
              //           },
              //           onChanged: (val) {
              //             setState(() {});
              //             final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
              //                   priceValue: double.parse(_priceController.text.trim()),
              //                 );
              //             ref.read(jobDataProvider.notifier).state = temp;
              //           },
              //           inputFormatters: [
              //             CurrencyTextInputFormatter.currency(
              //               customPattern: '.',
              //             ),
              //           ],
              //           keyboardType: TextInputType.number,
              //         ),
              //       ],
              //     ))
              //   ],
              // ),
              // addVerticalSpacing(15),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              // Flexible(
              //     child: VWidgetsDropdownNormal(
              //         value: talentType,
              //         fieldLabel: "Talent",
              //         itemToString: (val) => val.toString(),
              //         items: allUserTypes?.talents ?? [],
              //         onChanged: (val) {
              //           setState(() {
              //             talentType = val!;
              //           });
              //           final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
              //             talents: [talentType],
              //           );
              //           ref.read(jobDataProvider.notifier).state = temp;
              //         },
              //         validator: (val) {
              //           return null;
              //         })),
              // Flexible(
              //   child: VWidgetsDropDownTextField<String>(
              //     hintText: "",
              //     // options: const ["Model", "Artist", "Photographer"],
              //     options: allUserTypes?.talents ?? [],
              //     fieldLabel: "Talent",
              //     onChanged: (val) {
              //       setState(() {
              //         talentType = val;
              //       });
              //     },
              //     value: talentType,
              //     getLabel: (String value) => value,
              //   ),
              // ),
              // addHorizontalSpacing(10),
              // Flexible(
              //     child: VWidgetsDropdownNormal(
              //         value: preferredGender,
              //         fieldLabel: "Gender",
              //         itemToString: (val) => val.toString(),
              //         items: Gender.values,
              //         onChanged: (val) {
              //           setState(() {
              //             preferredGender = val!;
              //           });
              //           final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
              //                 preferredGender: preferredGender.apiValue,
              //               );
              //           ref.read(jobDataProvider.notifier).state = temp;
              //         },
              //         validator: (val) {
              //           return null;
              //         })),
              //   ],
              // ),
              NewFormRow(
                options: Gender.values.map((x) => x.simpleName).toList(),
                customValidator: (p0) {
                  return null;
                },
                fieldTitle: 'Gender',
                fieldValue: preferredGender.simpleName,
                onUpdate: (val) async {
                  setState(() {
                    preferredGender = Gender.values.where((x) => x.simpleName == val!).single;
                  });
                  final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                        preferredGender: preferredGender.apiValue,
                      );
                  ref.read(jobDataProvider.notifier).state = temp;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "Accepting multiple applicants",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  // CupertinoSwitch(value: value, onChanged: onChanged)
                  VWidgetsSwitch(
                    swicthValue: _isMultipleApplicants,
                    onChanged: (value) {
                      _isMultipleApplicants = value;
                      setState(() {});

                      final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                            acceptMultiple: _isMultipleApplicants,
                          );
                      ref.read(jobDataProvider.notifier).state = temp;
                    },
                  ),
                ],
              ),
              addVerticalSpacing(5),
              addVerticalSpacing(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Delivery Date",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.4)),
                  ),
                ],
              ),
              addVerticalSpacing(0),
              Padding(
                padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                child: TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2040),
                  focusedDay: _focusedDay,
                  eventLoader: (val) => [], //_getEventsForDay,
                  selectedDayPredicate: (day) {
                    // return _selectedDays.contains(day);
                    // return mySelectedDates.contains(day);
                    if (mySelectedDates.length <= 5) {
                      final wwx = ref.read(createJobNotifierProvider.notifier).containsDateTime(day);
                      return wwx;
                    } else {
                      return false;
                    }
                  },
                  onDaySelected: (date, fdate) async {
                    final moreThanAYear = date.difference(DateTime.now()).inDays > 365;
                    if (moreThanAYear) {
                      // SnackBarService().showSnackBar(
                      // message: 'Delivery date cannot exceed one year',
                      // context: context,
                      // icon: VIcons.noBlocked);
                      return;
                    }

                    setState(() {});
                    if (mySelectedDates.length <= 4) {
                      setState(() {});
                      await ref.read(createJobNotifierProvider.notifier).add(
                          dateTime: date,
                          start: timeOptions[18], //9:00am
                          end: timeOptions[34], //5:00pm
                          priceType: priceType);
                      ref.invalidate(calculatedTotalDurationProvider);
                      await ref.refresh(calculatedTotalDurationProvider);
                      setState(() {});
                    } else {
                      ref.read(createJobNotifierProvider.notifier).removeDateEntry(date);
                      return;
                    }
                  },

                  // _onDaySelected,
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  headerStyle: HeaderStyle(
                    titleTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          // color: Theme.of(context)
                        ),
                    leftChevronIcon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      // color: VmodelColors.primaryColor,
                      size: 20,
                      color: calendarChevronIconColor,
                    ),
                    formatButtonVisible: false,
                    titleCentered: true,
                    rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded,
                        // color: VmodelColors.primaryColor,
                        size: 20,
                        color: calendarChevronIconColor),
                  ),
                  calendarStyle: CalendarStyle(
                    todayTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    isTodayHighlighted: true,
                    todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        // color: VmodelColors.primaryColor,
                        // color: Theme.of(context).colorScheme.primary,
                        color: UIConstants.switchActiveColor(context),
                        shape: BoxShape.circle),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: Theme.of(context).textTheme.bodyMedium!,
                    weekendStyle: Theme.of(context).textTheme.bodyMedium!,
                  ),
                ),
              ),
              addVerticalSpacing(16),
              if (mySelectedDates.isNotEmpty)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Selected Dates",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    addVerticalSpacing(25),
                  ],
                ),
              Padding(
                padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //Date Formats
                  children: List.generate(mySelectedDates.length, (index) {
                    final selectedDate = mySelectedDates[index].date;

                    final date = DateFormat("MMMM dd, y").format(mySelectedDates[index].date);
                    final weekDay = DateFormat("EEEE").format(mySelectedDates[index].date);

                    return VWidgetsSelectedDateWidget(
                        selectedDate: date,
                        selectedDateDay: weekDay,
                        onTapCancel: () {
                          ref.read(createJobNotifierProvider.notifier).removeDateEntry(selectedDate);
                          setState(() {});
                        });
                  }),
                  // },
                ),
              ),
              addVerticalSpacing(16),
              const Divider(thickness: 1),
              addVerticalSpacing(16),
              Padding(
                padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(mySelectedDates.length, (index) {
                      final selectedDate = mySelectedDates[index];
                      final date = DateFormat("MMMM dd, y").format(mySelectedDates[index].date);
                      final weekDay = DateFormat("EEEE").format(mySelectedDates[index].date);

                      return VWidgetsSelectedDateTimeDurationWidget(
                        key: ValueKey(selectedDate.date.millisecondsSinceEpoch),
                        jobDeliveryDate: selectedDate,
                        dt: selectedDate.date,
                        startTime: selectedDate.startTime,
                        endTime: selectedDate.endTime,
                        dateTimeInMilliseconds: 2,
                        selectedDate: date,
                        selectedDateDay: weekDay,
                        durationForDate: (value) {
                          // //print(
                          //     'DDDDDDDDDDDDDDDDDDDdduration difference is ${value}');
                          // _dateTimeRes = value;
                          // setState(() {});
                        },
                      );
                    })
                    // },
                    ),
              ),
              addVerticalSpacing(0),
              if (mySelectedDates.isNotEmpty)
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: mySelectedDates.isEmpty ? 0 : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          // color: VmodelColors.white,
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                          border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const RenderSvgWithoutColor(
                            svgPath: VIcons.timer,
                            svgWidth: 28,
                            svgHeight: 28,
                          ),
                          addHorizontalSpacing(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Duration',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor),
                                ),
                                addVerticalSpacing(2),
                                RichText(
                                  text: TextSpan(
                                    text: '',
                                    children: List.generate(mySelectedDates.length, (index) {
                                      final dateDuration = mySelectedDates[index].dateDuration.dayHourMinuteSecondFormatted();
                                      if (index == mySelectedDates.length - 1) {
                                        return TextSpan(
                                            text: '$dateDuration '
                                                '${getHoursPluralize(mySelectedDates[index].dateDuration)}');
                                      }
                                      return TextSpan(
                                          //   text: "$dateDuration hrs + ",
                                          // );
                                          text: '$dateDuration '
                                              '${getHoursPluralize(mySelectedDates[index].dateDuration)} + ');
                                    }),
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          addHorizontalSpacing(16),
                          Text(
                            // '19',
                            calculatedDuration.dayHourMinuteSecondFormatted(),
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 24.sp, color: Theme.of(context).primaryColor),
                          ),
                          addHorizontalSpacing(4),
                          Text(
                            // 'HRS',
                            getHoursPluralize(calculatedDuration).toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 11, color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                    addVerticalSpacing(24),
                    if (priceType.simpleName != 'Service')
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text("Amount Payable: "),
                        Text(
                          "£${double.parse(_priceController.text) * double.parse(calculatedDuration.dayHourMinuteSecondFormatted())}",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        )
                      ]),
                    const Divider(thickness: 1),
                  ],
                ),
              addVerticalSpacing(25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "I have a creative brief",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        // color: VmodelColors.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: VWidgetsSwitch(
                      swicthValue: creativeBriefSwitchValue,
                      onChanged: (p0) {
                        setState(() {
                          creativeBriefSwitchValue = !creativeBriefSwitchValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(15),
              if (creativeBriefSwitchValue)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        VWidgetsDescriptionTextFieldWithTitle(
                          controller: _briefTextController,
                          label: "Create your brief (Optional)",
                          hintText: "Write in detail what work needs to be done",
                          minLines: 4,
                          maxLength: maxDescLength,
                          onChanged: (p0) {
                            final temp = ref.read(jobDataProvider.notifier).state?.copyWith(
                                  brief: p0,
                                );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "${maxDescLength - _briefTextController.text.length} characters remaining",
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                    addVerticalSpacing(25),
                    Text(
                      "Attach brief (optional)",
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          // color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                    addVerticalSpacing(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: VWidgetsPrimaryButton(
                            onPressed: () async {
                              final file = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );
                              if (file != null) {
                                setState(() => pickedBriefFile = file.files.single.xFile);
                                final uploadFile = await ref.read(createJobNotifierProvider.notifier).uploadFile(File(file.files.single.path!));
                                logger.d(uploadFile);
                                if (uploadFile != null) {
                                  setState(() => _briefFile = uploadFile['data']['urls'][0]);
                                }
                              }
                            },
                            showLoadingIndicator: ref.watch(breifFileUploadProgress) != 0.0,
                            buttonTitle: "Upload",
                            enableButton: true,
                          ),
                        ),
                        addHorizontalSpacing(10),
                        Flexible(
                            child: Container(
                          height: 40,
                          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.onSurface), borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(pickedBriefFile != null ? pickedBriefFile!.name : "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.displayMedium),
                                ),
                              ],
                            ),
                          ),
                        )),
                        addHorizontalSpacing(10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              pickedBriefFile = null;
                              _briefFile = null;
                            });
                          },
                          child: const RenderSvg(svgPath: VIcons.remove),
                        )
                      ],
                    ),
                    addVerticalSpacing(25),
                    VWidgetsPrimaryTextFieldWithTitle(
                      label: "Link to brief (Optional)",
                      hintText: "https://vmodel.app/brief-document.html",
                      controller: _briefLinkController,
                      keyboardType: TextInputType.url,
                      //validator: ValidationsMixin.isNotEmpty(value),
                      //keyboardType: TextInputType.emailAddress,
                      //onSaved: (){},
                      onChanged: (p0) {
                        ref.read(jobDataProvider.notifier).state?.copyWith(
                              briefLink: _briefLinkController.text,
                            );
                      },
                    ),
                  ],
                ),
              addVerticalSpacing(40),
              VWidgetsPrimaryButton(
                enableButton: true,
                onPressed: () {
                  _onContinue();
                },
                buttonTitle: "Continue",
              ),
              addVerticalSpacing(50)
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    VMHapticsFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Please fill required fields');
      return;
    } else if (mySelectedDates.isEmpty) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Please select a booking date');
      return;
    } else if (username.isEmpty) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Username is required to prroceed');
      return;
    }
    if (categoryType == null) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Please select a job category to proceed');
      return;
    }
    final temp = ref.read(jobDataProvider.notifier).state!.copyWith(
          jobTitle: _titleController.text.trim(),
          jobType: jobType!.apiValue,
          preferredGender: preferredGender.apiValue,
          priceOption: priceType.simpleName,
          priceValue: double.parse(_priceController.text.trim()),
          talents: [talentType],
          shortDescription: _shortDescriptionController.text,
          acceptMultiple: _isMultipleApplicants,
          brief: _briefTextController.text,
          briefLink: _briefLinkController.text,
          briefFile: _briefFile,
          category: categoryType,
          subCategory: subCategory,
        );
    //print(temp);
    ref.read(jobDataProvider.notifier).state = temp;

    ref.read(singleJobProvider.notifier).state = _job;
    context.push('/createRequestPage2/${jobType}/${username}');
  }

  String getHoursPluralize(Duration duration) {
    if (duration.inMinutes == 60) {
      return 'hr';
    }
    return 'hrs';
  }

  double getTotalPrice(Duration duration) {
    final price = double.tryParse(_priceController.text) ?? 0;
    return (duration.inMinutes / 60) * price;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  jobDialog(BuildContext context) {
    _isPopupClosed = false;
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isPopupClosed) goBack(context);
    });

    return showAnimatedDialog(
      context: context,
      child: VWidgetsPopUpWithoutSaveButton(
        // popupTitle: const Text(''),
        popupTitle: Text('Only ID Verified members can book on site jobs',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                // fontWeight: FontWeight.w600,
                // color: Theme.of(context).primaryColor,
                )),
      ),
    ).then((value) => _isPopupClosed = true);
  }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   setState(() {
  //     if (_selectedDays.contains(selectedDay)) {
  //       _selectedDays.remove(selectedDay);
  //     } else {
  //       _selectedDays.add(selectedDay);
  //     }
  //   });
  //   _selectedEvents!.value = _getEventsForDays(_selectedDays);
  //   _focusedDay = focusedDay;
  // }

  /// Remove selected dates
  void _removeSelectedDate(DateTime selectedDay) {
    if (mySelectedDates.contains(JobDeliveryDate.fromMap({"date": selectedDay.toIso8601String().split("T")[0], "startTime": selectedDay.toIso8601String().split("T")[1]}))) {
      //print("object");
      _selectedDays.remove(selectedDay);
    }
    setState(() {});
  }

  /// Single Selection Function of date[When Price type is "Per service iin create a job first Page"]
  void _singleDateSelection(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.isEmpty) {
        _selectedDays.add(selectedDay);
      } else {
        _selectedDays.clear();
        _selectedDays.add(selectedDay);
      }
    });
    _selectedEvents!.value = _getEventsForDays(_selectedDays);
    _focusedDay = focusedDay;
  }
}
