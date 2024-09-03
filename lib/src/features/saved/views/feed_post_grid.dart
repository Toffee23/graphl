import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import '../../../core/utils/helper_functions.dart';
import '../../../shared/empty_page/empty_page.dart';

import '../../dashboard/feed/model/feed_model.dart';
import '../../dashboard/new_profile/widgets/gallery_album_tile.dart';

class ExplorePostGrid extends ConsumerStatefulWidget {
  const ExplorePostGrid({
    super.key,
    required this.albumID,
    required this.userProfilePictureUrl,
    required this.userProfileThumbnailUrl,
    required this.username,
    required this.isSaved,
    // required this.photos,
    this.boardId,
    required this.posts,
    this.isCurrentUser = false,
    required this.ontap,
    this.onPaginate,
    this.canPaginate = false,
    // this.onSetCover,
  });

  final String albumID;
  final bool isSaved;
  final String userProfilePictureUrl;
  final String userProfileThumbnailUrl;
  final String username;
  final bool isCurrentUser;
  // final List<AlbumPostSetModel> photos;
  final int? boardId;
  final List<FeedPostSetModel> posts;
  final Function(int _) ontap;
  final Future<void> Function()? onPaginate;
  final bool canPaginate;

  @override
  ConsumerState<ExplorePostGrid> createState() => _ExplorePostGridState();
}

class _ExplorePostGridState extends ConsumerState<ExplorePostGrid> {
  final homeCtrl = Get.put<HomeController>(HomeController());
  final refreshController = RefreshController();

  // @override
  // void initState() {
  // final photoSet = ref.watch(postSetProvider(widget.albumID));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.posts.isEmpty
          ? const EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'Upload media to see content here.')
          : SmartRefresher(
              controller: refreshController,
              enablePullDown: false,
              enablePullUp: widget.canPaginate,
              onLoading: () async {
                if (widget.onPaginate != null) {
                  await widget.onPaginate!();
                  refreshController.loadComplete();
                }
              },
              child: GridView.builder(
                  padding: EdgeInsets.zero,
                  // physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: UploadAspectRatio.portrait.ratio,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: widget.posts.length,
                  itemBuilder: (context, index) {
                    final item = widget.posts[index];
                    cachePath(item.photos.first.url);
                    return GestureDetector(
                        child: GalleryAlbumTile(
                          postId: '${item.id}',
                          photos: item.photos,
                          hasVideo: item.photos.first.mediaType == 'VIDEO',
                          isCurrentUser: widget.isCurrentUser,
                          onLongPress: () {},
                        ),
                        onTap: () {
                          widget.ontap(index);
                        });
                  }),
            ),
    );
  }
}
