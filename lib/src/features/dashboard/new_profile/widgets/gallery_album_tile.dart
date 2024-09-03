import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/create_posts/models/photo_post_model.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

import '../../../../shared/shimmer/post_shimmer.dart';
import '../../../create_posts/controller/create_post_controller.dart';
import '../../../suite/views/business_opening_times/widgets/bussiness_tag_widget.dart';

class GalleryAlbumTile extends ConsumerStatefulWidget {
  final List<PhotoPostModel> photos;
  // final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String postId;
  //Temp variable
  final bool isCurrentUser;
  final bool hasVideo;

  const GalleryAlbumTile({
    Key? key,
    required this.postId,
    required this.photos,
    required this.isCurrentUser,
    required this.hasVideo,
    // required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GalleryAlbumTileState();
}

class _GalleryAlbumTileState extends ConsumerState<GalleryAlbumTile> {
  ValueNotifier<int> _networklHasErrorNotifier = ValueNotifier(0);
  final isReposting = ValueNotifier<bool>(false);
  // late VideoPlayerController playerController =
  //     VideoPlayerController.networkUrl(Uri.parse(''));

  bool isLoading = true;
  bool isUnmute = true;

  // void initializeController() async {
  //   WidgetsFlutterBinding.ensureInitialized();

  //   // playerController =
  //   //     VideoPlayerController.networkUrl(Uri.parse(widget.photos.first.url));
  //   // await playerController.initialize();

  //   // playerController.setLooping(true);
  //   // playerController.pause();
  //   // playerController.setVolume(0);

  //   isLoading = false;
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    // initializeController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      // onTap: widget.onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder(
                valueListenable: _networklHasErrorNotifier,
                builder: (context, value, child) {
                  final urlToUse = widget.photos.first.mediaType == 'VIDEO' ? widget.photos.first.thumbnail! : widget.photos.first.url;
                  return CachedNetworkImage(
                    cacheKey: urlToUse,
                    imageUrl: urlToUse,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fit: BoxFit.cover,
                    memCacheHeight: 300,
                    placeholder: (context, url) {
                      return const PostShimmerPage();
                    },
                    errorWidget: (context, error, url) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_networklHasErrorNotifier.value < 5) {
                          Future.delayed(Duration(seconds: 3));
                          _networklHasErrorNotifier.value++;
                        }
                      });
                      if (_networklHasErrorNotifier.value < 5) {
                        return const PostShimmerPage();
                      }
                      return Center(
                        child: TextButton(
                          onPressed: () {
                            _networklHasErrorNotifier.value++;
                          },
                          child: Text('Retry'),
                        ),
                      );
                    },
                  );
                }),
          ),
          if (widget.isCurrentUser && widget.photos.any((element) => element.thumbnailUnavailable))
            Positioned.fill(
              child: ValueListenableBuilder(
                  valueListenable: isReposting,
                  builder: (context, value, _) {
                    return Container(
                      color: Colors.black.withOpacity(0.15),
                      height: 20,
                      width: 50,
                      child: Center(
                        child: RepostButtonWidget(
                            isLoading: value,
                            isSelected: false,
                            text: "Repost",
                            borderColor: Colors.white,
                            onPressed: () async {
                              // onItemTap(index);

                              // final fooo = [];

                              isReposting.value = true;
                              await ref.read(createPostProvider(null).notifier).createPostThumbnailOnly(postId: widget.postId, photos: widget.photos);
                              isReposting.value = false;
                            }),
                      ),
                    );
                  }),
            ),
          if (widget.photos.length > 1)
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: -4,
                    blurRadius: 1.5,
                  )
                ],
              ),
              child: const Icon(
                Icons.album,
                color: Colors.white,
              ),
            ),
          if (widget.hasVideo)
            Container(
              height: 25,
              padding: const EdgeInsets.only(top: 8.0, left: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const RenderSvg(
                color: Colors.white,
                svgPath: VIcons.homeLiveFilled,
              ),
            ),
        ],
      ),
    );
  }
}
