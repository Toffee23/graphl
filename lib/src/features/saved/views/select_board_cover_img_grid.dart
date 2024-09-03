import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/validators_mixins.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_controller.dart';
import 'package:vmodel/src/res/icons.dart';
import '../../../core/utils/helper_functions.dart';
import '../../../shared/appbar/appbar.dart';
import '../../../shared/empty_page/empty_page.dart';

import '../../../shared/picture_styles/pick_image_widget.dart';
import '../../dashboard/new_profile/widgets/gallery_album_tile.dart';
import '../controller/provider/board_posts_controller.dart';
import '../controller/provider/user_boards_controller.dart';

class SelectedBoardCoverGrid extends ConsumerStatefulWidget {
  const SelectedBoardCoverGrid({
    super.key,
    // required this.albumID,
    // required this.isSaved,
    // required this.photos,
    required this.boardId,
    // required this.posts,
    this.isCurrentUser = false,
    // this.isSelectCoverImageActivated = false,
    // this.onSetCover,
  });

  // final String albumID;
  // final bool isSaved;
  final bool isCurrentUser;
  // final bool isSelectCoverImageActivated;
  // final List<AlbumPostSetModel> photos;
  final int boardId;
  // final List<FeedPostSetModel> posts;
  // final Future<bool> Function()? onSetCover;

  @override
  ConsumerState<SelectedBoardCoverGrid> createState() =>
      SelectedBoardCoverGridState();
}

class SelectedBoardCoverGridState
    extends ConsumerState<SelectedBoardCoverGrid> {
  final homeCtrl = Get.put<HomeController>(HomeController());

  // @override
  // void initState() {
  // final photoSet = ref.watch(postSetProvider(widget.albumID));
  // }

  @override
  Widget build(BuildContext context) {
    final boardPosts = ref.watch(boardPostsProvider(widget.boardId));
    return Scaffold(
      appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(), appbarTitle: "Select cover image"),
      body: boardPosts.when(data: (values) {
        if (values.isEmpty)
          return const EmptyPage(
              svgPath: VIcons.gridIcon,
              svgSize: 30,
              subtitle: 'Upload media to see content here.');
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification? overscroll) {
            overscroll!
                .disallowIndicator(); //Don't show scroll splash/ripple effect
            return true;
          },
          child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: UploadAspectRatio.portrait.ratio,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                  return VWidgetsAddImageWidget(
                    radius: 0,
                    onTap: () async {
                      final imagePath = await imagePicker();
                      _setCover(boardId: widget.boardId, imagePath: imagePath);
                    },
                  );
                final item = values[index - 1];

                return GestureDetector(
                  onTap: () async {
                    _setCover(
                      boardId: widget.boardId,
                      url: item.photos.first.mediaType == 'VIDEO'?item.photos.first.thumbnail:item.photos.first.url,
                    );
                  },
                  child: GalleryAlbumTile(
                    postId: '${item.id}',
                    photos: item.photos,
                    hasVideo: item.hasVideo,
                    isCurrentUser: widget.isCurrentUser,
                    onLongPress: () {
                    },
                  ),
                );
              }),
        );
      }, error: ((error, stackTrace) {
        return Container(
            width:MediaQuery.of(context).size.width,
            child:Center(
                child:EmptyPage(
                  svgSize: 30,
                  svgPath: VIcons.aboutIcon,
                  // title: 'No Galleries',
                  subtitle: 'An error occcured',
                )
            )
        );
      }), loading: () {
        return Center(
          child: CircularProgressIndicator.adaptive(),
        );
      }),
    );
  }

  Future<void> _setCover({
    required int boardId,
    String? imagePath,
    String? url,
  }) async {

    final success =
        await ref.read(userPostBoardsProvider.notifier).setPostBoardCoverImage(
              boardId: widget.boardId,
              selectedImage: imagePath.isEmptyOrNull ? null : File(imagePath!),
              imageUrl: url,
            );

    if (success) {
      goBack(context);
      // responseDialog(context, "Cover updated");
      SnackBarService().showSnackBar(
        context: context,message:    "Cover updated");
    }

  }
}
