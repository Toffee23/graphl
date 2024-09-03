import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/enum/vmodel_app_themes.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';

import '../../../../shared/shimmer/post_shimmer.dart';
import '../../../../vmodel.dart';
import '../controller/new_feed_provider.dart';
import 'feed_video.dart';

class FeedCarousel extends ConsumerStatefulWidget {
  const FeedCarousel({
    super.key,
    required this.aspectRatio,
    required this.hasVideo,
    required this.imageList,
    required this.onPageChanged,
    this.gallery,
    this.isMessageWidget,
    this.refreshing,
    this.isLocalPreview = false,
    this.feed,
  });

  final bool isLocalPreview;
  final UploadAspectRatio aspectRatio;
  final List imageList;
  final bool hasVideo;
  final bool? isMessageWidget;
  final FeedPostSetModel? feed;
  final GalleryModel? gallery;
  final bool? refreshing;
  final Function(int, CarouselPageChangedReason) onPageChanged;

  @override
  ConsumerState<FeedCarousel> createState() {
    return _FeedCarouselState();
  }
}

class _FeedCarouselState extends ConsumerState<FeedCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  bool blockScroll = false;
  int _currentIndex = 0;
  final isReposting = ValueNotifier<bool>(false);
  int loadedTimes = 0;
  bool canRefresh = false;
  bool refreshing = false;
  void refresh() {
    loadedTimes++;
    setState(() {
      refreshing = true;
      canRefresh = false;
    });
    Timer(Duration(seconds: 1), () {
      refreshing = false;
      setState(() {});
    });
  }

  void initRefreshState() {
    setState(() {
      loadedTimes = 0;
    });
  }

  bool isLoading = true;
  bool isUnmute = false;

  void initializeController() async {
    isLoading = false;
    setState(() {});
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();

  //   if (mounted) {
  //     if (widget.imageList.isNotEmpty) {
  //       for (var images in widget.imageList) {
  //         await precacheImage(CachedNetworkImageProvider(images.url), context);
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  Widget build(BuildContext context) {
    final isPinchToZoom = ref.watch(isPinchToZoomProvider);
    final userPrefsConfig = ref.read(userPrefsProvider);
    if (widget.refreshing == true && canRefresh && loadedTimes < 1) {
      refresh();
    } else if (loadedTimes == 1 && widget.refreshing == false) {
      initRefreshState();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: PinchZoomReleaseUnzoomWidget(
            child: CarouselSlider(
              disableGesture: true,
              items: List.generate(
                widget.imageList.length,
                (index) => widget.hasVideo
                    ? Builder(builder: (context) {
                        var dimension = (widget.imageList.first.dimension ??
                            [0, 0]) as List;
                        return FeedVideo(
                          url: widget.imageList.first.url,
                          thumbnail: widget.imageList.first.thumbnail,
                          width: dimension[0],
                          height: dimension[1],
                          isMessageWidget: widget.isMessageWidget,
                          feed: widget.feed!,
                        );
                      })
                    : widget.isLocalPreview
                        ? Image.memory(
                            widget.imageList[index],
                          )
                        : !refreshing
                            ? CachedNetworkImage(
                                imageUrl: widget.imageList[index].url,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                width: double.maxFinite,
                                height: double.maxFinite,
                                filterQuality: FilterQuality.medium,
                                // fit: BoxFit.cover,
                                fit: BoxFit.contain,
                                errorListener: (e) {
                                  setState(() {
                                    canRefresh = true;
                                  });
                                },
                                placeholder: (context, url) {
                                  return const PostShimmerPage();
                                },
                                errorWidget: (context, url, error) => EmptyPage(
                                  svgSize: 30,
                                  svgPath: VIcons.aboutIcon,
                                  // title: 'No Galleries',
                                  subtitle: 'Tap to refresh',
                                ),
                              )
                            : Center(
                                child: Lottie.asset(
                                  userPrefsConfig.value!.preferredDarkTheme ==
                                              VModelAppThemes.grey &&
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                      ? 'assets/images/animations/loading_dark_ani.json'
                                      : 'assets/images/animations/shimmer_animation.json',
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  fit: BoxFit.fill,
                                ),
                              ),
              ),
              // carouselController: _controller,
              options: CarouselOptions(
                padEnds: false,
                viewportFraction: 1,
                aspectRatio: widget.feed == null
                    ? widget.aspectRatio.ratio
                    : (widget.feed!.photos.firstOrNull?.dimension ?? []).isEmpty
                        ? widget.feed!.aspectRatio.ratio
                        : widget.feed!.aspectRatio.customAspectRatio(
                            widget.feed!.photos.first.dimension?[0] ?? 0,
                            widget.feed!.photos.first.dimension?[1] ?? 0,
                          ),
                initialPage: 0,
                enableInfiniteScroll: false,
                // widget.imageList.length > 1 ? true : false,
                onPageChanged: (index, reason) {
                  _currentIndex = index;
                  widget.onPageChanged(index, reason);
                },
                scrollPhysics:
                    isPinchToZoom ? NeverScrollableScrollPhysics() : null,
                // height: 300,
              ),
            ),
            twoFingersOn: () {
              ref.read(isPinchToZoomProvider.notifier).state = true;
              // setState(() => blockScroll = true);
            },
            twoFingersOff: () => Future.delayed(
              PinchZoomReleaseUnzoomWidget.defaultResetDuration,
              () {
                if (!mounted) return;
                ref.read(isPinchToZoomProvider.notifier).state = false;
                // setState(() => blockScroll = false);
              },
            ),
          ),
        ),
      ],
    );
  }
}
