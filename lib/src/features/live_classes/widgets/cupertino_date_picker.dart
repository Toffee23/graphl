import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:vmodel/src/vmodel.dart';

class CupetinoDatePicker extends StatefulWidget {
  const CupetinoDatePicker({super.key, required this.selectedDate});
  final DateTime selectedDate;

  @override
  State<CupetinoDatePicker> createState() => _CupetinoDatePickerState();
}

class _CupetinoDatePickerState extends State<CupetinoDatePicker> {
  late final DateTime currentDateTime;

  @override
  initState() {
    super.initState();
    currentDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle datePickerTextStyle =
        Theme.of(context).textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 25,
            );

    final TextStyle selectedDatePickerTextStyle =
        Theme.of(context).textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 25,
            );

    return ScrollDatePicker(
      options: DatePickerOptions(
          isLoop: false,
          diameterRatio: 3,
          itemExtent: 30,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor
          //itemExtent: 3.0
          ),
      scrollViewOptions: DatePickerScrollViewOptions(
        day: ScrollViewDetailOptions(
          alignment: Alignment.centerLeft,
          // textStyle: datePickerTextStyle,
          textStyle: selectedDatePickerTextStyle,
          selectedTextStyle: selectedDatePickerTextStyle,
          margin: const EdgeInsets.all(14.0),
        ),
        month: ScrollViewDetailOptions(
          alignment: Alignment.center,
          textStyle: datePickerTextStyle,
          selectedTextStyle: selectedDatePickerTextStyle,
          margin: const EdgeInsets.only(right: 14),
        ),
        year: ScrollViewDetailOptions(
          alignment: Alignment.centerRight,
          textStyle: datePickerTextStyle,
          selectedTextStyle: selectedDatePickerTextStyle,
          margin: const EdgeInsets.only(right: 14),
        ),
      ),
      selectedDate: widget.selectedDate,
      onDateTimeChanged: (value) {
        // VMHapticsFeedback.lightImpact();
        // Get.find<OnboardingController>().birthday(value);
      },
      locale: const Locale('ko'),
      minimumDate: DateTime(currentDateTime.year, currentDateTime.month, 1),
      maximumDate: DateTime(DateTime.now().year, 12, 31),
      indicator: null,
    );
  }
}
