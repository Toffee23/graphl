import 'package:flutter/gestures.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/switch/primary_switch.dart';
import 'package:vmodel/src/vmodel.dart';

class BusinessHoursPage extends StatefulWidget {
  const BusinessHoursPage({super.key});

  @override
  State<BusinessHoursPage> createState() => _BusinessHoursPageState();
}

class _BusinessHoursPageState extends State<BusinessHoursPage> {
  final businessHours = <Map<String, dynamic>>[
    {
      'day': 'Monday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': true,
    },
    {
      'day': 'Tuesday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': true,
    },
    {
      'day': 'Wednesday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': true,
    },
    {
      'day': 'Thursday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': true,
    },
    {
      'day': 'Friday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': true,
    },
    {
      'day': 'Saturday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': false,
    },
    {
      'day': 'Sunday',
      'start_time': TimeOfDay(hour: 10, minute: 0),
      'end_time': TimeOfDay(hour: 20, minute: 0),
      'is_open': false,
    },
    {
      'day': 'Open 24/7',
      'is_open': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: !context.isDarkMode ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
        appBar: VWidgetsAppBar(
          appbarTitle: "My Business Hours",
          leadingIcon: const VWidgetsBackButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalSpacing(15),
              ListView.separated(
                shrinkWrap: true,
                itemCount: businessHours.length,
                itemBuilder: (context, index) {
                  final hours = businessHours[index];
                  return Row(
                    children: [
                      VWidgetsSwitch(
                          swicthValue: (hours['is_open'] as bool),
                          onChanged: (isClosed) {
                            setState(() {
                              businessHours.where((e) => e['day'] == hours['day']).single['is_open'] = isClosed;
                            });
                            if (hours['day'] == 'Open 24/7' && hours['is_open']) {
                              for (var i = 0; i < businessHours.length; i++) {
                                if (businessHours[i]['day'] != 'Open 24/7') {
                                  setState(() => businessHours[i]['is_open'] = true);
                                }
                              }
                            }
                          }),
                      addHorizontalSpacing(10),
                      SizedBox(
                        width: 80,
                        child: Text(
                          hours['day'],
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                      Spacer(),
                      if (hours['day'] != 'Open 24/7') ...[
                        if (hours['is_open'])
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${(hours['start_time'] as TimeOfDay).format(context)}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => showTimePicker(
                                        context: context,
                                        initialTime: (hours['start_time'] as TimeOfDay),
                                      ).then((time) {
                                        if (time != null) {
                                          setState(() {
                                            businessHours.where((e) => e['day'] == 'Open 24/7').single['is_open'] = false;
                                            businessHours.where((e) => e['day'] == hours['day']).single['start_time'] = time;
                                          });
                                        }
                                      }),
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              TextSpan(
                                text: ' - ',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              TextSpan(
                                text: '${(hours['end_time'] as TimeOfDay).format(context)}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => showTimePicker(
                                        context: context,
                                        initialTime: (hours['end_time'] as TimeOfDay),
                                      ).then((time) {
                                        if (time != null) {
                                          setState(() {
                                            businessHours.where((e) => e['day'] == 'Open 24/7').single['is_open'] = false;
                                            businessHours.where((e) => e['day'] == hours['day']).single['end_time'] = time;
                                          });
                                        }
                                      }),
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              )
                            ]),
                          )
                        else
                          Text(
                            'Closed',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        Spacer(
                          flex: 3,
                        ),
                      ],
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 15),
              ),
              Spacer(),
              VWidgetsPrimaryButton(
                onPressed: () {},
                buttonTitle: 'Continue',
              ),
              addVerticalSpacing(10),
            ],
          ),
        ));
  }
}
