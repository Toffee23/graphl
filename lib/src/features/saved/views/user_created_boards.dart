import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_provider.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../controller/provider/current_selected_board_provider.dart';
import '../controller/provider/user_boards_controller.dart';
import '../model/user_post_board_model.dart';
import '../widgets/text_overlayed_image.dart';
import 'explore_v2.dart';

class UserCreatedBoardsWidget extends ConsumerStatefulWidget {
  const UserCreatedBoardsWidget(
      {super.key,
      required this.boards,
      required this.mockImages,
      required this.scrollBack,
      this.title,
      this.itemSize,
      this.buttonPadding = EdgeInsets.zero,
      this.mainAxisSpacing = 12,
      this.crossAxisSpacing = 12});

  final Size? itemSize;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List mockImages;
  final List<UserPostBoard> boards;
  final String? title;
  final VoidCallback scrollBack;
  final EdgeInsetsGeometry buttonPadding;

  @override
  ConsumerState<UserCreatedBoardsWidget> createState() => UserCreatedBoardsWidgetState();
}

class UserCreatedBoardsWidgetState extends ConsumerState<UserCreatedBoardsWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalBoardsNumber = ref.watch(userBoardsTotalNumberProvider);
    final hiddenPosts = ref.watch(getHiddenPostProvider);

    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      key: Key("value"),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title!,
                  style: textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: widget.mainAxisSpacing,
          runSpacing: widget.crossAxisSpacing,
          children: [
            hiddenPosts.when(data: (items) {
              if (items == null) return SizedBox.shrink();
              if (items.isEmpty) return SizedBox.shrink();
              return Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: EdgeInsets.zero,
                child: TextOverlayedImage(
                  size: widget.itemSize,
                  imageUrl: items.first.photos.first.mediaType == 'VIDEO' ? items.first.photos.first.thumbnail! : items.first.photos.first.url,
                  title: 'Hidden posts',
                  gradientStops: [0.75, 1],
                  onTap: () {
                    navigateToRoute(
                        context,
                        ExploreV2(
                          boardId: 0,
                          title: 'Hidden Posts',
                          providerType: BoardProvider.hidden,
                        ));
                  },
                  onLongPress: () {},
                ),
              );
            }, error: (error, stackTrace) {
              return SizedBox.shrink();
            }, loading: () {
              return SizedBox.shrink();
            }),
            ...getBoards(),
          ],
        ),
        addVerticalSpacing(40),
      ],
    );
  }

  List<Widget> getBoards() {
    List<Widget> items = [];
    // for (int i = 0; i < itemsLen; i++) {
    //   if (widget.boards.length % 2 == 1 && i == widget.boards.length) {
    //     items.add(
    //       RoundedSquareAvatar(
    //         url: '',
    //         thumbnail: '',
    //         size: UploadAspectRatio.portrait.sizeFromX(43.w),
    //         errorWidget: ColoredBox(
    //           color: Colors.transparent,
    //         ),
    //       ),
    //     );
    //     continue;
    //   }
    for (var e in widget.boards) {
      items.add(
        Padding(
          padding: EdgeInsets.zero,
          child: TextOverlayedImage(
            size: widget.itemSize,
            imageUrl: e.coverImageUrl != null ? e.coverImageUrl! : '${e.photos!.isNotEmpty ? (e.photos?.first.mediaType == 'VIDEO' ? e.photos?.first.thumbnail : e.photos?.first.url) : ''}',
            title: e.title,
            gradientStops: [0.75, 1],
            onTap: () {
              ref.read(currentSelectedBoardProvider.notifier).setOrUpdateBoard(
                    SelectedBoard(
                      board: e,
                      source: SelectedBoardSource.userCreatd,
                    ),
                  );

              navigateToRoute(
                  context,
                  ExploreV2(
                    boardId: e.id,
                    title: e.title,
                    providerType: BoardProvider.userCreated,
                    // userPostBoard: widget.boards[index],
                  ));
            },
            onLongPress: () {},
          ),
        ),
      );
    }
    // final e = widget.boards[i];
    // if (e.numberOfPosts != 0) {

    // }
    // }
    return items;
  }

  int get itemsLen {
    final boardsLen = widget.boards.length;
    if (boardsLen == 0) return boardsLen;
    return boardsLen % 2 == 0 ? boardsLen : boardsLen + 1;
  }

  void _buttonPressed() {
    final totalBoardsNumber = ref.watch(userBoardsTotalNumberProvider);
    if (!isExpanded) {
      isExpanded = true;
      setState(() {});
    } else if (totalBoardsNumber > widget.boards.length) {
      //loadMore
      ref.read(userPostBoardsProvider.notifier).fetchMoreData();
      isExpanded = true;
      setState(() {});
    } else {
      setState(() => isExpanded = !isExpanded);
      if (!isExpanded) {
        widget.scrollBack();
      }
    }
  }

  String get _buttonText {
    final totalBoardsNumber = ref.watch(userBoardsTotalNumberProvider);
    if (isExpanded && totalBoardsNumber == widget.boards.length) {
      return "Collapse";
    }
    return "Expand";
  }

  Widget defaultBoard({
    required String title,
    required String thumbnail,
    required String assetPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Text(
          //   title,
          //   style: context.textTheme.displayMedium!.copyWith(
          //     fontSize: 13.sp,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // addVerticalSpacing(10),
        ],
      ),
    );
  }
}
