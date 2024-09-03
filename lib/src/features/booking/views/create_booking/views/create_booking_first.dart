import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/core/utils/extensions/hex_color.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/booking/controller/calendar_event.dart';
import 'package:vmodel/src/features/jobs/create_jobs/widgets/selected_date_time_slots_widget.dart';
import 'package:vmodel/src/features/jobs/create_jobs/widgets/selected_date_widget.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/controller/booking_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/enums/tiers_enum.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/html_description_widget.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../../core/utils/enum/work_location.dart';
import '../../../../../shared/text_fields/dropdown_text_normal.dart';
import '../../../../../shared/text_fields/places_autocomplete_field.dart';
import '../../../../authentication/register/provider/user_types_controller.dart';
import '../../../../jobs/create_jobs/controller/create_job_controller.dart';
import '../../../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../../../../settings/views/booking_settings/controllers/unavailable_days_controller.dart';
import '../../../../settings/views/booking_settings/models/service_package_model.dart';

/// [CreateBookingFirstPage] creates bookings for services, [username] is requried feild for getting the service detail
/// [displayName] is required for the app title and also the [serviceId] can also be used for also getting the service detail
class CreateBookingFirstPage extends ConsumerStatefulWidget {
  const CreateBookingFirstPage({
    super.key,
    required this.username,
    required this.displayName,
    this.unavailableDates,
    required this.serviceId,
    this.tier,
    this.serviceTierPrice,
  });
  final String username;
  final String displayName;
  final List<DateTime>? unavailableDates;
  final String serviceId;

  final ServiceTiers? tier;
  final double? serviceTierPrice;

  @override
  ConsumerState<CreateBookingFirstPage> createState() =>
      _CreateBookingFirstPageState();
}

class _CreateBookingFirstPageState
    extends ConsumerState<CreateBookingFirstPage> {
  double slideValue = 18;
  double amountSlide = 0;
  bool creativeBriefSwitchValue = false;
  String jobType = "Remote";
  late ServicePeriod priceType;
  String talentType = "Model";
  String duration = "Full-Day";
  String arrivalTime = "Morning";
  String gender = "Male";
  String ethinicity = "Asian";
  String budget = "Per Day";
  String identifiedGender = "Indentified Gender";
  String height = "5'11";
  String weight = "XL";
  String complexion = "Dark/Melanin";
  String deliveryDateType = "Range";

  String preferredGender = "Male";
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
  final bool _isMultipleApplicants = false;
  String _selectedLocation = "";
  List<DateTime>? unavailableDates = [];

  final mockServices = const [
    "I will be your model for 3 hours",
    "I wil shoot a video for your event",
    "Contact me for to capture your memorable moments"
  ];

  ServicePackageModel? selectedMockService;

  late ServiceTiers serviceTier = widget.tier ?? ServiceTiers.basic;

  // List<Duration> startTimes = [];

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay));
    _selectedDays = LinkedHashSet<DateTime>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    // selectedMockService = mockServices.first;
    // startTimes =
    //     List.generate(48, (index) => Duration(minutes: index * 30)).toList();
    // startTimeDurationValue = startTimes[18];
    // endTimeDurationValue = startTimes[34];
    priceType = ServicePeriod.values.last;
    // final startT = DateTime.now();
    // final endT = startT.add(Duration(hours: 8));
    // _dateTimeRes = endT.difference(startT);
    unavailableDates = widget.unavailableDates;
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
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
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
    if (_selectedDays.contains(selectedDay)) {
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

  bool _isDateDisabled(DateTime day) {
    var date = DateTime.parse(day.toIso8601String().split("T")[0]);
    if (widget.unavailableDates!.isNotEmpty) {
      //print(widget.unavailableDates![0]);
      return widget.unavailableDates!.contains(date);
    } else {
      return false;
    }
  }

  bool expressDelivery = false;
  late double? serviceTierPrice = widget.serviceTierPrice;

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicePackagesProvider(widget.username));
    final mySelectedDates = ref.watch(createJobNotifierProvider);
    final calculatedDuration = ref.watch(calculatedTotalDurationProvider);
    final timeOptions = ref.watch(timeOpProvider);
    final userTypes = ref.watch(accountTypesProvider);
    final allUserTypes = userTypes.valueOrNull;
    final tempJobData = ref.watch(jobDataProvider);
    if (unavailableDates == null) {
      unavailableDates = [];
      final temp =
          ref.watch(unavailableDaysProvider(widget.username)).valueOrNull ?? [];
      for (var data in temp) {
        unavailableDates!.add(data.date!);
      }
    }

    /// this autoDisposable provider is initialized here so whenever so once this context
    /// the provider is disposed and its likely not used in this page
    ref.watch(currentBookingIdProvider);

    return PopScope(
      onPopInvoked: (_) {
        ref.invalidate(createJobNotifierProvider);
      },
      child: Portal(
        child: Scaffold(
          appBar: VWidgetsAppBar(
            appBarHeight: 50,
            leadingIcon: VWidgetsBackButton(
              onTap: () {
                goBack(context);
                ref.invalidate(createJobNotifierProvider);
              },
            ),
            appbarTitle: "Book ${widget.displayName}",
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              color: !context.isDarkMode
                  ? "e3e8ee".fromHex
                  : "191919".fromHex,
              border: Border.all(
                color: !context.isDarkMode
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(children: [
              Text('Total booking fee',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              Spacer(),
              // RichText(
              //   text:TextSpan(
              //     children: [
              //       TextSpan(
              //         text: ''
              //       )
              //     ]
              //   )
              // ),

              Text(
                  ref
                      .watch(serviceBookingTotalPriceProvider)
                      .toString()
                      .formatToPounds(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ]),
          ),
          body: SingleChildScrollView(
            padding: const VWidgetsPagePadding.horizontalSymmetric(10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addVerticalSpacing(20),

                  services.when(data: (items) {
                    if (items.isEmpty) return Text('User has no services.');

                    final nonPausedServices =
                        items.where((element) => !element.paused).toList();

                    selectedMockService ??= items
                            .where((e) => e.id == widget.serviceId)
                            .firstOrNull ??
                        nonPausedServices.first;

                    final service = items
                        .where((e) => e.id == widget.serviceId)
                        .singleOrNull;

                    if (service != null) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        ref
                                .read(serviceBookingTotalPriceProvider.notifier)
                                .state =
                            calculateDiscountedAmount(
                                price: ((serviceTierPrice ?? service.price) +
                                    (ref.watch(serviceBookingExpressDelivery)
                                        ? service.expressDelivery!.price
                                        : 0) +
                                    (service.travelFee?.price ?? 0) +
                                    (ref.watch(serviceBookingAddProvider) ??
                                        0)),
                                discount: service.percentDiscount);
                      });
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // addHorizontalSpacing(10),
                                        // if (!bannerUrl.isEmptyOrNull)
                                        RoundedSquareAvatar(
                                          // borderRadius: BorderRadius.only(
                                          //     topLeft: Radius.circular(10),
                                          //     bottomLeft: Radius.circular(10)),
                                          url: service.banner.first.thumbnail,
                                          thumbnail:
                                              service.banner.first.thumbnail,
                                          size: Size(130, 110),
                                        ),
                                        // addHorizontalSpacing(10),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        service.title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayLarge!
                                                            .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // if (showDescription!) ...[
                                                addVerticalSpacing(02),
                                                if (service.serviceType != null)
                                                  if (service.serviceSubType !=
                                                      null)
                                                    Text(
                                                      service
                                                          .serviceSubType!.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors
                                                                .grey.shade400,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    )
                                                  else
                                                    Text(
                                                      service.serviceType!.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors
                                                                .grey.shade400,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    )
                                                else
                                                  HtmlDescription(
                                                    content:
                                                        service.description,
                                                    style: Style(
                                                        margin: Margins.zero,
                                                        height: Height(40),
                                                        fontSize: FontSize(14),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        maxLines: 2,
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis),
                                                  ),
                                                addVerticalSpacing(5),
                                                // Text(
                                                //   serviceDescription,
                                                //   maxLines: 2,
                                                //   overflow: TextOverflow.ellipsis,
                                                //   style: Theme.of(context)
                                                //       .textTheme
                                                //       .displaySmall!
                                                //       .copyWith(
                                                //         fontSize: 12,
                                                //         fontWeight: FontWeight.w400,
                                                //       ),
                                                // ),
                                                // ],
                                                // addVerticalSpacing(06),
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: !context
                                                                .isDarkMode
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.white,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 10),
                                                      child: Text(
                                                        'Per ${service.servicePricing.simpleName}', // e.msg.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: !context
                                                                      .isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                    addHorizontalSpacing(5),
                                                    // Icon(Icons.pin_drop_rounded, size: 18),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: !context
                                                                .isDarkMode
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.white,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 10),
                                                      child: Text(
                                                        service.serviceLocation
                                                            .simpleName, // e.msg.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: !context
                                                                      .isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                addVerticalSpacing(15),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    addVerticalSpacing(20),
                                    Row(children: [
                                      Text('Service Price',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              )),
                                      Spacer(),
                                      Text(
                                        // "${VMString.poundSymbol} $jobBudget",
                                        // "${VMString.poundSymbol} 1.5M",
                                        VConstants.noDecimalCurrencyFormatterGB
                                            .format(calculateDiscountedAmount(
                                                    price: serviceTierPrice ??
                                                        service.price,
                                                    discount:
                                                        service.percentDiscount)
                                                .round()),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ]),
                                    if (service.percentDiscount != 0) ...[
                                      addVerticalSpacing(20),
                                      Row(children: [
                                        Text(
                                            '${service.percentDiscount}% Discount',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                        Spacer(),
                                        Text(
                                          // "${VMString.poundSymbol} $jobBudget",
                                          // "${VMString.poundSymbol} 1.5M",
                                          '(${VConstants.noDecimalCurrencyFormatterGB.format((serviceTierPrice ?? service.price * service.percentDiscount) / 100)} Off)',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ]),
                                      addVerticalSpacing(10),
                                    ]
                                  ],
                                ),
                              )),
                          addVerticalSpacing(10),
                          if (service.serviceTier
                                      .singleWhere((x) => x.tier == serviceTier)
                                      .addons
                                      .firstOrNull !=
                                  null ||
                              service.expressDelivery != null) ...[
                            Text('Additional Services'),
                            Card(
                                child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (service.expressDelivery != null) ...[
                                    Text('Express Delivery',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                    Row(children: [
                                      Text(
                                          '${service.expressDelivery!.delivery} ${service.expressDelivery!.price.toString().formatToPounds()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                                // fontWeight: FontWeight.bold,
                                              )),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          ref
                                                  .read(
                                                      serviceBookingExpressDelivery
                                                          .notifier)
                                                  .state =
                                              !ref.read(
                                                  serviceBookingExpressDelivery);
                                        },
                                        child: Icon(
                                          ref.watch(
                                                  serviceBookingExpressDelivery)
                                              ? Icons.check_circle
                                              : Icons.add_circle_outline,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.6),
                                        ),
                                      )
                                    ]),
                                    addVerticalSpacing(15),
                                  ],
                                  if (service.serviceTier
                                      .singleWhere((x) => x.tier == serviceTier)
                                      .addons
                                      .isNotEmpty) ...[
                                    Text('Addons',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                    Row(children: [
                                      Text(
                                          '${service.serviceTier.singleWhere((x) => x.tier == serviceTier).addons.firstOrNull?.name} at ${service.serviceTier.singleWhere((x) => x.tier == serviceTier).addons.firstOrNull?.price.toString().formatToPounds()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.6),
                                                // fontWeight: FontWeight.bold,
                                              )),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          if (ref.read(
                                                  serviceBookingAddProvider) !=
                                              null) {
                                            ref
                                                .read(serviceBookingAddProvider
                                                    .notifier)
                                                .state = null;
                                            return;
                                          }
                                          ref
                                                  .read(
                                                      serviceBookingAddProvider
                                                          .notifier)
                                                  .state =
                                              service.serviceTier
                                                  .singleWhere((x) =>
                                                      x.tier == serviceTier)
                                                  .addons
                                                  .firstOrNull
                                                  ?.price;
                                        },
                                        child: Icon(
                                          ref.watch(serviceBookingAddProvider) !=
                                                  null
                                              ? Icons.check_circle
                                              : Icons.add_circle_outline,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.6),
                                        ),
                                      )
                                    ]),
                                    addVerticalSpacing(15),
                                  ]
                                ],
                              ),
                            ))
                          ]
                        ],
                      );
                    } else {
                      return VWidgetsDropdownNormal(
                        validator: null,
                        items: nonPausedServices,
                        isExpanded: true,
                        fieldLabel: "Select Gig or Service",
                        onChanged: (val) {
                          setState(() {
                            selectedMockService = val;
                          });
                        },
                        value: selectedMockService,
                        itemToString: (value) => value.title,
                        // heightForErrorText: 0,
                      );
                    }
                  }, error: ((error, stackTrace) {
                    return Center(
                      child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator.adaptive(
                              strokeWidth: 3)),
                    );
                  }), loading: () {
                    return Text('No services');
                  }),

                  addVerticalSpacing(10),
                  if (selectedMockService?.serviceType ==
                      WorkLocation.clientsLocation) ...[
                    addVerticalSpacing(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PlacesAutocompletionField(
                        label: "Address",
                        hintText: "Start typing address...",
                        isFollowerTop: false,
                        onItemSelected: (value) {
                          if (!mounted) return;
                          _selectedLocation = value['description'];

                          ref
                              .read(servicebookingAddressProvider.notifier)
                              .state = _selectedLocation;
                        },
                        postOnChanged: (String value) {},
                      ),
                    ),
                    addVerticalSpacing(8),
                  ],
                  // if (selectedMockService?.expressDelivery != null)
                  //   Card(
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(10),
                  //       child: Column(
                  //         children: [
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text(
                  //                 'Express Delivery',
                  //                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  //                       fontWeight: FontWeight.bold,
                  //                     ),
                  //               ),
                  //               VWidgetsSwitch(
                  //                   swicthValue: ref.watch(serviceBookingExpressDelivery), onChanged: (value) => setState(() => ref.read(serviceBookingExpressDelivery.notifier).state = value)),
                  //             ],
                  //           ),
                  //           // addVerticalSpacing(5),
                  //           Row(
                  //             children: [
                  //               Row(
                  //                 children: [
                  //                   Icon(Icons.schedule_rounded),
                  //                   addHorizontalSpacing(2),
                  //                   Text(
                  //                     selectedMockService!.expressDelivery!.delivery,
                  //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                   ),
                  //                 ],
                  //               ),
                  //               Spacer(),
                  //               Text(
                  //                 'Fee',
                  //                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //                       fontWeight: FontWeight.bold,
                  //                     ),
                  //               ),
                  //               addHorizontalSpacing(2),
                  //               Text(
                  //                 selectedMockService!.expressDelivery!.price.toString().formatToPounds(),
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //                 style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  //                       color: context.isDarkMode ? null : Theme.of(context).primaryColor,
                  //                       fontWeight: FontWeight.bold,
                  //                       fontSize: 20,
                  //                     ),
                  //               )
                  //             ],
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),

                  addVerticalSpacing(10),
                  Padding(
                    padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                    child: TableCalendar(
                      availableGestures: AvailableGestures.horizontalSwipe,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      firstDay: DateTime.now(),
                      lastDay: DateTime(2040),
                      focusedDay: _focusedDay,
                      enabledDayPredicate: (day) {
                        var date =
                            DateTime.parse(day.toIso8601String().split("T")[0]);
                        if (unavailableDates!.isNotEmpty) {
                          return !unavailableDates!.contains(date);
                        } else {
                          return true;
                        }
                      },
                      eventLoader: (val) => [], //_getEventsForDay,
                      selectedDayPredicate: (day) {
                        // return _selectedDays.contains(day);
                        // return mySelectedDates.contains(day);
                        return ref
                            .read(createJobNotifierProvider.notifier)
                            .containsDateTime(day);
                      },
                      onDaySelected: (date, fdate) {
                        // priceType == ServicePeriod.service
                        // ? _singleDateSelection(date, fdate)
                        // : _onDaySelected(date, fdate);
                        setState(() {});
                        ref.read(createJobNotifierProvider.notifier).add(
                            dateTime: date,
                            start: timeOptions[18], //9:00am
                            end: timeOptions[34], //5:00pm
                            priceType: priceType);

                        // Future.delayed(Duration(seconds: 1), () {
                        //   setState(() {});
                        // });
                      },

                      // _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      headerStyle: HeaderStyle(
                        titleTextStyle:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  // color: Theme.of(context).primaryColor,
                                ), // VWidgetsDropDownTextField(
                        //   fieldLabel: "Delivery date type",
                        //   hintText: "",
                        //   onChanged: (val) {
                        //     setState(() {
                        //       deliveryDateType = val;
                        //     });
                        //   },
                        //   value: deliveryDateType,
                        //   options: const ["Range", "Range 2"],
                        //   getLabel: (String value) => value,
                        // ),
                        leftChevronIcon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          // color: VmodelColors.primaryColor,
                          size: 20,
                        ),
                        formatButtonVisible: false,
                        titleCentered: true,
                        rightChevronIcon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          // color: VmodelColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayTextStyle:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        isTodayHighlighted: true,
                        todayDecoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                            // color: VmodelColors.primaryColor,
                            color: Theme.of(context).colorScheme.primary,
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
                              "Expected delivery",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                        addVerticalSpacing(25),
                      ],
                    ),
                  // Padding(
                  //     padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                  //     child: ListView.builder(
                  //       // key: UniqueKey(),
                  //       physics: const NeverScrollableScrollPhysics(),
                  //       shrinkWrap: true,
                  //       // cacheExtent: 1000,
                  //       itemCount: _selectedDays!.length,
                  //       itemBuilder: (context, index) {
                  //         //Date Formats
                  //         final selectedDate = _selectedDays!.toList()[index];
                  //         final date = DateFormat("MMMM dd, y")
                  //             .format(_selectedDays!.toList()[index]);
                  //         final weekDay = DateFormat("EEEE")
                  //             .format(_selectedDays!.toList()[index]);

                  //         return VWidgetsSelectedDateWidget(
                  //             selectedDate: date,
                  //             selectedDateDay: weekDay,
                  //             onTapCancel: () {
                  //               setState(() {
                  //                 _removeSelectedDate(selectedDate);
                  //               });
                  //             });
                  //       },
                  //     )),
                  //just now
                  Padding(
                    padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                    child: Column(
                      // key: UniqueKey(),
                      // physics: const NeverScrollableScrollPhysics(),
                      // shrinkWrap: true,
                      // cacheExtent: 1000,
                      // itemCount: _selectedDays!.length,
                      // itemBuilder: (context, index) {
                      mainAxisSize: MainAxisSize.min,
                      //Date Formats
                      children: List.generate(mySelectedDates.length, (index) {
                        final selectedDate = mySelectedDates[index];
                        final date = DateFormat("MMMM dd, y")
                            .format(mySelectedDates[index].date);
                        final weekDay = DateFormat("EEEE")
                            .format(mySelectedDates[index].date);

                        return VWidgetsSelectedDateWidget(
                            selectedDate: date,
                            selectedDateDay: weekDay,
                            onTapCancel: () {
                              // setState(() {
                              //   _removeSelectedDate(selectedDate);
                              // });
                            });
                      }),
                      // },
                    ),
                  ),
                  addVerticalSpacing(16),
                  const Divider(thickness: 1),
                  addVerticalSpacing(16),
                  // Padding(
                  //     padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                  //     child: ListView.builder(
                  //       // key: UniqueKey(),
                  //       physics: const NeverScrollableScrollPhysics(),
                  //       shrinkWrap: true,
                  //       // cacheExtent: 1000,
                  //       itemCount: _selectedDays.length,
                  //       itemBuilder: (context, index) {
                  //         //Date Formats
                  //         final date = DateFormat("MMMM dd, y")
                  //             .format(_selectedDays.toList()[index]);
                  //         final weekDay = DateFormat("EEEE")
                  //             .format(_selectedDays.toList()[index]);

                  //         return VWidgetsSelectedDateTimeDurationWidget(
                  //           dateTimeInMilliseconds:
                  //               _selectedDays.toList()[index].millisecondsSinceEpoch,
                  //           selectedDate: date,
                  //           selectedDateDay: weekDay,
                  //           durationForDate: (value) {
                  //             // print(
                  //             //     'DDDDDDDDDDDDDDDDDDDdduration difference is ${value}');
                  //             // _dateTimeRes = value;
                  //             // setState(() {});
                  //           },
                  //         );
                  //       },
                  //     )),
                  Padding(
                    padding: const VWidgetsPagePadding.horizontalSymmetric(0),
                    child: Column(
                        // key: UniqueKey(),
                        mainAxisSize: MainAxisSize.min,
                        // cacheExtent: 1000,
                        // itemCount: _selectedDays.length,
                        // itemBuilder: (context, index) {
                        //Date Formats
                        children:
                            List.generate(mySelectedDates.length, (index) {
                          final selectedDate = mySelectedDates[index];
                          final date = DateFormat("MMMM dd, y")
                              .format(mySelectedDates[index].date);
                          final weekDay = DateFormat("EEEE")
                              .format(mySelectedDates[index].date);

                          return VWidgetsSelectedDateTimeDurationWidget(
                            key: ValueKey(
                                selectedDate.date.millisecondsSinceEpoch),
                            jobDeliveryDate: selectedDate,
                            dt: selectedDate.date,
                            startTime: selectedDate.startTime,
                            endTime: selectedDate.endTime,
                            dateTimeInMilliseconds: 2,
                            selectedDate: date,
                            selectedDateDay: weekDay,
                            durationForDate: (value) {
                              // print(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: context.theme.colorScheme.onPrimary
                                  .withOpacity(0.2),
                              border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).primaryColor),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                    ),
                                    addVerticalSpacing(2),
                                    RichText(
                                      text: TextSpan(
                                        text: '',
                                        children: List.generate(
                                            mySelectedDates.length, (index) {
                                          final dateDuration = mySelectedDates[
                                                  index]
                                              .dateDuration
                                              .dayHourMinuteSecondFormatted();
                                          if (index ==
                                              mySelectedDates.length - 1) {
                                            return TextSpan(
                                                text:
                                                    '$dateDuration ${getHoursPluralize(mySelectedDates[index].dateDuration)}');
                                          }
                                          return TextSpan(
                                            text:
                                                "$dateDuration ${getHoursPluralize(mySelectedDates[index].dateDuration)} + ",
                                          );
                                        }),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              addHorizontalSpacing(16),
                              Text(
                                // '19',
                                calculatedDuration
                                    .dayHourMinuteSecondFormatted(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24.sp,
                                        color: Theme.of(context).primaryColor),
                              ),
                              addHorizontalSpacing(4),
                              Text(
                                'HRS',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                        color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  addVerticalSpacing(32),
                  VWidgetsPrimaryButton(
                    enableButton: true,
                    onPressed: () {
                      VMHapticsFeedback.lightImpact();
                      // if (!_formKey.currentState!.validate()) {
                      //   VWidgetShowResponse.showToast(ResponseEnum.warning,
                      //       message: 'Please fill required fields');
                      //   return;
                      // } else if (mySelectedDates.isEmpty) {
                      //   VWidgetShowResponse.showToast(ResponseEnum.warning,
                      //       message: 'Please select a booking date');
                      //   return;
                      // }
                      // final temp = ref
                      //     .read(jobDataProvider.notifier)
                      //     .state
                      //     .copyWith(
                      //       jobTitle: _titleController.text.trim(),
                      //       jobType: jobType,
                      //       preferredGender: gender,
                      //       priceOption: priceType.simpleName,
                      //       priceValue: double.parse(_priceController.text.trim()),
                      //       talents: [
                      //         {
                      //           "talentType": talentType,
                      //           // "numOfTalent": int.parse(
                      //           //   _talentNumberController.text.trim(),
                      //           "numOfTalent": 1
                      //         }
                      //       ],
                      //       shortDescription: _shortDescriptionController.text,
                      //       brief: _briefTextController.text,
                      //       briefLink: _briefLinkController.text,
                      //     );
                      // ref.read(jobDataProvider.notifier).state = temp;
                      context.push("/createBookingSecondPage/$jobType",
                          extra: selectedMockService);
                      /*navigateToRoute(
                          context, CreateBookingSecondPage(jobType: jobType));*/
                    },
                    buttonTitle: "Continue",
                  ),
                  addVerticalSpacing(80)
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
