import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsEarningsRevenuesCard extends StatelessWidget {
  final String? paymentsCleared;
  final String? earningsToDate;
  final String? expensesToDate;
  final String? withdrawnToDate;
  final VoidCallback? onTapPaymentsCleared;
  final VoidCallback? onTapEarningsToDate;
  final VoidCallback? onTapExpensesToDate;
  final VoidCallback? onTapWithdrawnToDate;
  final bool showArrow;

  const VWidgetsEarningsRevenuesCard(
      {required this.paymentsCleared,
      this.showArrow = true,
      required this.earningsToDate,
      required this.expensesToDate,
      required this.withdrawnToDate,
      required this.onTapPaymentsCleared,
      required this.onTapEarningsToDate,
      required this.onTapExpensesToDate,
      required this.onTapWithdrawnToDate,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: Theme.of(context).brightness == Brightness.light
      //       ? VmodelColors.lightBgColor
      //       : Theme.of(context).scaffoldBackgroundColor,
      // ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTapPaymentsCleared,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment being cleared",
                    style: Theme.of(context).textTheme.displayMedium!,
                  ),
                  Row(
                    children: [
                      Text(
                        "£$paymentsCleared",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addHorizontalSpacing(10),
                      RenderSvg(
                        svgPath: VIcons.newForwardIcon,
                        svgWidth: 12,
                        svgHeight: 12,
                        color: Theme.of(context).brightness == Brightness.light
                            ? VmodelColors.primaryColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            const Divider(),
            addVerticalSpacing(30),
            GestureDetector(
              onTap: onTapEarningsToDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Earnings to date",
                    style: Theme.of(context).textTheme.displayMedium!,
                  ),
                  Row(
                    children: [
                      Text(
                        "$earningsToDate",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),

                      addHorizontalSpacing(10),
                      if (showArrow || !showArrow)
                        RenderSvg(
                          svgPath: VIcons.newForwardIcon,
                          svgWidth: 12,
                          svgHeight: 12,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? VmodelColors.primaryColor.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                        ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
             const Divider(),
            addVerticalSpacing(30),
            GestureDetector(
              onTap: onTapExpensesToDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Expenses to date",
                    style: Theme.of(context).textTheme.displayMedium!,
                  ),
                  Row(
                    children: [
                      Text(
                        "$expensesToDate".formatToPounds(),
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addHorizontalSpacing(10),
                      RenderSvg(
                        svgPath: VIcons.newForwardIcon,
                        svgWidth: 12,
                        svgHeight: 12,
                        color: Theme.of(context).brightness == Brightness.light
                            ? VmodelColors.primaryColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
             const Divider(),
            addVerticalSpacing(30),
            GestureDetector(
              onTap: onTapWithdrawnToDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Withdrawn to date",
                    style: Theme.of(context).textTheme.displayMedium!,
                  ),
                  Row(
                    children: [
                      Text(
                        "£$withdrawnToDate",
                        style:
                            Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      addHorizontalSpacing(10),
                      RenderSvg(
                        svgPath: VIcons.newForwardIcon,
                        svgWidth: 12,
                        svgHeight: 12,
                        color: Theme.of(context).brightness == Brightness.light
                            ? VmodelColors.primaryColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
