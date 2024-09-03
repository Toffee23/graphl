import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../res/icons.dart';
import '../empty_page/empty_page.dart';

class RoundedSquareAvatar extends StatelessWidget {
  final String? url;
  final String? thumbnail;
  final Size? size;
  final double radius;
  final Color? backgroundColor;
  final Widget? imageWidget;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const RoundedSquareAvatar({
    super.key,
    required this.url,
    required this.thumbnail,
    this.size,
    this.radius = 8,
    this.backgroundColor,
    this.imageWidget,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size?.width ?? 50,
      height: size?.height ?? 50,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
      ),
      child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          child: imageWidget != null
              ? imageWidget
              : url.isHttpOkay
                  ? CachedNetworkImage(
                      imageUrl: '$url',
                      fit: BoxFit.cover,
                      placeholderFadeInDuration: Duration.zero,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      // placeholder: (context, url) {
                      //   // return const RenderSvgWithoutColor(svgPath: VIcons.vModelProfile);
                      //   return thumbnail.isHttpOkay
                      //       ? CachedNetworkImage(
                      //           imageUrl: '$thumbnail',
                      //           fit: BoxFit.cover,
                      //           placeholderFadeInDuration: Duration.zero,
                      //           fadeInDuration: Duration.zero,
                      //           fadeOutDuration: Duration.zero,
                      //           placeholder: (context, url) => ColoredBox(
                      //             color: VmodelColors.jobDetailGrey.withOpacity(0.3),
                      //           ),
                      //           // const RenderSvgWithoutColor(
                      //           //     svgPath: VIcons.vModelProfile),
                      //           errorWidget: (context, url, error) => ColoredBox(
                      //             color: VmodelColors.jobDetailGrey.withOpacity(0.3),
                      //           ),
                      //           // const RenderSvgWithoutColor(
                      //           //     svgPath: VIcons.vModelProfile),
                      //         )
                      //       : SizedBox.shrink();
                      // },
                      errorWidget: (context, url, error) => EmptyPage(
                        svgSize: 30,
                        svgPath: VIcons.aboutIcon,
                        // title: 'No Galleries',
                        subtitle: '',
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: '$url',
                      fit: BoxFit.cover,
                      placeholderFadeInDuration: Duration.zero,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      // placeholder: (context, url) {
                      //   // return const RenderSvgWithoutColor(svgPath: VIcons.vModelProfile);
                      //   return thumbnail.isHttpOkay
                      //       ? CachedNetworkImage(
                      //           imageUrl: '$thumbnail',
                      //           fit: BoxFit.cover,
                      //           placeholderFadeInDuration: Duration.zero,
                      //           fadeInDuration: Duration.zero,
                      //           fadeOutDuration: Duration.zero,
                      //           placeholder: (context, url) => ColoredBox(
                      //             color: VmodelColors.jobDetailGrey.withOpacity(0.3),
                      //           ),
                      //           // const RenderSvgWithoutColor(
                      //           //     svgPath: VIcons.vModelProfile),
                      //           errorWidget: (context, url, error) => ColoredBox(
                      //             color: VmodelColors.jobDetailGrey.withOpacity(0.3),
                      //           ),
                      //           // const RenderSvgWithoutColor(
                      //           //     svgPath: VIcons.vModelProfile),
                      //         )
                      //       : SizedBox.shrink();
                      // },
                      errorWidget: (context, url, error) {
                        return Center(
                            child: SvgPicture.asset(
                          VIcons.aboutIcon,
                          width: 30,
                          height: 30,
                        ));
                      })),
    );
  }
}
