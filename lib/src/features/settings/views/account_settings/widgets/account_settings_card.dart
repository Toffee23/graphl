import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsAccountSettingsCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;
  final String? subtitle;
  const VWidgetsAccountSettingsCard({required this.title, this.subtitle, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title!,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            addHorizontalSpacing(4),
            // if (subtitle != null)
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              subtitle ?? '',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            ),

                        SizedBox(height: 10,),

            const Divider(
              thickness: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
