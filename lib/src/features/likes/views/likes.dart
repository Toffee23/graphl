import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/debounce.dart';
import 'package:vmodel/src/features/likes/widgets/like_widget.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/vmodel.dart';

class Likes extends ConsumerStatefulWidget {
  final List usersThatLiked;
  final String username;
  const Likes(
      {required this.usersThatLiked, required this.username, super.key});

  @override
  ConsumerState<Likes> createState() => _LikesState();
}

class _LikesState extends ConsumerState<Likes> {
  TextEditingController searchController = TextEditingController();
  late final Debounce _debounce;
  final refreshController = RefreshController();

  @override
  initState() {
    super.initState();
    _debounce = Debounce(delay: Duration(milliseconds: 300));
  }

  @override
  dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);
    bool isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    // final likes = ref.watch(getConnections);
    return Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: const VWidgetsBackButton(),
          appbarTitle: "Likes",
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.usersThatLiked.isEmpty
                ?
                // isCurrentUser?
                Center(
                    child: Container(
                      height: 200,
                      width: 300,
                      child: EmptyPage(
                          svgPath: VIcons.feedLikeIcon,
                          svgSize: 30,
                          shouldCenter: true,
                          subtitle: 'No likes yet, check again later'),
                    ),
                  )
                // :
                //       Center(
                //       child: Container(
                //       height: 200,
                //       width: 300,
                //       child: EmptyPage(
                //         svgPath: VIcons.feedLikeIcon,
                //         svgSize: 30,
                //         shouldCenter: true,
                //         subtitle: 'Only @${widget.username} can see likes')
                //       )
                //       )
                : Expanded(
                    child: SmartRefresher(
                      controller: refreshController,
                      onRefresh: () async {
                        VMHapticsFeedback.lightImpact();
                        refreshController.refreshCompleted();
                      },
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        itemCount: widget.usersThatLiked.length,
                        itemBuilder: (BuildContext context, int index) {
                          var likes = widget.usersThatLiked[index];
                          return Padding(
                              padding:
                                  const VWidgetsPagePadding.horizontalSymmetric(
                                      18),
                              child: VWidgetsLikeCard(
                                onPressedProfile: () {
                                  /*navigateToRoute(
                                        context,
                                        OtherProfileRouter(
                                          username: connection['username'],
                                        ));*/

                                  String? _userName = likes['username'];
                                  context.push(
                                      '${Routes.otherProfileRouter.split("/:").first}/$_userName');

                                  // navigateToRoute(
                                  //     context,
                                  //     const ProfileMainView(
                                  //         profileTypeEnumConstructor:
                                  //             ProfileTypeEnum.personal));
                                },
                                userImage: likes['profilePictureUrl'] ??
                                    "assets/images/models/listTile_3.png",
                                userImageThumbnail: likes['thumbnailUrl'] ??
                                    "assets/images/models/listTile_3.png",
                                userImageStatus:
                                    likes['profilePictureUrl'] == null
                                        ? false
                                        : true,
                                displayName: '${likes['displayName']}',
                                title:
                                    // '${connection['firstName']} ${connection['lastName']}',
                                    '${likes['username']}',
                                subTitle:
                                    '${likes['label'] ?? VMString.noSubTalentErrorText}',
                                isVerified: likes['isVerified'],
                                blueTickVerified: likes['blueTickVerified'],
                              ));
                        },
                      ),
                    ),
                  ),
          ],
        ));
  }
}
