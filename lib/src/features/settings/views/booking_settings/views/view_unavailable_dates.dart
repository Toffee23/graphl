import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/unavailable_dates.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../shared/appbar/appbar.dart';

class ViewUnAvDates extends ConsumerStatefulWidget {
  const ViewUnAvDates(this.selectedDays, {super.key});
  final Set<DateTime> selectedDays;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewUnAvDatesState();
}

class _ViewUnAvDatesState extends ConsumerState<ViewUnAvDates> {
  late Set<DateTime> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.selectedDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: "Added Days",
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
      ),
      body: Padding(
        padding: VWidgetsPagePadding.all(16),
        child: SafeArea(child: LayoutBuilder(
          builder: (context, constraints) {
            var mHeight = constraints.maxHeight;
            var mWidth = constraints.maxWidth;
            return SizedBox(
              height: mHeight,
              width: mWidth,
              child: Column(
                children: [
                  Text(
                    'This month',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  addVerticalSpacing(30),
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) {
                      final date = DateFormat("MMMM dd, yyy")
                          .format(_selectedDays.toList()[index]);
                      final day = DateFormat("EEEE")
                          .format(_selectedDays.toList()[index]);

                      return UnavailableDates(
                        date: date,
                        day: day,
                        removeFunc: () {
                          setState(() {
                            _selectedDays.remove(_selectedDays.toList()[index]);
                          });
                        },
                      );
                    },
                    itemCount: _selectedDays.length,
                  )),
                  SizedBox(
                    height: 100,
                  ),
                  VWidgetsPrimaryButton(
                      butttonWidth: 250,
                      onPressed: () {},
                      enableButton: true,
                      buttonTitle: 'Save dates')
                ],
              ),
            );
          },
        )),
      ),
    );
  }
}
