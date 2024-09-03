
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/extensions/theme_extension.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsMessageCard extends ConsumerStatefulWidget {
  final String? titleText;
  final String? profileImage;
  final String? latestMessage;
  final String? latestMessageTime;
  final VoidCallback? onPressedLike;
  final VoidCallback? onTapCard;
  final bool isRead;
  final bool isCurrentUserLastMsg;
  final int unreadMessageCount;
  final String? profileRing;

  const VWidgetsMessageCard({
    required this.titleText,
    required this.profileImage,
    this.latestMessage,
    this.latestMessageTime,
    this.onPressedLike,
    required this.onTapCard,
    required this.isRead,
    required this.isCurrentUserLastMsg,
    required this.unreadMessageCount,
    required this.profileRing,
    super.key,
  });

  @override
  ConsumerState<VWidgetsMessageCard> createState() => _VWidgetsMessageCard();
}

class _VWidgetsMessageCard extends ConsumerState<VWidgetsMessageCard> {
  var messageType = '';
  var service = '';
  var item;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: ProfilePicture(
              showBorder: false,
              url: widget.profileImage,
              headshotThumbnail: widget.profileImage,
              size: 50,
              profileRing: widget.profileRing,
            ),
          ),
          addHorizontalSpacing(10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titleText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            // color: VmodelColors.primaryColor,
                            fontWeight: !widget.isRead ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                    ),
                    Expanded(child: addHorizontalSpacing(10)),
                    Text(
                      widget.latestMessageTime!,
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                            fontSize: 10.sp,
                            fontWeight: !widget.isRead ? FontWeight.bold : null,
                            overflow: TextOverflow.clip,
                          ),
                    ),
                  ],
                ),
                addVerticalSpacing(4),
                //second row
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          if (widget.latestMessage!.contains('######service'))
                            WidgetSpan(
                                child: Icon(
                              Icons.home_repair_service,
                              size: 15.sp,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            )),
                          if (widget.latestMessage!.contains('######post'))
                            WidgetSpan(
                                child: Icon(
                              Icons.photo,
                              size: 15.sp,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                            )),
                          TextSpan(
                            text:
                                '${widget.latestMessage!.contains('######service') ? ' ${widget.isCurrentUserLastMsg ? 'You' : widget.titleText} sent a service' : widget.latestMessage!.contains('######post') ? ' ${widget.isCurrentUserLastMsg ? 'You' : widget.titleText} sent a post' : (widget.latestMessage!.contains('######Payment ')) ? widget.latestMessage?.replaceFirst('######Payment ', '') : widget.latestMessage}',
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  color: !widget.isRead ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
                                  fontSize: 10.sp,
                                  fontWeight: !widget.isRead ? FontWeight.w600 : null,
                                  overflow: TextOverflow.clip,
                                ),
                          )
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    addHorizontalSpacing(10),
                    if (widget.unreadMessageCount != 0)
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: context.appTheme.buttonTheme.colorScheme?.primary,
                        child: Text(
                          widget.unreadMessageCount.toString(),
                          style: context.appTextTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                    // Text(
                    //   latestMessageTime!,
                    //   style:
                    //       Theme.of(context).textTheme.displayMedium!.copyWith(
                    //             color: Theme.of(context)
                    //                 .primaryColor
                    //                 .withOpacity(0.5),
                    //             fontSize: 10.sp,
                    //             overflow: TextOverflow.clip,
                    //           ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
