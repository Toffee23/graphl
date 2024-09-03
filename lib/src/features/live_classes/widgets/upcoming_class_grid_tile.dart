import 'package:vmodel/src/features/live_classes/model/live_class_type.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/vmodel.dart';

// ignore_for_file: prefer_const_constructors

import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

class UpcomingClassTile extends StatelessWidget {
  final LiveClassesInput? classes;
  final String imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool? isLike;
  // final bool? isLike;

  UpcomingClassTile({
    Key? key,
    this.classes,
    this.onTap,
    required this.imageUrl,
    this.onLikeTap,
    this.isLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        //print('[xx200] item tapped');
        onTap?.call();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          height: 140,
          width: 44.w,

          // decoration: BoxDecoration(
          // color: Colors.amber,
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: Column(
            children: [
              Stack(
                children: [
                  RoundedSquareAvatar(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    url: imageUrl,
                    thumbnail: imageUrl,
                    size: Size.square(44.w),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: onLikeTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.0, left: 1.0),
                            child: RenderSvg(
                              svgPath: isLike ?? false ? VIcons.likedIcon : VIcons.unlikedIcon,
                              color: isLike ?? false ? Colors.red : Colors.white,
                              svgHeight: 20,
                              svgWidth: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(9),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${classes?.title}',
                      style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    addVerticalSpacing(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${classes?.category}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  // fontSize: subGreyFontSize.sp,
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '£${classes?.price}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w300,
                                // fontSize: subGreyFontSize.sp,
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(5),
                    // stap
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            RenderSvg(
                              svgPath: VIcons.clock,
                              svgHeight: 15,
                              svgWidth: 15,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            ),
                            addHorizontalSpacing(3),
                            Text(
                              '${classes?.duration}min',
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
                        Row(
                          children: [
                            RenderSvg(
                              svgPath: VIcons.star,
                              svgHeight: 12,
                              svgWidth: 12,
                              color: VmodelColors.starColor,
                            ),
                            addHorizontalSpacing(5),
                            Text(
                              '${classes?.rating}',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingClassTileNew extends StatelessWidget {
  final LiveClasses? classes;
  final String imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool? isLike;
  // final bool? isLike;

  UpcomingClassTileNew({
    Key? key,
    this.classes,
    this.onTap,
    required this.imageUrl,
    this.onLikeTap,
    this.isLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        //print('[xx200] item tapped');
        onTap?.call();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          height: 140,
          width: 44.w,

          // decoration: BoxDecoration(
          // color: Colors.amber,
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: Column(
            children: [
              Stack(
                children: [
                  RoundedSquareAvatar(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    url: imageUrl,
                    thumbnail: imageUrl,
                    size: Size.square(44.w),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: onLikeTap,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.0, left: 1.0),
                            child: RenderSvg(
                              svgPath: isLike ?? false ? VIcons.likedIcon : VIcons.unlikedIcon,
                              color: isLike ?? false ? Colors.red : Colors.white,
                              svgHeight: 20,
                              svgWidth: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(9),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${classes?.title}',
                      style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    addVerticalSpacing(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${classes?.category}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  // fontSize: subGreyFontSize.sp,
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '£${classes?.price}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w300,
                                // fontSize: subGreyFontSize.sp,
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(5),
                    // stap
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            RenderSvg(
                              svgPath: VIcons.clock,
                              svgHeight: 15,
                              svgWidth: 15,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            ),
                            addHorizontalSpacing(3),
                            Text(
                              '${classes?.duration}min',
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
                        // Row(
                        //   children: [
                        //     RenderSvg(
                        //       svgPath: VIcons.star,
                        //       svgHeight: 12,
                        //       svgWidth: 12,
                        //       color: VmodelColors.starColor,
                        //     ),
                        //     addHorizontalSpacing(5),
                        //     Text(
                        //       '${classes?.rating}',
                        //       style: Theme.of(context)
                        //           .textTheme
                        //           .bodyMedium!
                        //           .copyWith(
                        //             fontWeight: FontWeight.w300,
                        //             // fontSize: subGreyFontSize.sp,
                        //             color: Theme.of(context)
                        //                 .primaryColor
                        //                 .withOpacity(0.5),
                        //           ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
