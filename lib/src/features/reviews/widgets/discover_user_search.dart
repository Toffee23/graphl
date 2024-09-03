import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/cache/hive_provider.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/dashboard/discover/controllers/discover_controller.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/models/list_of_users.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/views/dis_search_main_screen.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_user_search.dart/widgets/dis_user_search_tile.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/vmodel.dart';

class UserSearchMainView extends ConsumerStatefulWidget {
  const UserSearchMainView({
    super.key,
    this.initialSearchPageIndex = 0,
  });
  final int? initialSearchPageIndex;

  @override
  ConsumerState<UserSearchMainView> createState() => _UserSearchMainViewState();
}

class _UserSearchMainViewState extends ConsumerState<UserSearchMainView> with SingleTickerProviderStateMixin {
  String storeValue = '';
  bool shouldShowRecent = true;
  FocusNode searchFieldFocus = FocusNode();
  late TabController controller;
  List _tabs = ["Members"];

  @override
  void initState() {
    super.initState();
    checkStorageData();
    controller = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialSearchPageIndex!);
  }

  checkStorageData() async {}

  Iterable<UserData> filteredUserList = userDataList();
  Iterable<UserData> popular = userDataList();
  Iterable<UserData> recent = userDataList();

  filterUserData(String searchText) {
    setState(() {
      if (searchText.isNotEmpty) {
        Iterable<UserData> searchList = userDataList().where((element) => element.name.toLowerCase().toString().contains(searchText.toLowerCase().toString()));

        filteredUserList = searchList;
        ref.read(showRecentViewProvider.notifier).state = false;
      } else {
        filteredUserList = userDataList();
        if (filteredUserList.isNotEmpty) {
          ref.read(showRecentViewProvider.notifier).state = true;
        } else {
          ref.read(showRecentViewProvider.notifier).state = false;
        }
      }
    });

    VModelSharedPrefStorage().putObject(discoverStoaregKey, {'userDataSavedList': filteredUserList}.toString());
  }

  removeUserFromList(UserData userToBeRemoved) {
    List<UserData> removeList = [];
    setState(() {
      for (var element in filteredUserList) {
        removeList.add(element);
      }
      removeList.removeWhere((element) => element == userToBeRemoved);
    });
  }

  clearRecent() {
    setState(() {
      VModelSharedPrefStorage().clearObject(discoverStoaregKey);
    });
  }

  @override
  void dispose() {
    ref.invalidate(showRecentViewProvider);
    ref.invalidate(showRecentViewProvider);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchList = ref.watch(searchUsersProvider);

    final recentlyViewedProfileList = ref.watch(hiveStoreProvider.notifier);
    final recents = recentlyViewedProfileList.getRecentlyViewedList();
    final currentUsername = ref.watch(appUserProvider).valueOrNull?.username;
    return SliverList.list(
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: controller,
                tabs: _tabs
                    .map((e) => Tab(
                            child: Text(
                          e,
                        )))
                    .toList(),
                onTap: (value) async {},
              ),
              SizedBox(
                width: SizerUtil.width * .99,
                height: SizerUtil.height * .9,
                child: TabBarView(
                  controller: controller,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((searchList.valueOrNull ?? []).isEmpty &&
                              ref.watch(discoverProvider.notifier).searchController.text.isEmpty &&
                              recents.isNotEmpty)
                            Column(
                              children: [
                                _headingText(mainText: "Recent", trailingButtonText: "Clear"),
                                ...recents.map((e) {
                                  return VWidgetDiscoverUserTile(
                                    onPressedRemove: () {},
                                    onPressedProfile: () {
                                      _showReviewBottomSheet(context, username: e.username);
                                    },
                                    userImage: e.profilePictureUrl,
                                    userImageThumbnail: e.thumbnailUrl,
                                    userName: e.username,
                                    userType: e.labelOrUserType,
                                    userNickName: e.displayName,
                                    isVerified: e.isVerified,
                                    blueTickVerified: e.blueTickVerified,
                                  );
                                }),
                                addVerticalSpacing(24),
                              ],
                            ),
                          _searchListCol(searchList, recents.toList(), currentUsername),
                          addVerticalSpacing(300)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchListCol(AsyncValue<List<VAppUser>> searchList, List<VAppUser> recents, String? username) {
    final controller = ref.watch(discoverProvider.notifier).searchController;
    return searchList.when(data: (value) {
      //print('VVVVVVVVVV is empty ${value.isEmpty}');
      //print('SERRRRCHHHHH field is ${controller.text}');
      if (value.isEmpty) {
        // && controller.text.isNotEmpty) {
        return SizedBox.shrink();
        // return const Padding(
        //   padding: EdgeInsets.all(16.0),
        //   child: Text('No users found'),
        // );
      }

      return Column(
        children: [
          // _headingText(mainText: "Result", trailingButtonText: "Clear"),
          addVerticalSpacing(16),
          // ...filteredUserList.map((e) {
          ...value.map((e) {
            return Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return VWidgetDiscoverUserTile(
                  onPressedRemove: () {
                    // removeUserFromList(e);
                  },
                  onPressedProfile: () {
                    _showReviewBottomSheet(context, username: e.username);
                  },
                  // shouldHaveRemoveButton: false,
                  // userImage: e.imgPath,
                  userImage: e.profilePictureUrl,
                  userImageThumbnail: e.thumbnailUrl,
                  userName: e.username,
                  userType: '${e.userType}',
                  userNickName: e.displayName,
                  isVerified: e.isVerified,
                  blueTickVerified: e.blueTickVerified,
                  // userNickName: "${e.fullName}",
                );
              },
            );
          }),
          addVerticalSpacing(24),
        ],
      );
    }, error: (error, stackTrace) {
      return const Text('Error fetching search results');
    }, loading: () {
      // return CircPro
      return Container(
        margin: const EdgeInsets.only(top: 120.0),
        child: Center(child: Loader()),
      );
    });
  }

  Widget _headingText({required String mainText, String? trailingButtonText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          mainText,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                // color: VmodelColors.primaryColor,
                fontSize: 13.sp,
              ),
        ),
        if (trailingButtonText != null)
          TextButton(
            onPressed: () {
              ref.read(hiveStoreProvider.notifier).searchesBox.clear();

              clearRecent();
            },
            child: Text(
              trailingButtonText,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    // color: VmodelColors.primaryColor,
                    fontSize: 12.sp,
                  ),
            ),
          ),
      ],
    );
  }

  Future<dynamic> _showReviewBottomSheet(BuildContext context, {required String username}) async {
    VMHapticsFeedback.lightImpact();
    return null;
    // return showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     constraints: BoxConstraints(maxHeight: 50.h),
    //     backgroundColor: Colors.transparent,
    //     builder: (context) {
    //       return ReviewBottomSheet(
    //         edit:false,
    //         reply:false,
    //         bottomInsetPadding: MediaQuery.of(context).viewInsets.bottom,
    //         username: username,
    //         onRatingCompleted: (){
    //           Navigator.of(context)
    //             ..pop();
    //         },
    //       );
    //     });
  }
}
