import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/features/create_posts/models/post_set_model.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/views/gallery_feed_view_homepage.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/shimmer/shimmerItem.dart';

import 'package:vmodel/src/vmodel.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../create_posts/models/photo_post_model.dart';
import '../model/gallery_model.dart';
import '../model/user_gallery_only_model.dart';
import 'gallery_album_tile.dart';


class Gallery extends ConsumerStatefulWidget {
  const Gallery({
    super.key,
    required this.albumID,
    required this.userProfilePictureUrl,
    required this.userProfileThumbnailUrl,
    required this.username,
    required this.isSaved,
    required this.photos,
    required this.gallery,
    required this.hasVideo,
    this.isCurrentUser = false,
    this.neverScrollable = false,
  });

  final String albumID;
  final bool isSaved;
  final bool hasVideo;
  final String userProfilePictureUrl;
  final String userProfileThumbnailUrl;
  final String username;
  final bool isCurrentUser;
  final List<AlbumPostSetModel>? photos;
  final GalleryModel gallery;
  final bool neverScrollable;

  @override
  ConsumerState<Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<Gallery> {
  final homeCtrl = Get.put<HomeController>(HomeController());

  late final Debounce _debounce;
  List<UserGalleryOnlyModel> photoValue = [];
  bool galleryLoader = true;


  void toggleLoader() async {
    await Future.delayed(Duration(milliseconds: 1500));
    galleryLoader = false;
  }

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
    toggleLoader();
  }

  @override
  Widget build(BuildContext context) {
    final userPrefsConfig = ref.watch(userPrefsProvider);
    final theme = userPrefsConfig.value!.preferredDarkTheme;

    final photos = ref.watch(pBProvider(int.parse('${widget.albumID}')));
    //print("JohnPrints_FeaturedGalleriesCheck $photos");
    return Scaffold(
      body: photos.when(data: (item) {
        // if (galleryLoader == true) {
        //   return shimmerGalleryItem(numOfItem: 10, useGrid:true, context: context);
      
        // }
        if (item.isEmpty)
          return const EmptyPage(
              svgPath: VIcons.gridIcon,
              svgSize: 30,
              // title: "No posts yet",
              subtitle: 'Upload media to see content here.');
        Timer(Duration(seconds: 1), () {
          if (mounted)
            setState(() {
              photoValue = item;
            });
        });
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollState) {
            final varof = scrollState; //.metrics;
            final slsl = scrollState.metrics.maxScrollExtent;
            if (scrollState is ScrollEndNotification && scrollState.metrics.pixels == slsl) {
              _debounce(() {
                ref.read(pBProvider(int.parse('${widget.albumID}')).notifier).fetchMoreData(int.parse('${widget.albumID}'));
              });
            }
            return false;
          },
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: widget.neverScrollable ? NeverScrollableScrollPhysics() : null,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: UploadAspectRatio.portrait.ratio,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: item.length,
            itemBuilder: (context, index) {
              cachePath(item[index].postSets?.first.photos.first.url ?? '');
              // return OpenContainer(
              //   closedShape: const RoundedRectangleBorder(),
              //   closedBuilder:
              //       (BuildContext context, void Function() action) {
              String galleryId = widget.albumID;
              String galleryName = widget.gallery.name;
              String username = widget.username;
              String profilePictureUrl = widget.userProfilePictureUrl;
              String profileThumbnailUrl = widget.userProfileThumbnailUrl;
              int tappedIndex = index;
              return OpenContainer(
                  routeSettings: RouteSettings(name: '/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${tappedIndex}'),
                  onClosed: (data) {
                    ref.read(openContainerOpenedProvider.notifier).state = false;
                  },
                  tappable: false,
                  closedShape: RoundedRectangleBorder(),
                  openBuilder: (context, action) {
                    String galleryId = widget.albumID;
                    String galleryName = widget.gallery.name;
                    String username = widget.username;
                    String profilePictureUrl = widget.userProfilePictureUrl;
                    String profileThumbnailUrl = widget.userProfileThumbnailUrl;
                    int tappedIndex = index;
                    return GalleryFeedViewHomepage(
                      galleryId: galleryId,
                      galleryName: galleryName,
                      username: username,
                      profilePictureUrl: profilePictureUrl,
                      profileThumbnailUrl: profileThumbnailUrl,
                      tappedIndex: tappedIndex,
                    );
                  },
                  closedBuilder: (context, action) {
                    return GestureDetector(
                      onTap: () {
                        ref.read(openContainerOpenedProvider.notifier).state = true;
                        ref.read(openContainerContextProvider.notifier).state = context;
                        action();
                      },
                      child: GalleryAlbumTile(
                        hasVideo: item[index].postSets?.first.hasVideo ?? false,
                        postId: '${item[index].id}',
                        photos: item[index].postSets?.first.photos ?? [],
                        isCurrentUser: widget.isCurrentUser,
                        onLongPress: () {},
                      ),
                    );
                  });
              // return Container(
              //   child: GestureDetector(
              //     onTap: () {
              //       context.push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${tappedIndex}',
              //           extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
              //     },
              //     child: GalleryAlbumTile(
              //       hasVideo: item[index].postSets?.first.hasVideo ?? false,
              //       postId: '${item[index].id}',
              //       photos: item[index].postSets?.first.photos ?? [],
              //       isCurrentUser: widget.isCurrentUser,
              //       onLongPress: () {},
              //     ),
              //   ),
              // );
            },
          ),
        );
      }, error: (error, stackTrace) {
        return EmptyPage(
            svgPath: VIcons.gridIcon,
            svgSize: 30,
            // title: "No posts yet",
            subtitle: 'Upload media to see content.');
      }, loading: () {
        return shimmerGalleryItem(numOfItem: 10, useGrid: true, context: context);
        // if (photoValue.isEmpty) return Text('');
        // var item = photoValue;
        // return NotificationListener<ScrollNotification>(
        //   onNotification: (scrollState) {
        //     final varof = scrollState; //.metrics;
        //     final slsl = scrollState.metrics.maxScrollExtent;
        //     if (scrollState is ScrollEndNotification && scrollState.metrics.pixels == slsl) {
        //       _debounce(() {
        //         ref.read(pBProvider(int.parse('${widget.albumID}')).notifier).fetchMoreData(int.parse('${widget.albumID}'));
        //       });
        //     }
        //     return false;
        //   },
        //   child: GridView.builder(
        //     padding: EdgeInsets.zero,
        //     physics: widget.neverScrollable ? NeverScrollableScrollPhysics() : null,
        //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       childAspectRatio: UploadAspectRatio.portrait.ratio,
        //       crossAxisSpacing: 1,
        //       mainAxisSpacing: 1,
        //     ),
        //     itemCount: item.length,
        //     itemBuilder: (context, index) {
        //       cachePath(item[index].postSets?.first.photos.first.url ?? '');
        //       // return OpenContainer(
        //       //   closedShape: const RoundedRectangleBorder(),
        //       //   closedBuilder:
        //       //       (BuildContext context, void Function() action) {
        //       return OpenContainer(openBuilder: (context, action) {
        //         String galleryId = widget.albumID;
        //         String galleryName = widget.gallery.name;
        //         String username = widget.username;
        //         String profilePictureUrl = widget.userProfilePictureUrl;
        //         String profileThumbnailUrl = widget.userProfileThumbnailUrl;
        //         int tappedIndex = index;
        //         return GalleryFeedViewHomepage(
        //           galleryId: galleryId,
        //           galleryName: galleryName,
        //           username: username,
        //           profilePictureUrl: profilePictureUrl,
        //           profileThumbnailUrl: profileThumbnailUrl,
        //           tappedIndex: tappedIndex,
        //         );
        //       }, closedBuilder: (context, action) {
        //         return GestureDetector(
        //           onTap: () {
        //             // String galleryId = widget.albumID;
        //             // String galleryName = widget.gallery.name;
        //             // String username = widget.username;
        //             // String profilePictureUrl = widget.userProfilePictureUrl;
        //             // String profileThumbnailUrl = widget.userProfileThumbnailUrl;
        //             // int tappedIndex = index;
        //             // context.push('/galleryFeedViewHomepage/${galleryId}/${galleryName}/${username}/${tappedIndex}',
        //             //     extra: {'profilePictureUrl': profilePictureUrl, 'profileThumbnailUrl': profileThumbnailUrl});
        //           },
        //           child: GalleryAlbumTile(
        //             hasVideo: item[index].postSets?.first.hasVideo ?? false,
        //             postId: '${item[index].id}',
        //             photos: item[index].postSets?.first.photos ?? [],
        //             isCurrentUser: widget.isCurrentUser,
        //             onLongPress: () {},
        //           ),
        //         );
        //       });
        //     },
        //   ),
        // );
      }),
    );
  }

  Widget _createGridTileWidget(BuildContext context, List<PhotoPostModel> photos) => Builder(
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
