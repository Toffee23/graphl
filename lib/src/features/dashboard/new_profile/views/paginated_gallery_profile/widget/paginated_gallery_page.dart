import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/create_posts/models/post_set_model.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/views/gallery_feed_view_homepage.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../../../core/utils/debounce.dart';
import '../../../../../../core/utils/helper_functions.dart';
import '../../../../../../shared/empty_page/empty_page.dart';
import '../../../../../../shared/shimmer/post_shimmer.dart';
import '../../../../../create_posts/models/photo_post_model.dart';
import '../../../controller/gallery_posts_controller.dart';
import '../../../model/gallery_model.dart';
import '../../../widgets/gallery_album_tile.dart';

// void _scrollListener() {
//   //print("[jiww0] scroll listener triggered");
//   if (_scrollController.offset >=
//           _scrollController.position.maxScrollExtent &&
//       !_scrollController.position.outOfRange) {
//     // _isLoadMore = true;
//     //print("[jiww0] scroll listener fetch more...");
//     _debounce(() {
//       ref.read(hashTagProvider.notifier).fetchMoreHandler();
//     });

//     // if (_isLoadMore) {
//     //   _pageCount++;
//     // }
//     setState(() {});
//   }
// }
class GalleryHello extends ConsumerStatefulWidget {
  const GalleryHello({
    super.key,
    required this.albumID,
    required this.userProfilePictureUrl,
    required this.userProfileThumbnailUrl,
    required this.username,
    required this.isSaved,
    required this.photos,
    required this.gallery,
    this.sController,
    this.isCurrentUser = false,
  });

  final String albumID;
  final bool isSaved;
  final String userProfilePictureUrl;
  final String userProfileThumbnailUrl;
  final String username;
  final bool isCurrentUser;
  final List<AlbumPostSetModel> photos;
  final GalleryModel gallery;
  final ScrollController? sController;

  @override
  ConsumerState<GalleryHello> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<GalleryHello> {
  final homeCtrl = Get.put<HomeController>(HomeController());
  final _debounce = Debounce();

  // @override
  // void initState() {
  // final photoSet = ref.watch(postSetProvider(widget.albumID));
  // }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ;
    final albumPosts =
        ref.watch(galleryPostsProvider(int.parse(widget.albumID)));
    return Scaffold(
      body: albumPosts.when(data: (items) {
        if (items.isEmpty) {
          return const EmptyPage(
              svgPath: VIcons.gridIcon,
              svgSize: 30,

              // title: "No posts yet",
              subtitle: 'Upload media to see content here.');
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollState) {
            final varof = scrollState; //.metrics;
            final slsl = scrollState.metrics.maxScrollExtent;
            if (scrollState is ScrollEndNotification &&
                scrollState.metrics.pixels == slsl) {
              //print('[ospp] ITs Gooooooo!');
              _debounce(() {
                ref
                    .read(galleryPostsProvider(int.parse(widget.albumID))
                        .notifier)
                    .fetchMoreData();
              });
            }
            return false;
          },
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification? overscroll) {
              overscroll!
                  .disallowIndicator(); //Don't show scroll splash/ripple effect
              return true;
            },
            child: GridView.builder(
                controller: widget.sController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: UploadAspectRatio.portrait.ratio,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: canLoad ? items.length + 3 : items.length,
                itemBuilder: (context, index) {
                  final sss = ref
                      .read(galleryPostsProvider(int.parse(widget.albumID))
                          .notifier)
                      .canLoadMore;
                  if (index >= items.length && sss) {
                    return const PostShimmerPage();
                  }

                  final item = items[index];
                  cachePath(item.photos.first.url);
                  return OpenContainer(
                    closedShape: const RoundedRectangleBorder(),
                    closedBuilder:
                        (BuildContext context, void Function() action) {
                      return GalleryAlbumTile(
                        postId: '${item.id}',
                        photos: item.photos,
                        hasVideo: item.hasVideo,
                        isCurrentUser: widget.isCurrentUser,
                        onLongPress: () {
                          //print("onTile");
                        },
                      );
                    },
                    openBuilder: (BuildContext context,
                        void Function({Object? returnValue}) action) {
                      return GalleryFeedViewHomepage(
                        // isSaved: widget.isSaved,
                        // items: e.photos,
                        // isCurrentUser: widget.isCurrentUser,
                        // postTime: widget.gallery,
                        galleryId: widget.albumID,
                        galleryName: widget.gallery.name,
                        username: widget.username,
                        profilePictureUrl: widget.userProfilePictureUrl,
                        profileThumbnailUrl: widget.userProfileThumbnailUrl,
                        tappedIndex: index,
                      );
                    },
                  );
                }),
          ),
        );
      }, error: (error, stacktrace) {
        return const EmptyPage(
            svgPath: VIcons.gridIcon,
            svgSize: 30,
            subtitle: 'Upload media to see content here.');
      }, loading: () {
        return Center(child: CircularProgressIndicator.adaptive());
      }),
    );
  }

  bool get canLoad {
    return ref
        .read(galleryPostsProvider(int.parse(widget.albumID)).notifier)
        .canLoadMore;
  }

  Widget _createGridTileWidget(
          BuildContext context, List<PhotoPostModel> photos) =>
      Builder(
        builder: (context) => GestureDetector(
          onLongPress: () {},
          // child: Image.asset(url, fit: BoxFit.cover),
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              image: photos.first.url.isHttpOkay
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        photos.first.url,
                        // fit: BoxFit.cover,
                        // placeholder: (context, url) => Container(
                        //   color: Colors.grey.shade300,
                        // ),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photos.length > 1
                ? const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Icon(
                              Icons.photo_album_sharp,
                              color: Colors.white,
                            ),
                          ],
                        )),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      );
}
