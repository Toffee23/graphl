import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vmodel/src/core/utils/enum/deliverables_type.dart';
import 'package:vmodel/src/core/utils/enum/license_type.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_field.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/costants.dart';
import '../../../../core/utils/enum/ethnicity_enum.dart';
import '../../../../core/utils/enum/size_enum.dart';
import '../../../../res/icons.dart';
import '../../../../shared/rend_paint/render_svg.dart';
import '../../../../shared/switch/primary_switch.dart';
import '../../../../shared/text_fields/description_text_field.dart';
import '../../../jobs/create_jobs/controller/create_job_controller.dart';

final dates = StateProvider.autoDispose<List>((ref) => []);

class CreateBookingSecondPage extends ConsumerStatefulWidget {
  // final String isPricePerService;
  const CreateBookingSecondPage(
      {super.key, required this.jobType, required this.service
      //  required this.isPricePerService
      });
  final String jobType;
  final ServicePackageModel service;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateBookingSecondPageState();
}

class _CreateBookingSecondPageState
    extends ConsumerState<CreateBookingSecondPage> {
  double slideValue = 18;
  double amountSlide = 0;

  String jobType = "On-site";
  String duration = "Full-Day";
  String arrivalTime = "Morning";
  String gender = "Male";
  Ethnicity ethinicity = Ethnicity.values.first;
  String budget = "Per Day";
  String identifiedGender = "Indentified Gender";
  String heightInches = "1";
  String heightFeet = "5";
  ModelSize size = ModelSize.values.first; //= "XL";
  String complexion = "Dark/Melanin";
  bool isDigitalContent = true;
  LicenseType usageType = LicenseType.values.first; //"Usage type";
  String usageLength = VConstants.kUsageLengthOptions.first; //"Usage Length";
  List<String> _usageLengthOptions = [];
  final RangeValues _ageRangeValues = const RangeValues(18, 30);
  final String _selectedLocation = "";

  TextEditingController dateTime = TextEditingController();
  // final _locationController = TextEditingController();
  // final _deliverablesController = TextEditingController();
  DeliverablesType deliverableType = DeliverablesType.values.first;
  final _heightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool creativeBriefSwitchValue = false;
  String talentType = "Model";
  String height = "5'11";
  String weight = "XL";
  String deliveryDateType = "Range";

  String preferredGender = "Male";
  String? _briefFile;
  XFile? pickedBriefFile;

  // @override
  // bool get wantKeepAlive => true;

  final _briefTextController = TextEditingController();
  final _briefLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //Taking out the last option from the usage length options
    _usageLengthOptions = VConstants.kUsageLengthOptions
        .sublist(0, VConstants.kUsageLengthOptions.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final tempJobData = ref.watch(jobDataProvider);
    return Portal(
      child: Scaffold(
        appBar: VWidgetsAppBar(
          appBarHeight: 50,
          leadingIcon: const VWidgetsBackButton(),

          appbarTitle: "Create a booking",
          // trailingIcon: [
          //   Padding(
          //     padding: const EdgeInsets.only(top: 12),
          //     child: VWidgetsTextButton(
          //       text: 'Create',
          //       //Implement the logic here
          //       onPressed: () {},
          //     ),
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
                addVerticalSpacing(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "I have a creative brief",
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                              // color: VmodelColors.primaryColor,
                              fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: VWidgetsSwitch(
                        swicthValue: creativeBriefSwitchValue,
                        onChanged: (p0) {
                          setState(() {
                            creativeBriefSwitchValue =
                                !creativeBriefSwitchValue;
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
                      VWidgetsDescriptionTextFieldWithTitle(
                        controller: _briefTextController,
                        label: "Create your brief (Optional)",
                        hintText: "Write in detail what work needs to be done",
                        minLines: 4,
                      ),
                      addVerticalSpacing(25),
                      Text(
                        "Attach brief (optional)",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addVerticalSpacing(5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: VWidgetsPrimaryButton(
                              onPressed: () async {
                                final file =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                );
                                if (file != null) {
                                  setState(() => pickedBriefFile =
                                      file.files.single.xFile);
                                  final uploadFile = await ref
                                      .read(createJobNotifierProvider.notifier)
                                      .uploadFile(
                                          File(file.files.single.path!));
                                  logger.d(uploadFile);
                                  if (uploadFile != null) {
                                    setState(() => _briefFile =
                                        uploadFile['data']['urls'][0]);
                                  }
                                }
                              },
                              showLoadingIndicator:
                                  ref.watch(breifFileUploadProgress) != 0.0,
                              buttonTitle: "Upload",
                              enableButton: true,
                            ),
                          ),
                          addHorizontalSpacing(10),
                          Flexible(
                              child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                        pickedBriefFile != null
                                            ? pickedBriefFile!.name
                                            : "",
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium),
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

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Flexible(
                      //       child: VWidgetsPrimaryButton(
                      //         onPressed: () {},
                      //         buttonTitle: "Upload",
                      //         enableButton: true,
                      //       ),
                      //     ),
                      //     addHorizontalSpacing(10),
                      //     Flexible(
                      //         child: Container(
                      //       height: 40,
                      //       decoration: BoxDecoration(
                      //           border: Border.all(
                      //             // color: VmodelColors.primaryColor,
                      //             color:
                      //                 Theme.of(context).colorScheme.onSurface,
                      //           ),
                      //           borderRadius: BorderRadius.circular(8)),
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Row(
                      //           children: [
                      //             Flexible(
                      //               child: Text("File Name.extension",
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: Theme.of(context)
                      //                       .textTheme
                      //                       .displayMedium),
                      //             ),
                      //             GestureDetector(
                      //               onTap: () {},
                      //               child: const RenderSvg(
                      //                   svgPath: VIcons.galleryDelete),
                      //             )
                      //           ],
                      //         ),
                      //       ),
                      //     ))
                      //   ],
                      // ),
                      addVerticalSpacing(25),
                      VWidgetsPrimaryTextFieldWithTitle(
                        label: "Link to brief (Optional)",
                        hintText: "https://vmodel.app/brief-document.html",
                        controller: _briefLinkController,
                        //validator: ValidationsMixin.isNotEmpty(value),
                        //keyboardType: TextInputType.emailAddress,
                        //onSaved: (){},
                      ),
                      addVerticalSpacing(10),
                    ],
                  ),
                // addVerticalSpacing(10),
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
                // VWidgetsPrimaryTextFieldWithTitle(
                //   controller: _deliverablesController,
                //   label: "Deliverables type (Required)",
                //   hintText: "Eg. What do you expect to receive?",
                //   validator: VValidatorsMixin.isNotEmpty,
                //   isIncreaseHeightForErrorText: true,
                //   //keyboardType: TextInputType.emailAddress,
                //   //onSaved: (){},
                // ),
                addVerticalSpacing(8),
                VWidgetsDropDownTextField<bool>(
                  fieldLabel: "Are you receiving any digital content?",
                  hintText: "",
                  onChanged: (val) {
                    setState(() {
                      isDigitalContent = val;
                    });
                  },
                  value: isDigitalContent,
                  // options: const ["Yes", "No"],
                  options: const [false, true],
                  // getLabel: (String value) => value,
                  customDisplay: (value) => value ? "Yes" : "No",
                ),
                if (isDigitalContent)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: VWidgetsDropDownTextField<LicenseType>(
                          fieldLabel: "License",
                          hintText: "",
                          onChanged: (val) {
                            setState(() {
                              usageType = val;
                            });
                          },
                          value: usageType,
                          // options: const ["Usage type", "Usage type 2"],
                          options: LicenseType.values,
                          getLabel: (LicenseType value) => value.simpleName,
                        ),
                      ),
                      addHorizontalSpacing(10),
                      Expanded(
                        child: VWidgetsDropDownTextField(
                          fieldLabel: "",
                          hintText: "",
                          onChanged: (val) {
                            setState(() {
                              usageLength = val;
                            });
                          },
                          value: usageLength,
                          // options: const ["Usage Length", "Usage Length 2"],
                          options: _usageLengthOptions,
                          getLabel: (String value) => value,
                        ),
                      ),
                    ],
                  ),
                addVerticalSpacing(25),
                VWidgetsPrimaryButton(
                  enableButton: true,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      VWidgetShowResponse.showToast(ResponseEnum.warning,
                          message: "Please fill all required fields");
                      return;
                    }

                    showAnimatedDialog(
                      barrierColor: Colors.black54,
                      context: context,
                      child: Consumer(builder: (context, ref, child) {
                        return LoaderProgress(
                          done: !ref.watch(_bookingSercviceLoader),
                          loading: ref.watch(_bookingSercviceLoader),
                        );
                      }),
                    );

                    final bookingData = BookingData(
                      module: BookingModule.SERVICE,
                      moduleId: widget.service.id,
                      title: widget.service.title,
                      price: (widget.service.price +
                          (ref.watch(serviceBookingExpressDelivery)
                              ? widget.service.expressDelivery!.price
                              : 0) +
                          (widget.service.travelFee?.price ?? 0) +
                          (ref.read(serviceTierPriceProvider) ?? 0)),
                      pricingOption:
                          BookingData.getPricingOptionFromServicePeriod(
                              widget.service.servicePricing),
                      bookingType: BookingData.getBookingType(
                          widget.service.serviceLocation.simpleName),
                      // bookingType: BookingType.ON_LOCATION,
                      haveBrief: creativeBriefSwitchValue,
                      deliverableType: widget.service.deliverablesType ?? '',
                      expectDeliverableContent: isDigitalContent,
                      usageType: null,
                      usageLength: null,
                      brief: _briefTextController.text,
                      briefLink: _briefLinkController.text,
                      briefFile: _briefFile,
                      bookedUser: widget.service.user!.username,
                      startDate: DateTime.now(),
                      address: {
                        "latitude": "0",
                        "longitude": "0",
                        "locationName": widget.service.serviceLocation ==
                                WorkLocation.clientsLocation
                            ? ref.read(servicebookingAddressProvider)
                            : widget.service.serviceLocation ==
                                    WorkLocation.myLocation
                                ? widget.service.user?.businessAddress
                                    .toString()
                                : WorkLocation.remote,
                      },
                    );

                    /// returns bookings with pending payment
                    final pendingBooking =
                        await ref.read(pendingPaymentBookingsProvider.future);

                    /// a check would be attached to see if there's already an ongoing booking
                    /// so as to choose if to create a new bookingid or use the currently initiated version
                    final bookingId = ref.read(currentBookingIdProvider) != null
                        ? ref.read(currentBookingIdProvider)
                        : pendingBooking
                                .where((x) =>
                                    x.moduleId.toString() == widget.service.id)
                                .isNotEmpty
                            ? pendingBooking
                                .firstWhere((x) =>
                                    x.moduleId.toString() == widget.service.id)
                                .id
                            : await ref.read(
                                createBookingProvider(bookingData).future);

                    ///attach initiated booking to currentBookingIdProvider
                    ref.read(currentBookingIdProvider.notifier).state =
                        bookingId;

                    if (bookingId != null) {
                      await ref
                          .read(bookingPaymentNotifierProvider.notifier)
                          .createBookingPayment(bookingId);
                      ref.read(bookingPaymentNotifierProvider).whenOrNull(
                          error: (e, _) {
                        Navigator.of(
                          context,
                        ).pop();
                        SnackBarService().showSnackBarError(context: context);
                      }, data: (paymentIntent) async {
                        await ref
                            .read(bookingPaymentNotifierProvider.notifier)
                            .makePayment(paymentIntent['clientSecret']);
                        ref.read(bookingPaymentNotifierProvider).whenOrNull(
                          error: (e, _) {
                            Navigator.of(
                              context,
                            ).pop();
                            SnackBarService()
                                .showSnackBarError(context: context);
                          },
                          data: (_) {
                            Future.delayed(Duration(seconds: 2), () async {
                              ref.read(_bookingSercviceLoader.notifier).state =
                                  false;
                              SnackBarService().showSnackBar(
                                  message: "Service booked successfully",
                                  context: context);
                              Navigator.of(
                                context,
                              ).pop();
                              Navigator.of(context)
                                ..pop()
                                ..pop();
                            });
                          },
                        );
                      });
                    } else {
                      Navigator.of(
                        context,
                      ).pop();
                    }
                  },
                  buttonTitle: "Continue to payment",
                ),
                addVerticalSpacing(50)
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// dialog loader provider for booking process
  final _bookingSercviceLoader = StateProvider.autoDispose((ref) => true);
}
