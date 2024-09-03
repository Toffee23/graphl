import 'package:flutter_svg/flutter_svg.dart';
import 'package:vmodel/src/features/live_classes/model/live_class_type.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsLiveClassCardWidget extends StatelessWidget {
  final LiveClassesInput? classes;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final String imageUrl;

  final bool? isLike;

  const VWidgetsLiveClassCardWidget({
    super.key,
    this.classes,
    required this.imageUrl,
    this.onTap,
    this.onLikeTap,
    this.isLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navigateToRoute(context, const JobDetailPage());
        onTap?.call();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0.0),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              decoration: BoxDecoration(
                // color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // addHorizontalSpacing(10),
                  // if (!bannerUrl.isEmptyOrNull)
                  Stack(
                    children: [
                      RoundedSquareAvatar(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        url: imageUrl,
                        thumbnail: imageUrl,
                        size: Size(120, 120),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 06.0, left: 06),
                        child: InkWell(
                          onTap: onLikeTap,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.black38,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1.0, left: 1),
                              child: RenderSvg(
                                svgPath: isLike ?? false
                                    ? VIcons.likedIcon
                                    : VIcons.unlikedIcon,
                                color:
                                    isLike ?? false ? Colors.red : Colors.white,
                                svgHeight: 18,
                                svgWidth: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // addHorizontalSpacing(10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(classes?.title??'',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          addVerticalSpacing(12),
                          Row(
                            children: [
                              Text(classes?.category?.first??'',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Spacer(),
                              Text('£${classes?.price??0.0}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                              ),
                            ],
                          ),
                          addVerticalSpacing(12),
                          Row(
                            children: [
                              SvgPicture.asset(VIcons.clockIcon,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7),
                                  height: 18),
                              addHorizontalSpacing(05),
                              Text(
                                // "${VMString.poundSymbol} $jobBudget",
                                // "${VMString.poundSymbol} 1.5M",
                                '${classes?.duration??''}min',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                              Spacer(),
                              RenderSvg(
                                svgPath: VIcons.star,
                                svgHeight: 15,
                                svgWidth: 15,
                                color: VmodelColors.starColor,
                              ),
                              SizedBox(width: 4),
                              Text('${classes?.rating}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                              addHorizontalSpacing(08),
                            ],
                          ),
                          addVerticalSpacing(12),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ),
        ),
      ),
    );
  }

  GestureDetector _oldBody(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(classes?.title.toString()??'',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: VmodelColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              addHorizontalSpacing(4),
              Row(
                children: [
                  Text(classes?.category?.first.toString()??'',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  addHorizontalSpacing(10),
                  Text(
                    "£${classes?.price}",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: VmodelColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          addVerticalSpacing(10),
          Text(
            "${classes?.description}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: VmodelColors.primaryColor.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
          ),
          addVerticalSpacing(5),
          Divider(
            thickness: 1,
            color: VmodelColors.dividerColor,
          ),
          addVerticalSpacing(12)
        ],
      ),
    );
  }
}
