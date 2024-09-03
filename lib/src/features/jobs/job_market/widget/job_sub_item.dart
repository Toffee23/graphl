import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../messages/views/messages_homepage.dart';
import '../model/job_post_model.dart';

class JobSubItem extends StatelessWidget {
  final JobPostModel item;
  final VoidCallback? onTap;
  final bool isViewAll;
  final VoidCallback? onLongPress;
  final VoidCallback? onLike;
  const JobSubItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.isViewAll = false,
    this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    int subFontSize = 10;
    int subGreyFontSize = 10;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // color: Colors.amber,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: SizerUtil.width * 0.44,
                // margin: EdgeInsets.symmetric(horizontal: isViewAll ? 0 : 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () {
                    onTap!();
                  },
                  onLongPress: () {
                    onLongPress!();
                  },
                  child: RoundedSquareAvatar(
                    // size: Size.square(40.w),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    url: item.creator!.profilePictureUrl,
                    thumbnail: item.creator!.thumbnailUrl ?? item.creator!.thumbnailUrl,
                  ),
                ),
              ),
              // Positioned(
              //     right: 10,
              //     top: 10,
              //     child: InkWell(
              //       onTap: () {
              //         onLike!();
              //       },
              //       child: CircleAvatar(
              //         radius: 18,
              //         backgroundColor: Colors.black38,
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 1.0, left: 1),
              //           child: RenderSvg(
              //             svgPath: item.creator?.isLiked ?? false ? VIcons.likedIcon : VIcons.unlikedIcon,
              //             color: item.creator?.isLiked ?? false ? Colors.red : Colors.white,
              //             svgHeight: 20,
              //             svgWidth: 20,
              //           ),
              //         ),
              //       ),
              //     ))
            ],
          ),
          addVerticalSpacing(15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(
                  width: SizerUtil.width * 0.40,
                  child: Text(
                    item.jobTitle,
                    style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                addVerticalSpacing(5),
                SizedBox(
                  width: SizerUtil.width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.priceOption.tileDisplayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              // fontSize: subFontSize.sp,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        VConstants.noDecimalCurrencyFormatterGB.format(item.priceValue),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w300,
                              // fontSize: subFontSize.sp,
                              // color: VmodelColors.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(5),
                SizedBox(
                  width: SizerUtil.width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.jobType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            // fontSize: subGreyFontSize.sp,
                            color: Theme.of(context).primaryColor.withOpacity(0.5)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          RenderSvg(
                            svgPath: VIcons.star,
                            svgHeight: 12,
                            svgWidth: 12,
                            color: VmodelColors.starColor,
                            // color: VmodelColors.primaryColor,
                          ),
                          addHorizontalSpacing(5),
                          Text(
                            '4.5',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w300,
                                  // fontSize: subGreyFontSize.sp,
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(5),
                SizedBox(
                  width: SizerUtil.width * 0.4,
                  child: Row(
                    children: [
                      RenderSvg(
                        svgPath: VIcons.calendarTick,
                        svgHeight: 17,
                        svgWidth: 17,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      addHorizontalSpacing(3),
                      Text(
                        "${item.jobDelivery[0].date.formatDateExtension()}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              // fontSize: subGreyFontSize.sp,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
