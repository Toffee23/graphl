import 'package:either_option/either_option.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/features/connection/controller/provider/connection_provider.dart';
import 'package:vmodel/src/features/settings/widgets/my_network_card.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';
import '../../../../shared/shimmer/widgets/circle_avatar_two_line_tile.dart';

final activateSearchProvider = StateProvider((ref) => false);

class NetworkPageSearch extends ConsumerStatefulWidget {
  const NetworkPageSearch({super.key});

  @override
  ConsumerState<NetworkPageSearch> createState() => _NetworkPageSearchState();
}

class _NetworkPageSearchState extends ConsumerState<NetworkPageSearch> {
  TextEditingController searchController = TextEditingController();
  final refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(searchConnections);
    // final searchText = ref.watch(myConnectionsSearchProvider);

    return connections.when(
        data: (Either<CustomException, List<dynamic>> data) {
      return data.fold(
        (left) => Text(left.message),
        (right) {
          return Expanded(
            child: SmartRefresher(
              controller: refreshController,
              onRefresh: () async {
                VMHapticsFeedback.lightImpact();
                ref.refresh(searchConnections.future);
                refreshController.refreshCompleted();
              },
              child: ListView.builder(
                itemCount: right.length,
                itemBuilder: (BuildContext context, int index) {
                  var connection = right[index];
                  //print('[ffg] $connection');
                  return Padding(
                      padding:
                          const VWidgetsPagePadding.horizontalSymmetric(18),
                      child: VWidgetsNetworkPageCard(
                        onPressedRemove: () {},
                        onPressedProfile: () {
                          /*navigateToRoute(
                              context,
                              OtherProfileRouter(
                                username: connection['username'],
                              ));*/

                          String? _userName = connection['username'];
                          context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
                          // navigateToRoute(
                          //     context,
                          //     const ProfileMainView(
                          //         profileTypeEnumConstructor:
                          //             ProfileTypeEnum.personal));
                        },
                        userImage: connection['profilePictureUrl'],
                        userImageThumbnail: connection['thumbnailUrl'],
                        userImageStatus: connection['profilePictureUrl'] == null
                            ? false
                            : true,
                        subTitle:
                            '${connection['label'] ?? VMString.noSubTalentErrorText}',
                        displayName: '${connection['displayName']}',
                        title:
                            // '${connection['firstName']} ${connection['lastName']}',
                            '${connection['username']}',
                        isVerified: connection['isVerified'],
                        blueTickVerified: connection['blueTickVerified'],
                      ));
                },
              ),
            ),
          );
        },
      );
    }, loading: () {
      // return const ConnectionShimmerPage();
      return Expanded(
        child: ListView.separated(
            itemCount: 4,
            padding: EdgeInsets.symmetric(horizontal: 18),
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return addVerticalSpacing(16);
            },
            itemBuilder: (context, index) {
              return CircleAvatarTwoLineTileShimmer();
            }),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return Text(stackTrace.toString());
    });
  }
}
