import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/features/vmodel_credits/models/achievement_model.dart';
import 'package:vmodel/src/features/vmodel_credits/models/achievements_list.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

class AchievementItemWidget extends StatelessWidget {
  const AchievementItemWidget({super.key, this.data, this.badgeTitle, this.size = 80, this.showTitle = true, this.iconSize = 20});
  final AchievementModel? data;
  final String? badgeTitle;
  final double size;
  final double iconSize;
  final bool showTitle;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final achievement = achievementList
          .where(
            (e) => data == null ? e['title'] == badgeTitle : data!.achievement.title.toLowerCase() == e['title'].toString().replaceAll("\n", " ").toLowerCase(),
          )
          .first;

      return GestureDetector(
        onTap: () => context.push('/achievement_detail', extra: achievement),
        child: Column(
          children: [
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  // colorFilter: badgeTitle != null
                  //     ? ColorFilter.mode(
                  //         Colors.white30,
                  //         BlendMode.srcOver,
                  //       )
                  //     : null,
                  image: AssetImage(achievement['image'] ?? ""),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              RenderSvg(
                svgPath: VIcons.star,
                color: (data?.timesEarned ?? 0) >= 1 ? Colors.amber : context.appTheme.primaryColor,
                svgHeight: iconSize,
                svgWidth: iconSize,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RenderSvg(
                  svgPath: VIcons.star,
                  color: (data?.timesEarned ?? 0) >= 2 ? Colors.amber : context.appTheme.primaryColor,
                  svgHeight: iconSize,
                  svgWidth: iconSize,
                ),
              ),
              RenderSvg(
                svgPath: VIcons.star,
                color: (data?.timesEarned ?? 0) >= 3 ? Colors.amber : context.appTheme.primaryColor,
                svgHeight: iconSize,
                svgWidth: iconSize,
              ),
            ]),
            if (showTitle) ...[
              SizedBox(height: 5),
              Text(
                achievement['title'] ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      height: 1,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ]
          ],
        ),
      );
    });
  }
}
