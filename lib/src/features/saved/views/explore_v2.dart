import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/saved/controller/provider/user_boards_controller.dart';
import 'package:vmodel/src/features/saved/views/saved_list_view.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:vmodel/src/res/icons.dart';
import '../../../res/res.dart';
import '../../../shared/bottom_sheets/confirmation_bottom_sheet.dart';
import '../../../shared/bottom_sheets/tile.dart';
import '../../../shared/buttons/text_button.dart';
import '../../../shared/empty_page/empty_page.dart';

import '../../../core/utils/debounce.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../../shared/rend_paint/render_svg.dart';
import '../../authentication/register/provider/user_types_controller.dart';
import '../../dashboard/feed/widgets/comment/create_new_board_dialogue.dart';
import '../controller/provider/board_posts_controller.dart';
import '../controller/provider/current_selected_board_provider.dart';
import '../controller/provider/saved_provider.dart';
import '../../dashboard/feed/model/feed_model.dart';
import 'feed_post_grid.dart';
import 'select_board_cover_img_grid.dart';

class ExploreV2 extends ConsumerStatefulWidget {
  const ExploreV2({
    super.key,
    required this.providerType,
    required this.title,
    required this.boardId,
    // this.userPostBoard,
    // this.userPostBoard?.id,
  });

  final BoardProvider providerType;
  // final UserPostBoard? userPostBoard;
  final String title;
  final int boardId;
  // final int? userPostBoard?.id;

  @override
  ExploreV2State createState() => ExploreV2State();
}

class ExploreV2State extends ConsumerState<ExploreV2> {
  // ExplorePostGridModel? gallery;
  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;
  final ValueNotifier<bool> _showLoading = ValueNotifier(false);
  String _mTitle = '';
  final refreshController = RefreshController();

  @override
  initState() {
    super.initState();
    _mTitle = widget.title;
    _debounce = Debounce(delay: Duration(milliseconds: 300));
  }

  @override
  dispose() {
    super.dispose();
    _debounce.dispose();
  }

  bool showView = false;
  int tappedIndex = 0;
  List<FeedPostSetModel> _value = [];

  @override
  Widget build(BuildContext context) {
    final selectedBoard = ref.watch(currentSelectedBoardProvider);
    final userTypes = ref.watch(accountTypesProvider);
    AsyncValue<List<FeedPostSetModel>?> savedData;
    switch (widget.providerType) {
      case BoardProvider.allPosts:
        savedData = ref.watch(getsavedPostProvider);
        break;
      case BoardProvider.hidden:
        savedData = ref.watch(getHiddenPostProvider);
        break;
      case BoardProvider.userCreated:
        if (isUserBoardNull(selectedBoard)) {
          return EmptyPage(
            svgPath: VIcons.documentLike,
            svgSize: 30,
            subtitle: 'Invalid id',
          );
        }
        try {
          savedData = ref.watch(boardPostsProvider(selectedBoard!.board.id));
        } catch (e) {
          savedData = ref.watch(boardPostsProvider(selectedBoard!.board.id));
        }
        break;
    }

    // final savedData = ref.watch(getsavedPostProvider);

    return showView
        ? SavedListView(
            // isSaved: widget.isSaved,
            // items: e.photos,
            // isCurrentUser: widget.isCurrentUser,
            // postTime: widget.gallery,
            // galleryId: widget.albumID,
            posts: _value,
            galleryName: widget.title,
            username: "user!.username",
            profilePictureUrl: "",
            profileThumbnailUrl: '',
            tappedIndex: tappedIndex,
            boardId: widget.boardId,
          )
        : Scaffold(
            appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              // expandedHeight: 117,
              title: Text(
                _mTitle,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              centerTitle: true,
              leading: const VWidgetsBackButton(),

              actions: [
                if (widget.title != 'Hidden Posts')
                  if (!isUserBoardNull(selectedBoard))
                    IconButton(
                      onPressed: () {
                        VMHapticsFeedback.lightImpact();
                        _showMoreBottomSheet();
                      },
                      icon: const RenderSvg(svgPath: VIcons.moreIcon),
                    ),
              ],
            ),
            body: savedData.when(data: (value) {
              if (value == null || value.isEmpty) {
                return const EmptyPage(
                  svgSize: 30,
                  svgPath: VIcons.gridIcon,
                  subtitle: 'No content',
                );
              }

              return ExplorePostGrid(
                  boardId: selectedBoard?.board.id,
                  isSaved: false,
                  isCurrentUser: false,
                  albumID: 'Slll',
                  username: "user!.username",
                  userProfilePictureUrl: "",
                  userProfileThumbnailUrl: '',
                  posts: value,
                  canPaginate:
                      ref.watch(getsavedPostProvider.notifier).canLoadMore(),
                  onPaginate: () async {
                    if (widget.providerType == BoardProvider.allPosts) {
                      await ref
                          .read(getsavedPostProvider.notifier)
                          .fetchMoreData();
                    }
                  },
                  ontap: (index) {
                    _value = value;
                    tappedIndex = index;
                    setState(() {
                      showView = true;
                    });
                  });
            }, error: (err, stackTrace) {
              return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: EmptyPage(
                    svgSize: 30,
                    svgPath: VIcons.aboutIcon,
                    // title: 'No Galleries',
                    subtitle: 'An error occcured',
                  )));
            }, loading: () {
              return const Center(child: CircularProgressIndicator.adaptive());
            }),
          );
  }

  Future<void> _showMoreBottomSheet() {
    final selectedBoard = ref.watch(currentSelectedBoardProvider);
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        builder: (BuildContext context) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                // color: Theme.of(context).scaffoldBackgroundColor,
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVerticalSpacing(20),
                  const Align(
                      alignment: Alignment.center, child: VWidgetsModalPill()),
                  addVerticalSpacing(25),
                  VWidgetsBottomSheetTile(
                    onTap: () {
                      if (isUserBoardNull(selectedBoard)) {
                        return;
                      }
                      if (context.mounted) {
                        popSheet(context);
                      }
                      navigateToRoute(
                          context,
                          SelectedBoardCoverGrid(
                            boardId: selectedBoard!.board.id,
                          ));
                    },
                    message: "Change Cover",
                  ),
                  if (!isUserBoardNull(selectedBoard)) ...[
                    const Divider(thickness: 0.5),
                    addVerticalSpacing(10),
                    VWidgetsBottomSheetTile(
                      onTap: () async {
                        if (isUserBoardNull(selectedBoard)) {
                          return;
                        }

                        final success = await ref
                            .read(userPostBoardsProvider.notifier)
                            .togglePinnedStatus(
                              boardId: selectedBoard.board.id,
                              // pinnedStatus: selectedBoard!.pinned,
                            );
                        if (success && context.mounted) {
                          goBack(context);
                          // responseDialog(
                          //     context,
                          //     selectedBoard.board.pinned
                          //         ? "Board unpinned"
                          //         : 'Board pinned');
                          //     context: context);
                          SnackBarService().showSnackBar(
                              context: context,
                              message: selectedBoard.board.pinned
                                  ? "Board unpinned"
                                  : 'Board pinned');
                        }
                      },
                      message: selectedBoard!.board.pinned
                          ? "Unpin Board"
                          : "Pin Board",
                    ),
                    const Divider(thickness: 0.5),
                    addVerticalSpacing(10),
                    VWidgetsBottomSheetTile(
                        onTap: () async {
                          if (isUserBoardNull(selectedBoard)) {
                            return;
                          }

                          showAnimatedDialog(
                              context: context,
                              child: CreateNewBoardDialog(
                                title: 'Rename board',
                                buttonText: 'Rename',
                                controller:
                                    TextEditingController(text: widget.title),
                                onSave: (title) async {
                                  final success = await ref
                                      .read(userPostBoardsProvider.notifier)
                                      .renameUserBoard(
                                        newTitle: title,
                                        boardId: selectedBoard.board.id,
                                      );
                                  _mTitle = title.trim();
                                  setState(() {});
                                  await Future.delayed(
                                    Duration(milliseconds: 500),
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                    // responseDialog(context, "Board renamed");
                                    SnackBarService().showSnackBar(
                                      context: context,
                                      message: "Board renamed",
                                    );
                                  }
                                },
                              ));
                        },
                        message: 'Rename board'),
                    const Divider(thickness: 0.5),
                  ],
                  addVerticalSpacing(10),
                  VWidgetsBottomSheetTile(
                      showWarning: true,
                      onTap: () {
                        if (isUserBoardNull(selectedBoard)) {
                          return;
                        }
                        if (context.mounted) {
                          goBack(context);
                        }
                        _showDeleteConfirmation();
                      },
                      message: 'Delete Board'),
                  addVerticalSpacing(10),
                ],
              ));
        });
  }

  // getProvider

  bool isUserBoardNull(SelectedBoard? board) {
    return board == null;
  }

  void _showDeleteConfirmation() {
    final selectedBoard = ref.watch(currentSelectedBoardProvider);

    showModalBottomSheet<Widget>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: 50.h),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
              // color: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              title: "Are you sure you want to delete comment?",
              actions: [
                ValueListenableBuilder(
                    valueListenable: _showLoading,
                    builder: (context, value, _) {
                      return VWidgetsTextButton(
                        text: 'Delete',
                        showLoadingIndicator: value,
                        onPressed: () async {
                          _showLoading.value = true;

                          final success = await ref
                              .read(userPostBoardsProvider.notifier)
                              .deleteUserBoard(
                                boardId: selectedBoard!.board.id,
                                // pinnedStatus: selectedBoard!.pinned,
                              );
                          if (success) {
                            goBack(context);
                            // responseDialog(context,
                            //     '${selectedBoard.board.title} deleted');
                            SnackBarService().showSnackBar(
                                context: context,
                                message:
                                    '${selectedBoard.board.title} deleted');
                          }
                          _showLoading.value = false;
                          if (context.mounted) {
                            goBack(context);
                          }
                        },
                      );
                    }),
                // if (!showLoader)
                const Divider(
                  thickness: 0.5,
                ),
                // Connect
                // if (!showLoader)
                VWidgetsBottomSheetTile(
                    onTap: () {
                      if (context.mounted) {
                        goBack(context);
                      }
                    },
                    message: 'Cancel')
              ],
            ),
          );
        });
      },
    );
  }
}
