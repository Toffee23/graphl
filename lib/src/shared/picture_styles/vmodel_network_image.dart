import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../res/icons.dart';
import '../shimmer/post_shimmer.dart';

class VWidgetNetworkImage extends StatelessWidget {
  final String? url;
  final String? thumbnail;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final BoxFit fit;

  const VWidgetNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.thumbnail,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: thumbnail ?? '$url',
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      width: double.maxFinite,
      height: double.maxFinite,
      filterQuality: FilterQuality.medium,
      fit: fit,
      // fit: BoxFit.contain,
      placeholder: (context, url) {
        return loadingWidget ?? const PostShimmerPage();
      },
      errorWidget: (context, url, error) {
        return SvgPicture.asset(
          VIcons.gridIcon,
          width: 30,
          height: 30,
        );
      },
    );
  }
}
