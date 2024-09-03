import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/checkConnection.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/send.dart';
import 'package:vmodel/src/features/dashboard/feed/widgets/share.dart';
import 'package:vmodel/src/features/saved/controller/provider/saved_provider.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../../../../res/icons.dart';

//ConsumerWidget
class VWidgetsPostMediaOptionsFunctionality extends ConsumerStatefulWidget {
  const VWidgetsPostMediaOptionsFunctionality({
    super.key,
    required this.postId,
    required this.postData,
    required this.postItemsLength,
    this.onDeletePost,
    this.onEditPost,
  });

  final postData;
  final int postId;
  final int postItemsLength;
  final VoidCallback? onDeletePost;
  final VoidCallback? onEditPost;

  @override
  ConsumerState<VWidgetsPostMediaOptionsFunctionality> createState() => _VWidgetsPostMediaOptionsFunctionalityState();
}

class _VWidgetsPostMediaOptionsFunctionalityState extends ConsumerState<VWidgetsPostMediaOptionsFunctionality> {
  String _boardText = "Add to Boards";

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

  Future createDynamicLink(Map<String, String> queryParams) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    var convertedString = mapToQueryString(queryParams);

    final String link = 'https://vmodelapp.com$convertedString';
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: 'https://vmodel.page.link',
    //   longDynamicLink: Uri.parse(
    //     'https://vmodel.page.link?imv=0&amv=0&link=https%3A%2F%2Fvmodelapp.com',
    //   ),
    //   link: Uri.parse(DynamicLink),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'app.vmodel.social',
    //     minimumVersion: 0,
    //   ),
    //   iosParameters: const IOSParameters(
    //     bundleId: 'app.vmodel.social',
    //     minimumVersion: '0',
    //   ),
    // );

    // Uri url;
    // if (false) {
    //   final ShortDynamicLink shortLink =
    //       await dynamicLinks.buildShortLink(parameters);
    //   url = shortLink.shortUrl;
    // } else {
    //   url = await dynamicLinks.buildLink(parameters);
    // }
    return Uri.parse(link);
  }

  void initDynamicLink() async {
    try {
      String dynamicLink = (await createDynamicLink({'a': 'true', 'p': 'post', 'i': widget.postId.toString()})).toString();
      copyToClipboard(dynamicLink);

      Navigator.pop(context);
      SnackBarService().showSnackBar(icon: VIcons.copyIcon, message: "Link copied", context: context);
    } catch (e) {
      //print(e);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List postMediaOptionsItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Edit",
          onTap: () {
            widget.onEditPost?.call();
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Send",
          onTap: () {
            popSheet(context);
            showModalBottomSheet(
              isScrollControlled: true,
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
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: _boardText,
      //     onTap: () {
      //       if (_boardText.toLowerCase() == "Add to Boards".toLowerCase()) {
      //         _boardText = "Remove from Board";
      //       } else {
      //         _boardText = "Add to Boards";
      //       }
      //       setState(() {});
      //     }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Hide from profile",
          onTap: () async {
            final connected = await checkConnection();
            if (connected) {
              VMHapticsFeedback.lightImpact();
              await ref.watch(hidePostProvider([widget.postId, context]));
              ref.invalidate(mainFeedProvider);
            } else {
              if (context.mounted) {
                // responseDialog(context, "No connection", body: "Try again");
                SnackBarService().showSnackBarError(context: context);
              }
            }
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Copy Link",
          onTap: () {
            //print('linked copied');
            initDynamicLink.call();
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Share",
          onTap: () async {
            popSheet(context);
            String url = (await createDeepLink({'a': 'true', 'p': 'post', 'i': widget.postData!.id.toString()})).toString();
            showModalBottomSheet(
              isScrollControlled: true,
              isDismissible: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => ShareWidget(
                shareLabel: 'Share Post',
                shareTitle: '${widget.postData?.postedBy.username}\'s Post',
                shareImage: widget.postData?.hasVideo ?? false ? widget.postData?.photos.first.thumbnail : widget.postData?.photos.first.url,
                shareURL: url,
                isWebPicture: true,
              ),
            );
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Delete",
          onTap: () {
            popSheet(context);
            deletePost(context);
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
        // Flexible(
        //   child: SingleChildScrollView(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: List.generate((postMediaOptionsItems.length * 2) - 1,
        //           (index) {
        //         if (index % 2 == 0) return postMediaOptionsItems[index ~/ 2];
        //         return const Divider();
        //       }),
        //     ),
        //   ),
        // ),
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

  Future<void> deletePost(BuildContext context) {
    return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
                child: // VWidgetsReportAccount(username: widget.username));
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    addVerticalSpacing(15),
                    const VWidgetsModalPill(),
                    addVerticalSpacing(25),
                    Center(
                      child: Text(
                          widget.postItemsLength > 1
                              ? 'Are you sure you want to delete this post? This action cannot be undone. '
                              : 'Are you sure you want to delete this picture? This action cannot be undone. ',
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                color: Theme.of(context).primaryColor,
                              )),
                    ),
                    addVerticalSpacing(30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onDeletePost != null) {
                            widget.onDeletePost!();
                          }
                          // VLoader.changeLoadingState(true);
                          // final isSuccess = await ref
                          //     .read(galleryProvider(null).notifier)
                          //     .deletePost(postId: postId);
                          // VLoader.changeLoadingState(false);
                          // if (isSuccess && context.mounted) {
                          //   goBack(context);
                          // }
                        },
                        child: Text("Delete",
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
                      child: GestureDetector(
                        onTap: () {
                          goBack(context);
                        },
                        child: Text('Cancel',
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
            // child:
          );
        });
  }
}
