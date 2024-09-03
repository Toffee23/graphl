import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../core/controller/user_prefs_controller.dart';
import '../../../../../shared/appbar/appbar.dart';
import '../../../../booking/controller/calendar_event.dart';
import '../controllers/unavailable_days_controller.dart';
import '../widgets/unavailable_dates.dart';
import 'view_all_dates.dart';

class NewUnavailableScreen extends ConsumerStatefulWidget {
  const NewUnavailableScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewUnavailableScreenState();
}

class _NewUnavailableScreenState extends ConsumerState<NewUnavailableScreen> {
  bool expandCalendar = false;
  String? formattedDate;
  DateTime? selectedDate;
  List<String> listOfTimes = [];
  Set<DateTime>? _selectedDays;
  ValueNotifier<DateTime> _currentPageDate = ValueNotifier(DateTime.now());
  ValueNotifier<bool> _dayIsAvailable = ValueNotifier(false);

  ValueNotifier<List<Event>>? _selectedEvents;
  bool _showFAB = true;
  bool _showLoading = false;
  late bool _isLightTheme;

  late PageController _calendarController;
  late Future<List<DateTime>> unavailableDates;

  /*boolean value that controls if an unavailability can be created
    action can be triggered via FAB button
  */
  bool createUnavailability = false;

  @override
  void initState() {
    super.initState();
    final userPrefsConfig = ref.read(userPrefsProvider);

    _isLightTheme = userPrefsConfig.value!.themeMode == ThemeMode.light;
    formattedDate = DateFormat('EEE, d MMM').format(selectedDate ?? DateTime.now());
    _dayIsAvailable.value = dayIsAvailable(DateTime.now());
    _selectedEvents = ValueNotifier(_getEventsForDay(selectedDate ?? DateTime.now()));
    _selectedDays = LinkedHashSet<DateTime>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
  }

  @override
  void dispose() {
    _selectedEvents!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unavailableDays = ref.watch(unavailableDaysProvider(null));
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Calendar",
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        // trailingIcon: [
        //   Padding(
        //       padding: const EdgeInsets.only(top: 0, right: 0),
        //       child: _showLoading
        //           ? SizedBox(
        //               height: 20,
        //               width: 20,
        //               child: CircularProgressIndicator.adaptive(
        //                 strokeWidth: 2,
        //                 valueColor: AlwaysStoppedAnimation<Color>(
        //                     Theme.of(context).primaryColor),
        //               ),
        //             )
        //           : Padding(
        //               padding: const EdgeInsets.only(right: 10.0),
        //               child: Badge(
        //                 offset: Offset(-4.0, 3.0),
        //                 label: Text(
        //                   _selectedDays?.length.toString() ?? '',
        //                   style: Theme.of(context)
        //                       .textTheme
        //                       .displayMedium
        //                       ?.copyWith(color: Colors.white),
        //                 ),
        //                 child: IconButton(
        //                     onPressed: () async {
        //                       VMHapticsFeedback.lightImpact();
        //                       await _saveDay();
        //                     },
        //                     icon: Icon(
        //                       CupertinoIcons.add_circled,
        //                       color: Theme.of(context).primaryColor,
        //                       size: 30,
        //                     )),
        //               ),
        //             )),
        // ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.horizontal) return true;
          _handleFABVisibility(notification);
          return true;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(child: LayoutBuilder(
            builder: (context, constraints) {
              var mHeight = constraints.maxHeight;
              var mWidth = constraints.maxWidth;
              return SizedBox(
                  height: mHeight,
                  width: mWidth,
                  child: Stack(
                    children: [
                      if (_selectedDays?.isEmpty ?? false)
                        Column(
                          children: [
                            Padding(padding: VWidgetsPagePadding.onlyTop(mHeight * 0.35)),
                            Expanded(
                                child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(),
                              itemBuilder: (context, index) {
                                var timeString = '${index < 10 ? '0$index' : '$index'}:00';

                                return _TimeRow(listOfTimes.contains(timeString), index, (time) => addOrRemoveTime(time), mHeight * 0.12, mWidth, timeString);
                              },
                              itemCount: 24,
                            ))
                          ],
                        ),
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(
                            width: mWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: ButtonStyle(overlayColor: WidgetStatePropertyAll(Colors.transparent), splashFactory: NoSplash.splashFactory),
                                  onPressed: () {
                                    VMHapticsFeedback.lightImpact();
                                    setState(() {
                                      expandCalendar = !expandCalendar;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(formattedDate ?? '', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                                      addHorizontalSpacing(10),
                                      Icon(
                                        expandCalendar ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                                        size: 18,
                                        color: context.isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _dayIsAvailable,
                                  builder: (context, isAvailable, _) => Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(isAvailable ? 'Available' : 'Unavailable', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                      addHorizontalSpacing(10),
                                      CircleAvatar(
                                        radius: 5,
                                        backgroundColor: isAvailable ? Colors.green : Colors.red,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          addVerticalSpacing(20),
                          TableCalendar(
                              onCalendarCreated: (pageController) {
                                _calendarController = pageController;
                              },
                              eventLoader: _getEventsForDay,
                              headerVisible: false,
                              availableGestures: AvailableGestures.horizontalSwipe,
                              formatAnimationCurve: Curves.easeInOut,
                              formatAnimationDuration: Duration(milliseconds: 500),
                              calendarBuilders: CalendarBuilders(
                                dowBuilder: (context, day) {
                                  return Text(
                                    DateFormat.EEEE().format(day).substring(0, 3).toUpperCase(),
                                    style: !createUnavailability && isSameDay(day, selectedDate)
                                        ? Theme.of(context).textTheme.displayMedium!.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )
                                        : isSameDay(DateTime.now(), day)
                                            ? Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  fontWeight: createUnavailability ? null : FontWeight.bold,
                                                )
                                            : null,
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                              onDaySelected: (selectedDay, focusedDay) {
                                changeSelectedDate(selectedDay, true);
                                // setState(() => selectedDate = selectedDay);
                                // logger.d('Current date ${selectedDate.toString()} ${focusedDay.toString()}');
                              },
                              focusedDay: selectedDate ?? DateTime.now(),
                              onPageChanged: (focusedDay) {
                                changeSelectedDate(focusedDay, false);
                              },
                              firstDay: DateTime(1960),
                              calendarFormat: expandCalendar ? CalendarFormat.month : CalendarFormat.week,
                              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, headerMargin: EdgeInsets.zero),
                              calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: !createUnavailability && selectedDate != null
                                      ? Theme.of(context).textTheme.displayMedium!.copyWith()
                                      : Theme.of(context).textTheme.displayMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                  // isTodayHighlighted: selectedDate == null,
                                  selectedDecoration:
                                      !createUnavailability ? BoxDecoration() : BoxDecoration(color: _isLightTheme ? Theme.of(context).colorScheme.primary : Colors.white, shape: BoxShape.circle),
                                  selectedTextStyle: !createUnavailability
                                      ? context.appTextTheme.displayMedium!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )
                                      : TextStyle(color: _isLightTheme ? Colors.white : Colors.black),
                                  weekendTextStyle: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500) ??
                                      TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  weekNumberTextStyle: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500) ?? TextStyle(color: Theme.of(context).primaryColor)),
                              lastDay: DateTime(2100),
                              selectedDayPredicate: (day) {
                                final wwx = ref.read(unavailableDaysProvider(null).notifier).containsDateTime(day);
                                return !createUnavailability ? isSameDay(day, selectedDate) : wwx || _selectedDays!.contains(day);
                              }),
                          // addVerticalSpacing(5),
                          SizedBox(
                            width: mWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: () => _changeCalendarPages(false), icon: Icon(CupertinoIcons.back)),
                                addHorizontalSpacing(8),
                                ValueListenableBuilder(
                                  valueListenable: _currentPageDate,
                                  builder: (context, value, child) {
                                    return Text(DateFormat.MMM().format(value), style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16));
                                  },
                                ),
                                addHorizontalSpacing(8),
                                IconButton(onPressed: () => _changeCalendarPages(true), icon: Icon(CupertinoIcons.forward)),
                              ],
                            ),
                          ),
                          if (_selectedDays?.isNotEmpty ?? false)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  addVerticalSpacing(30),
                                  Text(
                                    'Selected Dates',
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
                                  ),
                                  addVerticalSpacing(10),
                                  Expanded(
                                    child: ListView.builder(
                                        // physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _selectedDays!.length,
                                        itemBuilder: (context, index) {
                                          final date = DateFormat("MMMM dd, yyy").format(_selectedDays!.toList()[index]);
                                          final day = DateFormat("EEEE").format(_selectedDays!.toList()[index]);

                                          return UnavailableDates(
                                            date: date,
                                            day: day,
                                            removeFunc: () {
                                              _selectedDays!.remove(_selectedDays!.toList()[index]);
                                              if (_selectedDays?.isEmpty ?? false) {
                                                selectedDate = null;
                                                createUnavailability = false;
                                                formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
                                              } else {
                                                selectedDate = _selectedDays?.last;
                                                formattedDate = DateFormat('EEE, d MMM').format(selectedDate!);
                                              }
                                              setState(() {});
                                            },
                                          );
                                        }),
                                  )
                                ],
                              ),
                            ),
                        ]),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: SizedBox(
                            width: mWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  child: IconButton(
                                      onPressed: () {
                                        navigateToRoute(
                                            context,
                                            AllDates(
                                              selectedDays: _selectedDays!,
                                            ));
                                      },
                                      icon: Icon(
                                        Icons.playlist_add_check,
                                        size: 20,
                                      )),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Today'),
                                          if (_selectedDays?.isNotEmpty ?? false)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: Colors.red,
                                                child: Text(
                                                  _selectedDays!.length.toString(),
                                                  style: context.appTextTheme.labelSmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      )),
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).buttonTheme.colorScheme?.surface,
                                  child: _showLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator.adaptive(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () async {
                                            VMHapticsFeedback.lightImpact();
                                            await _saveDay();
                                          },
                                          icon: Icon(
                                            createUnavailability ? Icons.check_rounded : CupertinoIcons.add,
                                            color: Colors.white,
                                            size: 18,
                                          )),
                                  // Badge(
                                  //     offset: Offset(1.0, 1.0),
                                  //     label: Text(
                                  //       _selectedDays?.length.toString() ??
                                  //           '',
                                  //       style: Theme.of(context)
                                  //           .textTheme
                                  //           .displayMedium
                                  //           ?.copyWith(color: Colors.white),
                                  //     ),
                                  //     child: IconButton(
                                  //         onPressed: () async {
                                  //           VMHapticsFeedback.lightImpact();
                                  //           await _saveDay();
                                  //         },
                                  //         icon: Icon(
                                  //           CupertinoIcons.add,
                                  //           color: Colors.white,
                                  //           size: 18,
                                  //         )),
                                  //   ),
                                )
                              ],
                            ),
                          ))
                    ],
                  ));
            },
          )),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: _showFAB
      //     ? Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           VWidgetsPrimaryButton(
      //             butttonWidth: 118,
      //             enableButton: true,
      //             buttonTitle: "Unavailable dates",
      //             onPressed: () {
      //               navigateToRoute(
      //                   context,
      //                   AllDates(
      //                     selectedDays: _selectedDays!,
      //                   ));
      //             },
      //           ),
      //           addHorizontalSpacing(10),
      //           CircleAvatar(
      //             radius: 25,
      //             backgroundColor:
      //                 Theme.of(context).buttonTheme.colorScheme?.surface,
      //             child: _showLoading
      //                 ? SizedBox(
      //                     height: 20,
      //                     width: 20,
      //                     child: CircularProgressIndicator.adaptive(
      //                       strokeWidth: 2,
      //                       valueColor:
      //                           AlwaysStoppedAnimation<Color>(Colors.white),
      //                     ),
      //                   )
      //                 : Badge(
      //                     offset: Offset(1.0, 1.0),
      //                     label: Text(
      //                       _selectedDays?.length.toString() ?? '',
      //                       style: Theme.of(context)
      //                           .textTheme
      //                           .displayMedium
      //                           ?.copyWith(color: Colors.white),
      //                     ),
      //                     child: IconButton(
      //                         onPressed: () async {
      //                           VMHapticsFeedback.lightImpact();
      //                           await _saveDay();
      //                         },
      //                         icon: Icon(
      //                           CupertinoIcons.add,
      //                           color: Colors.white,
      //                           size: 30,
      //                         )),
      //                   ),
      //           )
      //         ],
      //       )
      //     : null,
    );
  }

  changeSelectedDate(DateTime newDate, bool isDaySelect) {
    if (createUnavailability) {
      if (!isDaySelect) {
        _currentPageDate.value = newDate;
        _dayIsAvailable.value = dayIsAvailable(newDate);
        return;
      }
      if (isDaySelect) {
        if (_selectedDays!.contains(newDate)) {
          _selectedDays!.remove(newDate);
        } else {
          _selectedDays!.add(newDate);
        }
      }
      if (_selectedDays?.isEmpty ?? false) {
        selectedDate = null;
        formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
      } else {
        selectedDate = isDaySelect ? _selectedDays?.last : newDate;
        formattedDate = DateFormat('EEE, d MMM').format(selectedDate!);
      }
      _dayIsAvailable.value = dayIsAvailable(selectedDate ?? DateTime.now());
      setState(() {});
    } else {
      setState(() => selectedDate = newDate);
    }
  }

  addOrRemoveTime(String time) {
    if (listOfTimes.contains(time)) {
      listOfTimes.remove(time);
    } else {
      listOfTimes.insert(0, time);
    }

    setState(() {});
  }

  Future<void> _saveDay() async {
    if (createUnavailability) {
      if (_selectedDays!.isNotEmpty) {
        var dayList = _selectedDays!.toList();
        List<Unavailable> unavailableList = dayList.map((dateTime) {
          return Unavailable(date: dateTime);
        }).toList();
        setState(() => _showLoading = true);
        await ref.read(unavailableDaysProvider(null).notifier).saveUnavailableDays(
              dates: unavailableList,
            );
        setState(() => _showLoading = false);
        goBack(context);
      }
    } else {
      setState(() {
        createUnavailability = true;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  _changeCalendarPages(bool isMovingForward) {
    var duration = Duration(milliseconds: 300);
    var curve = Curves.easeOut;
    if (isMovingForward) {
      _calendarController.nextPage(duration: duration, curve: curve);
    } else {
      _calendarController.previousPage(duration: duration, curve: curve);
    }
  }

  void _handleFABVisibility(UserScrollNotification notification) {
    final ScrollDirection direction = notification.direction;

    switch (direction) {
      case ScrollDirection.forward:
        _showFAB = true;
        break;
      case ScrollDirection.reverse:
        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
          _showFAB = true;
        } else {
          _showFAB = false;
        }
        break;
      case ScrollDirection.idle:
        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
          _showFAB = true;
        }
        break;
    }
    if (mounted) setState(() {});
  }

  bool dayIsAvailable(DateTime day) {
    bool isAv = ref.read(unavailableDaysProvider(null).notifier).containsDateTime(day);
    return isAv;
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow(this.isSelected, this.index, this.onTimeTap, this.maxHeight, this.maxWidth, this.timeString);
  final bool isSelected;
  final int index;
  final void Function(String) onTimeTap;
  final double maxHeight, maxWidth;
  final String timeString;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      width: maxWidth,
      child: InkWell(
        onTap: () => onTimeTap(timeString),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: maxWidth * 0.15,
              height: maxHeight,
              child: Text(
                timeString,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.3)),
                color: isSelected ? Colors.blue : Theme.of(context).scaffoldBackgroundColor,
              ),
              height: maxHeight,
            ))
          ],
        ),
      ),
    );
  }
}
