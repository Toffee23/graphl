import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/settings/views/apperance/data/rings_data.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_riverpod/src/consumer.dart';

class ProfilePicture extends StatelessWidget {
  final String? displayName;
  final String? url;
  final String? headshotThumbnail;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final bool showBorder;
  final EdgeInsetsGeometry imageBorderPadding;
  final String? profileRing;

  ProfilePicture({
    super.key,
    // required this.displayName,
    this.displayName = "",
    required this.url,
    required this.headshotThumbnail,
    this.size = 70.00,
    this.borderWidth = 2.5,
    this.borderColor,
    this.showBorder = false,
    this.imageBorderPadding = const EdgeInsets.all(2),
    this.profileRing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // border: Border.all(width: borderWidth, color: context.appTheme.primaryColor // getPicturBorderColor(context),
            //     ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              memCacheHeight: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              // imageUrl: headshotThumbnail == null ? headshotThumbnail ?? "$url" : "$url",
              imageUrl: headshotThumbnail != null ? headshotThumbnail! : "$url",
              // imageUrl: "${headshotThumbnail}", // ?? "$url",
              placeholderFadeInDuration: Duration.zero,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (context, url) {
                return RenderSvg(svgPath: VIcons.profilePlaceHolder);
                //   return Container(
                //     height: size,
                //     width: size,
                //     color: Theme.of(context).colorScheme.primary,
                //     child: Center(
                //       child: Text(
                //         displayName.isEmptyOrNull ? '-' : displayName![0],
                //         style: Theme.of(context).textTheme.displayLarge?.copyWith(
                //               fontSize: 24,
                //               color: Colors.white,
                //               fontWeight: FontWeight.w400,
                //             ),
                //       ),
                //     ),
                //   );
              },

              errorWidget: (context, url, error) {
                return RenderSvg(svgPath: VIcons.profilePlaceHolder);
                // return Container(
                //   height: size,
                //   width: size,
                //   color: Theme.of(context).colorScheme.primary,
                //   child: Center(
                //     child: Text(
                //       displayName.isEmptyOrNull ? '-' : displayName![0],
                //       style: Theme.of(context).textTheme.displayLarge?.copyWith(
                //             fontSize: 24 * (size / 70),
                //             color: Colors.white,
                //             fontWeight: FontWeight.w400,
                //           ),
                //     ),
                //   ),
                // );
                // return const RenderSvgWithoutColor(svgPath: VIcons.vModelProfile);
              },
            ),
          ),
        ),
        SvgPicture.asset(
          rings
              .where((element) => profileRing == null ? element['name']!.toLowerCase() == 'vmodel' : element['name']!.toLowerCase() == profileRing?.toLowerCase().replaceAll("_", " "))
              .single['asset']!,
          fit: BoxFit.contain,
          height: size,
          width: size,
        ),
      ],
    );
  }

  Color getPicturBorderColor(BuildContext context) {
    return borderColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor!;
  }
}

class NavProfilePicture extends ConsumerStatefulWidget {
  final String? url;
  final double size;
  final Color? borderColor;
  final bool showBorder;

  const NavProfilePicture({
    super.key,
    required this.url,
    this.size = 70.00,
    this.borderColor,
    this.showBorder = false,
  });

  @override
  ConsumerState<NavProfilePicture> createState() => _NavProfilePictureState();
}

class _NavProfilePictureState extends ConsumerState<NavProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      child: Stack(
        children: [
          Container(
            // height: size,
            // width: size,
            padding: EdgeInsets.all(1),
            decoration: widget.showBorder
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: getPicturBorderColor(context),
                    ),
                  )
                : null,
            child: Container(
              decoration: widget.showBorder
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      image: widget.url.isHttpOkay
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                "${widget.url}",
                              ),
                            )
                          : null,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Color getPicturBorderColor(BuildContext context) {
    return widget.borderColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor!;
  }
}
