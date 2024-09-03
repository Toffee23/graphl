import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../res/icons.dart';
import '../../../../res/res.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../jobs/job_market/views/search_field.dart';
import '../../new_profile/widgets/gallery_album_tile.dart';
import '../controllers/explore_posts_controller.dart';
import '../controllers/hash_tag_search_controller.dart';
import '../controllers/indexed_feed_posts_controller.dart';
import '../models/indexed_feed_type_tag.dart';
import 'discover_user_search.dart/views/hashtag_feed.dart';

class Explore extends ConsumerStatefulWidget {
  const Explore({super.key, this.title = "Trending"});
  final String title;

  @override
  ExploreState createState() => ExploreState();
}

class ExploreState extends ConsumerState<Explore> {
  // GalleryModel? gallery;
  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;

  final _scrollController = ScrollController();
  int _tappedIndex = 0;

  @override
  initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener);
    _searchController.text = ref.read(hashTagSearchOnExploreProvider.notifier).state ?? '';
    _debounce = Debounce(delay: Duration(milliseconds: 300));
  }

  @override
  dispose() {
    ref.invalidate(hashTagSearchOnExploreProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchHashList = ref.watch(hashTagProvider);

    ref.watch(tappedPostIndexProvider(_searchController.text));
    final searchHashList2 = ref.watch(indexedFeedPostsProvider(IndexedFeedTypeTag(type: IndexedFeedType.trending, tag: _searchController.text)));
    // ref.watch(trendingPostsProvider(_searchController.text));

    // final searchTerm = ref.watch(hashTagSearchProvider);

    return Scaffold(
        // appBar: VWidgetsAppBar(
        //   leadingIcon:
        //       exlporePage.isExplore ? null : const VWidgetsBackButton(),
        //   appbarTitle: "Explore",
        //   // customBottom: ,
        // ),
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            pinned: true,

            floating: true,
            expandedHeight: SizerUtil.height * .15,
            title: Text(
              // "Explore",
              widget.title,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: _titleSearch(),
            ),
            // leadingWidth: 15j,
            leading: const VWidgetsBackButton(),

            actions: [],
          ),
        ];
      },
      body: searchHashList2.when(
          // return HashtagSearchGridPage(
          //   // posts: searchHashList,
          //   title: ref.watch(hashTagSearchOnExploreProvider)!,
          // );
          data: (values) {
            return values.isEmpty
                ? const EmptyPage(svgPath: VIcons.gridIcon, svgSize: 30, subtitle: 'No content found')
                : NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (OverscrollIndicatorNotification? overscroll) {
                      overscroll!.disallowIndicator(); //Don't show scroll splash/ripple effect
                      return true;
                    },
                    child: GridView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: EdgeInsets.only(bottom: 250),
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: UploadAspectRatio.portrait.ratio,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          final item = values[index];
                          // cachePath(item.photos.first.url);
                          return OpenContainer(
                            closedShape: const RoundedRectangleBorder(),
                            closedBuilder: (BuildContext context, void Function() action) {
                              return GalleryAlbumTile(
                                postId: '${item.id}',
                                photos: item.photos,
                                hasVideo: item.hasVideo,
                                // isCurrentUser: widget.isCurrentUser,
                                isCurrentUser: true,
                                onLongPress: () {
                                  //print("onTile");
                                },
                              );
                            },
                            openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                              _tappedIndex = index;
                              return HashtagListView(
                                tag: _searchController.text,
                                // isSaved: widget.isSaved,
                                // items: e.photos,
                                // isCurrentUser: widget.isCurrentUser,
                                // postTime: widget.gallery,
                                // galleryId: widget.albumID,
                                // posts: widget.posts,
                                galleryName: widget.title,
                                username: '',
                                profilePictureUrl: '',
                                profileThumbnailUrl: '',
                                tappedIndex: _tappedIndex,
                                indexedFeedType: IndexedFeedType.trending,
                                onRefresh: () async {
                                  VMHapticsFeedback.lightImpact();
                                  // index = 0;
                                  _tappedIndex = 0;
                                  ref.invalidate(tappedPostIndexProvider);
                                  setState(() {});
                                  await ref.refresh(hashTagProvider.future);
                                },
                              );
                            },
                          );
                        }),
                  );
            // return GridView.builder(
            //   itemCount: data.length,
            //   padding:
            //       const EdgeInsets.only(top: 20, bottom: 300),
            //   gridDelegate:
            //       SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     crossAxisSpacing: 20,
            //     mainAxisSpacing: 20,
            //     childAspectRatio: .85,
            //   ),
            //   itemBuilder: (context, index) {
            //     return HashTagView(
            //         image: data[index].photos[0].url,
            //         title: "");
            //   },
            // );
          },
          error: (error, stackStace) {
            return Text(error.toString());
          },
          loading: () => Center(child: CircularProgressIndicator.adaptive())),
      // HashtagSearchGridPage(),

      // galleries.when(data: (value) {
      //   if (value.isEmpty) {
      //     return const EmptyPage(
      //       svgSize: 30,
      //       svgPath: VIcons.gridIcon,
      //       // title: 'No Galleries',
      //       subtitle: 'Upload media to see content here.',
      //     );
      //   }

      //   final e = value.first;

      //   return Gallery(
      //     isSaved: false,
      //     isCurrentUser: true,
      //     albumID: e.id,
      //     photos: e.postSets,
      //     username: "user!.username",
      //     userProfilePictureUrl: "${user?.profilePictureUrl}",
      //     userProfileThumbnailUrl: '${user?.thumbnailUrl}',
      //     gallery: e,
      //   );
      // }, error: (err, stackTrace) {
      //   return Text('There was an error showing albums $err');
      // }, loading: () {
      //   return const Center(child: CircularProgressIndicator.adaptive());
      // }),
    ));
  }

  Widget _titleSearch() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          addVerticalSpacing(70),
          Container(
            padding: const VWidgetsPagePadding.horizontalSymmetric(18),
            alignment: Alignment.bottomCenter,
            child: SearchTextFieldWidget(
              hintText: "Search...",
              controller: _searchController,
              // onChanged: (val) {},

              onTapOutside: (event) {
                // ref.invalidate(showRecentViewProvider);
                // _searchController.clear();
                RenderBox? textBox = context.findRenderObject() as RenderBox?;
                Offset? offset = textBox?.localToGlobal(Offset.zero);
                double top = offset?.dy ?? 0;
                top += 200;
                double bottom = top + (textBox?.size.height ?? 0);
                if (event is PointerDownEvent) {
                  if (event.position.dy >= 140) {
                    // Tapped within the bounds of the ListTile, do nothing
                    return;
                  } else {}
                }
              },
              onTap: () {
                // if (_searchController.text.isNotEmpty) {
                //   ref
                //       .read(discoverProvider.notifier)
                //       .searchUsers(_searchController.text.trim());
                //   ref.read(showRecentViewProvider.notifier).state = true;
                // } else {
                //   ref.read(showRecentViewProvider.notifier).state = false;
                // }
              },
              // focusNode: myFocusNode,
              onCancel: () {
                _searchController.text = '';

                // showRecentSearches = false;
                // typingText = '';
                // myFocusNode.unfocus();
                setState(() {});
                ref.read(hashTagSearchProvider.notifier).state = _searchController.text;

//today
                ref.read(trendingPostsProvider('').notifier);
                setState(() {});
              },
              onChanged: (val) {
                _debounce(
                  () {
                    // ref.read(hashTagSearchProvider.notifier).state = val;
                    ref.read(trendingPostsProvider(val).notifier);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollListener() {
    //print("[jiww0] scroll listener triggered");
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      // _isLoadMore = true;
      //print("[jiww0] scroll listener fetch more...");
      _debounce(() {
        ref.read(hashTagProvider.notifier).fetchMoreHandler();
      });

      // if (_isLoadMore) {
      //   _pageCount++;
      // }
      setState(() {});
    }
  }
}
