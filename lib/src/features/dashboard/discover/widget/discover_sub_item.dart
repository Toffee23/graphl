import 'package:cached_network_image/cached_network_image.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../shared/username_verification.dart';
import '../models/discover_item.dart';

class DiscoverSubItem extends StatelessWidget {
  final DiscoverItemObject item;
  final VoidCallback? onTap;
  final bool isViewAll;
  final VoidCallback? onLongPress;
  const DiscoverSubItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      height: 180,
      width: SizerUtil.width * 0.42,
      margin: EdgeInsets.symmetric(horizontal: isViewAll ? 0 : 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: item.image.isHttpOkay ? DecorationImage(image: CachedNetworkImageProvider(item.image), fit: BoxFit.cover) : null,
      ),
      child: GestureDetector(
        onTap: () {
          onTap!();
        },
        onLongPress: () {
          onLongPress!();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 10, 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.6, 1], colors: [Colors.transparent, Colors.black87])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: VerifiedUsernameWidget(
                      // username: userName,
                      useFlexible: true,
                      rowMainAxisAlignment: MainAxisAlignment.start,
                      username: '${item.username}',
                      displayName: '${item.username}',
                      textStyle: textTheme.displaySmall?.copyWith(fontSize: 12.sp, color: VmodelColors.white, fontWeight: FontWeight.w500),
                      isVerified: item.isVerified,
                      blueTickVerified: item.blueTickVerified,
                    ),
                  ),
                  // Flexible(
                  //   child: Text(
                  //     item.name,
                  //     style: textTheme.displaySmall?.copyWith(
                  //         fontSize: 12.sp,
                  //         color: VmodelColors.white,
                  //         fontWeight: FontWeight.w500),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                ],
              ),
              addVerticalSpacing(3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.labelOrUserType.toUpperCase(),
                      style: textTheme.displaySmall?.copyWith(
                        fontSize: 10.sp,
                        color: VmodelColors.white,
                        // fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RenderSvg(
                        svgPath: VIcons.star,
                        color: VmodelColors.starColor,
                        svgWidth: 16,
                        svgHeight: 16,
                      ),
                      addHorizontalSpacing(2),
                      Text(
                        item.reviewStats?.rating.toString() ?? '0.0',
                        style: textTheme.displaySmall?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
              addVerticalSpacing(4),
              // item.categories!=null?   Text(
              //      item.categories!,
              //      style: textTheme.displaySmall
              //          ?.copyWith(fontSize: 8.sp, color: VmodelColors.white),
              //      maxLines: 1,
              //      overflow: TextOverflow.ellipsis,
              //    ): Text(
              //  "",
              //   style: textTheme.displaySmall
              //       ?.copyWith(fontSize: 8.sp, color: VmodelColors.white),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
