import 'package:vmodel/src/features/earnings/widgets/progress_slider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';


class VWidgetsEarningsOverviewCard extends StatelessWidget {



  const VWidgetsEarningsOverviewCard({

    super.key});


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ratingStatCard(title: "Rating", value: "4.9", textStyle: Theme.of(context).textTheme.displayMedium!),
                _responseStatCard(title: "Response rate", value: "-", textStyle: Theme.of(context).textTheme.displayMedium!)
              ],
            ),
            SizedBox(height: 10,),
            const Divider(),
            addVerticalSpacing(30),
            _buildStatCard(title: 'Orders', value: '5 / 5', textStyle: Theme.of(context).textTheme.displayMedium!),
            SizedBox(height: 10,),
            const Divider(),
            addVerticalSpacing(30),
            _buildStatCard(title: 'Unique Clients', value: '5 / 3', textStyle: Theme.of(context).textTheme.displayMedium!),
            SizedBox(height: 10,),
            const Divider(),
            addVerticalSpacing(30),
            _buildStatCard(title: 'Earnings', value: '\$168 / \$400', textStyle: Theme.of(context).textTheme.displayMedium!),
            SizedBox(height: 10,),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required String title, required String value, required TextStyle textStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
 Widget _ratingStatCard(
      {required String title, required String value, required TextStyle textStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        )),
        addVerticalSpacing(15),
        Text(value, style: textStyle.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600
        )),
        addVerticalSpacing(15),
        ProgressSlide(progress: 0.90, child: Text("")),
      ],
    );
  }
 Widget _responseStatCard(
      {required String title, required String value, required TextStyle textStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        )),
        addVerticalSpacing(15),
        Text(value, style: textStyle.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600
        )),
        addVerticalSpacing(15),
        ProgressSlide(progress: 0.5, child: Text("")),
      ],
    );
  }
}