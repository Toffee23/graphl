import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/all_users_controller.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../../core/utils/shared.dart';
import '../../../../res/colors.dart';
import '../../../../res/gap.dart';
import '../../../../res/icons.dart';
import '../../../../shared/appbar/appbar.dart';
import '../../../../shared/empty_page/empty_page.dart';
import '../../../live_classes/model/live_class_type.dart';
import '../../../live_classes/widgets/upcoming_class_grid_tile.dart';
import '../../profile/controller/profile_controller.dart';

class UserLivesOfferings extends ConsumerStatefulWidget {
  const UserLivesOfferings({
    super.key,
    required this.username,
    this.showAppBar = true,
  });
  final String? username;
  final bool showAppBar;

  @override
  ConsumerState<UserLivesOfferings> createState() => UserLivesOfferingsState();
}

class UserLivesOfferingsState extends ConsumerState<UserLivesOfferings> {
  bool isCurrentUser = false;
  final refreshController = RefreshController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isCurrentUser = ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VAppUser? user;
    if (isCurrentUser) {
      final appUser = ref.watch(appUserProvider);
      user = appUser.valueOrNull;
    } else {
      final appUser = ref.watch(profileProviderNoFlag(widget.username));
      user = appUser.valueOrNull;
    }
    final requestUsername = ref.watch(userNameForApiRequestProvider('${widget.username}'));
    final userLives = ref.watch(userLivesProvider(widget.username));

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: !widget.showAppBar
          ? null
          : VWidgetsAppBar(
              leadingIcon: const VWidgetsBackButton(),
              appbarTitle: isCurrentUser ? "My Lives" : "User Lives",
            ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          await ref.refresh(allUsersProvider.notifier).getLives(requestUsername!);
          refreshController.refreshCompleted();
        },
        child: userLives.when(data: (items) {
          if (items.isEmpty) {
            return SingleChildScrollView(
              padding: const VWidgetsPagePadding.horizontalSymmetric(18),
              child: Column(
                children: [
                  addVerticalSpacing(20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // Expand to fill available space
                    child: Center(
                      child: Text(
                        'No lives available',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              // fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: GridView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 8,
                // childAspectRatio: 0.7,
                mainAxisExtent: 33.h,
                childAspectRatio: UploadAspectRatio.portrait.ratio,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                var _class = items[index];
                return UpcomingClassTileNew(
                  classes: _class,
                  imageUrl: _class.banners.isEmpty ? '' : _class.banners.first,
                  onTap: () {
                    context.push('/live_class_detail_new', extra: _class as LiveClasses);
                  },
                );
              },
            ),
          );
        }, error: (err, stackTrace) {
          return const EmptyPage(
            svgSize: 30,
            svgPath: VIcons.gridIcon,
            // title: 'No Galleries',
            subtitle: 'An error occured', //Error fetching posts',
          );
        }, loading: () {
          return const Center(child: CircularProgressIndicator.adaptive());
        }),
      ),
    );
  }
}
