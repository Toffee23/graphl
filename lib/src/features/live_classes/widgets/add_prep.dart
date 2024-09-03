import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';
import 'prep_bottomsheet.dart';

class AddPrep extends StatelessWidget {
  const AddPrep({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        _showPrepBottomSheet(context);
      },
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Add a Prep",
                  style: context.textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            addVerticalSpacing(10),
            Text(
              "Inform your audience on what they need and how to be prepared for your live.",
              style: context.textTheme.displaySmall!.copyWith(fontSize: 11.sp),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showPrepBottomSheet(
    BuildContext context,
  ) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return PrepBottomSheet(
              bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom);
        });
  }
}
