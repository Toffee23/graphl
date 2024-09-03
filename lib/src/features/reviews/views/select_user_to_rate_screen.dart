import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/composite_search_controller.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/discover_controller.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/reviews/widgets/discover_user_search.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/normal_back_button.dart';
import 'package:vmodel/src/shared/page_padding/page_padding.dart';

class SelectUserRateScreen extends ConsumerStatefulWidget {
  const SelectUserRateScreen({super.key});

  @override
  ConsumerState<SelectUserRateScreen> createState() => _SelectUserRateScreenState();
}

class _SelectUserRateScreenState extends ConsumerState<SelectUserRateScreen> with TickerProviderStateMixin {
  String typingText = "";
  bool isLoading = true;
  bool showRecentSearches = false;
  bool isExpanded = false;

  FocusNode searchfocus = FocusNode();

  ScrollController _controller = ScrollController();

  // FocusNode myFocusNode = FocusNode();
  late Future getFeaturedTalents;
  late Future getRisingTalents;
  late Future getPhotgraphers;
  late Future getPetModels;

  final TextEditingController _searchController = TextEditingController();
  late final Debounce _debounce;
  bool showHint = false;

  double _scrollOffset = 0.0;
  int? initialSearchPageIndex = 0;
  late AnimationController _bellController;

  changeTypingState(String val) {
    typingText = val;
    setState(() {});
  }

  @override
  void initState() {
    // startLoading();
    super.initState();
    _bellController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _debounce = Debounce(delay: Duration(milliseconds: 300));

    searchfocus.addListener(onFocusSearch);

    ref.read(discoverProvider.notifier).updateSearchController(_searchController);
    hideHint();
    _controller.addListener(() {
      _scrollOffset = _controller.offset;
    });
    initialSearchString();
  }

  void onFocusSearch() {}

  void initialSearchString() {}

  void hideHint() async {
    if (!showHint) {
      await Future.delayed(Duration(seconds: 2));
      if (mounted) setState(() => showHint = true);
      await Future.delayed(Duration(seconds: 4));
      if (mounted) setState(() => showHint = false);
    }
  }

  @override
  void dispose() {
    //print('os92c Disposing search user');
    searchfocus.removeListener(onFocusSearch);
    _searchController.dispose();
    // myFocusNode.dispose();
    _debounce.dispose();
    _bellController.dispose();
    super.dispose();
  }

  String selectedChip = "Models";

  @override
  Widget build(BuildContext context) {
    final discoverProviderState = ref.watch(discoverProvider);

    return Portal(
      child: Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appbarTitle: "",
        ),
        body: Stack(
          children: [
            Scaffold(
              body: CustomScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    pinned: true,
                    floating: true,
                    expandedHeight: ref.watch(showRecentViewProvider) ? 170 : 120.0,
                    title: Text(
                      "Search User",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    centerTitle: false,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: _titleSearch(),
                    ),
                    leadingWidth: 8,
                    leading: SizedBox.shrink(),
                  ),
                  discoverProviderState.when(data: (discoverItems) {
                    if (ref.watch(showRecentViewProvider)) {
                      return UserSearchMainView(
                        initialSearchPageIndex: initialSearchPageIndex,
                      );
                    }

                    if (discoverItems == null) {
                      return SliverToBoxAdapter(child: Text('Got null data'));
                    }

                    return SliverList.list(
                      children: [],
                    );
                  }, error: (error, stackTrace) {
                    return SliverFillRemaining(
                        child: Center(
                            child: Text(
                      'Oops, something went wrong\nPull down to refresh',
                      textAlign: TextAlign.center,
                    )));
                  }, loading: () {
                    return const SliverFillRemaining(child: SizedBox());
                  }),
                ],
              ),
            ),
            // if (showHint)
            //   HintDialogue(
            //     onTapDialogue: () => setState(() => showHint = false),
            //     text: 'Tap to access messages',
            //   )
          ],
        ),
      ),
    );
  }

  Widget _titleSearch() {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              addVerticalSpacing(70),
              Container(
                padding: const VWidgetsPagePadding.horizontalSymmetric(18),
                alignment: Alignment.bottomCenter,
                child: SearchTextFieldWidget(
                  hintText: "Search a user...",
                  controller: _searchController,
                  // onChanged: (val) {},
                  focusNode: searchfocus,
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
                    if (_searchController.text.isNotEmpty) {
                      ref.read(discoverProvider.notifier).searchUsers(_searchController.text.trim());
                      ref.read(showRecentViewProvider.notifier).state = true;
                    } else {
                      ref.read(showRecentViewProvider.notifier).state = false;
                    }
                  },
                  // focusNode: myFocusNode,
                  onCancel: () {
                    initialSearchPageIndex = 0;
                    ref.invalidate(searchTabProvider);
                    _searchController.text = '';
                    showRecentSearches = false;
                    typingText = '';
                    setState(() {});
                    searchfocus.unfocus();

                    ref.read(showRecentViewProvider.notifier).state = false;
                  },
                  onChanged: (val) {
                    _debounce(
                      () {
                        ref.read(compositeSearchProvider.notifier).updateState(query: val);
                      },
                    );
                    setState(() {
                      typingText = val;
                    });
                    if (val.isNotEmpty) {
                      ref.read(showRecentViewProvider.notifier).state = true;
                    } else {
                      ref.read(showRecentViewProvider.notifier).state = false;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
