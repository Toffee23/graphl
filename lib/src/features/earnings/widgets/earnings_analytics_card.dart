import 'package:intl/intl.dart';
import 'package:vmodel/src/core/utils/extensions/currency_format.dart';
import 'package:vmodel/src/features/earnings/model/earnining.model.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsEarningsAnalyticsCard extends StatelessWidget {
  final EarningModel? earnings;

  const VWidgetsEarningsAnalyticsCard({
    required this.earnings,
    super.key,
  });

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Earnings in ${DateFormat.MMMM().format(DateTime.now())}",
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                Text(
                  (earnings?.earningsInMonth ?? 0).toString().formatToPounds(),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                )
              ],
            ),
            SizedBox(height: 10,),
            const Divider(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       "Avg. Selling Price",
            //       style: Theme.of(context).textTheme.displayMedium!,
            //     ),
            //     Text(
            //       "£$averageSellingPrice",
            //       style: Theme.of(context).textTheme.displayMedium!.copyWith(
            //             fontWeight: FontWeight.w600,
            //           ),
            //     )
            //   ],
            // ),
            addVerticalSpacing(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Active Bookings",
                    style: Theme.of(context).textTheme.displayMedium!),
                Text(
                  '${earnings?.activeBookings?.count ?? '0'} (${(earnings?.activeBookings?.value ?? 0).toString().formatToPounds()})',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                )
              ],
            ),
             SizedBox(height: 10,),
            const Divider(),
            // addVerticalSpacing(30),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // Text(
            //     //   "Available for withdrawal",
            //     //   style: Theme.of(context).textTheme.displayMedium!,
            //     // ),
            //     Text(
            //       (availableForWithdrawal ?? '0').formatToPounds(),
            //       style: Theme.of(context).textTheme.displayMedium!.copyWith(
            //             fontWeight: FontWeight.w600,
            //           ),
            //     )
            //   ],
            // ),
            addVerticalSpacing(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Completed bookings",
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                Text(
                  "${earnings?.totalEarnings?.count ?? '0'} (${(earnings?.totalEarnings?.value ?? 0).toString().formatToPounds()})",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                )
              ],
            ),
             SizedBox(height: 10,),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
