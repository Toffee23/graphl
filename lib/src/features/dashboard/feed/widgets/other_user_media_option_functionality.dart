import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import 'package:vmodel/src/features/dashboard/profile/controller/profile_controller.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';

import 'delete_featured.dart';
import 'package:vmodel/src/res/icons.dart';

import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class VWidgetsOtherUserPostMediaOptionsFunctionality
    extends ConsumerStatefulWidget {
  final String username;
  final int postId;
  final int albumId;
  final postData;
  final removedFetured;
  final isTagged;
  final bool currentSavedValue;
  final ValueChanged<bool> onSavedResult;

  const VWidgetsOtherUserPostMediaOptionsFunctionality({
    super.key,
    required this.postData,
    required this.username,
    required this.postId,
    required this.albumId,
    required this.currentSavedValue,
    required this.onSavedResult,
    this.removedFetured,
    this.isTagged,
  });

  @override
  ConsumerState<VWidgetsOtherUserPostMediaOptionsFunctionality> createState() =>
      _VWidgetsOtherUserPostMediaOptionsFunctionalityState();
}

class _VWidgetsOtherUserPostMediaOptionsFunctionalityState
    extends ConsumerState<VWidgetsOtherUserPostMediaOptionsFunctionality> {
  String _boardText = "Add to Boards";
  final isFollowing = ValueNotifier(true);

  String mapToQueryString(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return '';
    final buffer = StringBuffer('?');
    queryParams.forEach((key, value) {
      buffer.write(Uri.encodeQueryComponent(key));
      buffer.write('=');
      buffer.write(Uri.encodeQueryComponent(value));
      buffer.write('&');
    });

    return buffer.toString().substring(0, buffer.length - 1);
  }

  Future<Uri> createDynamicLink(Map<String, String> queryParams) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    var convertedString = mapToQueryString(queryParams);

    final String link = 'https://vmodelapp.com$convertedString';
    return Uri.parse(link);
  }

  void initDynamicLink() async {
    try {
      String dynamicLink = (await createDynamicLink(
              {'a': 'true', 'p': 'post', 'i': widget.postId.toString()}))
          .toString();
      copyToClipboard(dynamicLink);
      Navigator.pop(context);
      SnackBarService().showSnackBar(
          icon: VIcons.copyIcon, message: "Link copied", context: context);
    } catch (e) {
      //print(e);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(profileProvider(widget.username));
    final user = userState.valueOrNull;
    List postMediaOptionsItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Send",
          onTap: () {
            popSheet(context);
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints(maxHeight: 50.h),
              isDismissible: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * .85,
                    // minHeight: MediaQuery.of(context).size.height * .10,
                  ),
                  child: SendWidget(
                    item: widget.postData,
                  )),
            );
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Copy Link",
          onTap: () {
            initDynamicLink.call();
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Share",
          onTap: () async {
            popSheet(context);
            String url = (await createDeepLink({
              'a': 'true',
              'p': 'post',
              'i': widget.postData!.id.toString()
            }))
                .toString();
            showModalBottomSheet(
              isScrollControlled: true,
              isDismissible: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => ShareWidget(
                shareLabel: 'Share Post',
                shareTitle: '${widget.postData?.postedBy.username}\'s Post',
                shareImage: widget.postData?.hasVideo ?? false
                    ? widget.postData?.photos.first.thumbnail
                    : widget.postData?.photos.first.url,
                shareURL: url,
                isWebPicture: true,
              ),
            );
          }),
      if (widget.isTagged != null && widget.isTagged)
        VWidgetsSettingsSubMenuTileWidget(
            title: "Remove me from this post",
            onTap: () {
              popSheet(context);
              showModalBottomSheet(
                isScrollControlled: true,
                isDismissible: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => Container(
                  // height: 400,
                  constraints: BoxConstraints(
                    minHeight: 30,
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    // color: VmodelColors.appBarBackgroundColor,
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: DeleteFeatured(
                    postId: widget.postId,
                    albumId: widget.albumId,
                    onRemoveFeatured: widget.removedFetured,
                  ),
                ),
              );
            }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Report Account",
          onTap: () {
            popSheet(context);
            reportUserFinalModal(context, user?.profilePictureUrl);
          }),
    ];
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        addVerticalSpacing(15),
        const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
        addVerticalSpacing(25),
        Flexible(
          child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) => postMediaOptionsItems[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: postMediaOptionsItems.length),
        )
      ],
    );
  }

  Future<void> reportUserFinalModal(
    BuildContext context,
    String? url,
  ) {
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                // color: VmodelColors.appBarBackgroundColor,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: VWidgetsReportAccount(username: widget.username));
        });
  }
}
