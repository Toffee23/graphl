import '../../../res/colors.dart';
import '../../../vmodel.dart';

class ChartNoDataWidget extends StatelessWidget {
  const ChartNoDataWidget({super.key , required this.isColorModified});

  final bool isColorModified;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 36),
        child: Text(
          'No data',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color:  isColorModified? VmodelColors.white: VmodelColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
