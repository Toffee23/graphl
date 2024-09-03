import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/widgets/block_user_widget.dart';
import 'package:vmodel/src/features/messages/controller/messages_controller.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';

import '../../../res/gap.dart';
import '../../dashboard/new_profile/controller/block_user_controller.dart';
import '../../dashboard/new_profile/other_user_profile/widgets/report_account_popUp_widget.dart';
import '../../dashboard/profile/controller/profile_controller.dart';

class MessageMenuOptionsWidget extends ConsumerStatefulWidget {
  final String username;
  final int? conversationId;
  final String connectionStatus;
  final Function(bool _) hasArchived;
  const MessageMenuOptionsWidget({
    super.key,
    required this.username,
    this.conversationId,
    required this.connectionStatus,
    required this.hasArchived,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageMenuOptionsWidgetState();
}

class _MessageMenuOptionsWidgetState
    extends ConsumerState<MessageMenuOptionsWidget> {
  bool userBlock = false;
  bool? isUserArchived;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(profileProviderNoFlag(widget.username));
    final user = userState.valueOrNull;
    bool isBlocked = ref.watch(isUserBlockedProvider(widget.username));
    if (isUserArchived == null) {
      ref.watch(isUserArchivedProvider(widget.username)).then((value) {
        isUserArchived = value;
        setState(() {});
      });
    }
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            addVerticalSpacing(10),
            const Align(
                alignment: Alignment.center, child: VWidgetsModalPill()),
            addVerticalSpacing(20),
            if (isUserArchived != null)
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: isUserArchived == true
                    ? GestureDetector(
                        onTap: () {
                          widget.hasArchived(false);
                        },
                        child: Text('Unarchive',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  // color: Theme.of(context).primaryColor,
                                )),
                      )
                    : isUserArchived == false
                        ? GestureDetector(
                            onTap: () {
                              widget.hasArchived(true);
                            },
                            child: Text('Archive',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      // color: Theme.of(context).primaryColor,
                                    )),
                          )
                        : GestureDetector(
                            onTap: () async {},
                            child: Shimmer.fromColors(
                              baseColor: const Color(0xffD9D9D9),
                              highlightColor: const Color(0xffF0F1F5),
                              child: Container(
                                width: 200,
                                height: 20,
                              ),
                            ),
                          ),
              ),
            const Divider(thickness: 1),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: isBlocked
                  ? GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        userBlock = await ref
                            .read(blockUserProvider.notifier)
                            .unBlockUser(userName: widget.username);
                        setState(() {});
                      },
                      child: Text('Un-Block',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromRGBO(224, 44, 35, 1))),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        blockUserFinalModal(context);
                      },
                      child: Text('Block',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                // color: VmodelColors.primaryColor,
                              ))),
            ),
            const Divider(thickness: 1),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  reportUserFinalModal(context, user?.profilePictureUrl);
                },
                child: Text('Report account',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          // color: Theme.of(context).primaryColor,
                        )),
              ),
            ),
            addVerticalSpacing(10),
          ],
        ),
      ),
    );
  }

  Future<void> blockUserFinalModal(BuildContext context) {
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
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
              child: VWidgetsBlockUser(
                username: widget.username,
                connectionStatus: widget.connectionStatus,
                previousPage: "message",
              ));
        });
  }

  Future<void> reportUserFinalModal(
    BuildContext context,
    String? url,
  ) {
    return showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        constraints: BoxConstraints(maxHeight: 50.h),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
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
              child: VWidgetsReportAccount(
                username: widget.username,
                previousPage: "message",
                connectionStatus: widget.connectionStatus,
              ));
        });
  }
}
