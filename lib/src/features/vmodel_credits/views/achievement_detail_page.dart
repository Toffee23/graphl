import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';

class AchievementDetailPage extends StatelessWidget {
  const AchievementDetailPage({super.key, required this.details});
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: '',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              details['title'] ?? "",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 10),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(details['image'] ?? ""))),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              RenderSvg(
                svgPath: VIcons.star,
                color: details['star'] >= 1 ? Colors.amber : context.appTheme.primaryColor,
                svgHeight: 40,
                svgWidth: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: RenderSvg(
                  svgPath: VIcons.star,
                  color: details['star'] >= 2 ? Colors.amber : context.appTheme.primaryColor,
                  svgHeight: 40,
                  svgWidth: 40,
                ),
              ),
              RenderSvg(
                svgPath: VIcons.star,
                color: details['star'] >= 3 ? Colors.amber : context.appTheme.primaryColor,
                svgHeight: 40,
                svgWidth: 40,
              ),
            ]),
            Spacer(
              flex: 2,
            ),
            Text(
              'Complete 5 gigs to unlock',
              style: context.appTextTheme.bodyLarge,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              '0 gigs Completed',
              style: context.appTextTheme.bodyLarge?.copyWith(
                color: context.appTextTheme.bodyLarge?.color?.withOpacity(0.8),
              ),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
