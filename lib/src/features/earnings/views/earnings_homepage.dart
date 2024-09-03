import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/features/earnings/controller/provider/earning.provider.dart';
import 'package:vmodel/src/features/earnings/widgets/earnings_analytics_card.dart';
import 'package:vmodel/src/features/earnings/widgets/earnings_revenues_card.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/costants.dart';
import '../../../res/icons.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../widgets/earnings_overview_card.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> {
  String getMonthName() {
    final monthFormat = DateFormat
        .MMMM(); // 'MMMM' gives you the full month name, 'MMM' for abbreviated name
    return monthFormat.format(DateTime.now());
  }

  @override
  void initState() {
    // final authState = ref.read(appUserProvider).valueOrNull;
    // ref.read(earmingStateNotiferProvider.notifier).init(username: authState!.username);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final earning = ref
        .watch(earningsProvider)
        .maybeWhen(orElse: () => null, data: (earnings) => earnings);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? VmodelColors.white
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: "Earnings",
        trailingIcon: [
          IconButton(
              onPressed: () {
                VMHapticsFeedback.lightImpact();
                showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    constraints: BoxConstraints(maxHeight: 50.h),
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: VConstants.bottomPaddingForBottomSheets,
                          ),
                          decoration: BoxDecoration(
                            // color: Theme.of(context).scaffoldBackgroundColor,
                            color: Theme.of(context)
                                .bottomSheetTheme
                                .backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(13),
                              topRight: Radius.circular(13),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              addVerticalSpacing(15),
                              const Align(
                                  alignment: Alignment.center,
                                  child: VWidgetsModalPill()),
                              addVerticalSpacing(25),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: GestureDetector(
                                  child: Text('Most Recent',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                ),
                              ),
                              const Divider(thickness: 0.5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: GestureDetector(
                                  child: Text('Earliest',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                ),
                              ),
                              addVerticalSpacing(10),
                            ],
                          ));
                    });
              },
              icon: const RenderSvg(
                svgPath: VIcons.sort,
              ))
        ],
      ),
      body: SingleChildScrollView(
          padding: const VWidgetsPagePadding.horizontalSymmetric(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpacing(25),
              Center(
                  child: Column(
                children: [
                  Text(
                    (earning?.totalEarnings?.value ?? 0)
                        .toString()
                        .formatToPounds(),
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 25.sp,
                        color: Theme.of(context).primaryColor),
                  ),
                  addVerticalSpacing(5),
                  Text(
                    "Available for withdrawal",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.color
                            ?.withOpacity(1)),
                  ),
                ],
              )),
              addVerticalSpacing(20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Analytics",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
              ),
              addVerticalSpacing(10),
              VWidgetsEarningsAnalyticsCard(
                earnings: earning,
              ),
              addVerticalSpacing(20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Revenues",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
              ),
              addVerticalSpacing(10),
              VWidgetsEarningsRevenuesCard(
                  showArrow: false,
                  paymentsCleared:
                      "${earning?.totalEarnings?.value == null ? "0" : earning?.totalEarnings?.value}",
                  earningsToDate:
                      "${(earning?.totalEarnings?.value ?? 0).toString().formatToPounds()}",
                  expensesToDate:
                      "${earning?.expensesToDate == null ? "0" : earning?.expensesToDate}",
                  withdrawnToDate: "-",
                  onTapPaymentsCleared: () {},
                  onTapEarningsToDate: () {},
                  onTapExpensesToDate: () {},
                  onTapWithdrawnToDate: () {}),
              addVerticalSpacing(20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Overview",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
              ),
              addVerticalSpacing(10),
              VWidgetsEarningsOverviewCard(),
              addVerticalSpacing(30),
            ],
          )),
    );
  }
}
