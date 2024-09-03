import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/dashboard/content/data/content_mock_data.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';

class ClassAttendeesBottomSheet extends ConsumerStatefulWidget {
  const ClassAttendeesBottomSheet({
    Key? key,
    this.onItemTap,
    // this.bottomInsetPadding = 15,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  // final double bottomInsetPadding;

  @override
  ConsumerState<ClassAttendeesBottomSheet> createState() => _ClassAttendeesBottomSheetState();
}

class _ClassAttendeesBottomSheetState extends ConsumerState<ClassAttendeesBottomSheet> {
  final names = ['Jane', 'Ellie', 'Jessica', 'Mark', 'Miley', 'Mary', 'Sophie', 'Mathew', 'Olivia', 'Elsa'];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.displayMedium;
    final coloWithOpacity = Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: VConstants.bottomPaddingForBottomSheets,
      ),
      constraints: BoxConstraints(
        maxHeight: SizerUtil.height * 0.95,
        minHeight: SizerUtil.height * 0.2,
        minWidth: SizerUtil.width,
      ),
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Column(
        children: [
          addVerticalSpacing(15),
          const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
          addVerticalSpacing(15),
          Expanded(
            child: CustomScrollView(
              // shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  leading: SizedBox.shrink(),
                  // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
                  pinned: true,

                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // addVerticalSpacing(15),
                        // const Align(
                        //     alignment: Alignment.center,
                        //     child: VWidgetsModalPill()),
                        // addVerticalSpacing(25),
                        Text(
                          "Attendees",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          "Tap on a profile picture to mute and unmute them",
                          textAlign: TextAlign.center,
                          style: textTheme?.copyWith(
                            fontSize: 11.sp,
                            color: coloWithOpacity,
                          ),
                        ),
                        addVerticalSpacing(8),
                      ],
                    ),
                  ),
                ),
                // StickySectionHeader(title: 'Speaking'),
                SliverStickyHeader(
                  header: HeaderWidget(textTheme: textTheme, title: 'Speaking'),
                  sliver: SliverGrid.builder(
                    itemCount: liveImages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisExtent: 100,
                    ),
                    itemBuilder: ((context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ProfilePicture(
                            showBorder: true,
                            borderColor: Theme.of(context).primaryColor,
                            borderWidth: 2,
                            imageBorderPadding: EdgeInsets.zero,
                            displayName: 'Janet Conner',
                            url: liveImages[index % 10],
                            headshotThumbnail: liveImages[index % 10],
                            size: 70,
                          ),
                          Text(
                            names[index % 10],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme?.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                SliverStickyHeader(
                  header: HeaderWidget(textTheme: textTheme, title: 'Requested to Speak'),
                  sliver: _buildGrid(1.5),
                ),
                SliverStickyHeader(
                  header: HeaderWidget(textTheme: textTheme, title: 'Others'),
                  sliver: _buildGrid(3),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 3.h,
                    ),
                    child: VWidgetsPrimaryButton(
                      // butttonWidth: 10.w,
                      onPressed: () {
                        if (context.mounted) goBack(context);
                      },
                      enableButton: true,
                      buttonTitle: "Back",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double factor) {
    return SliverGrid.builder(
      // shrinkWrap: true,
      // physics: BouncingScrollPhysics(),
      // padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: (liveImages.length * factor).toInt(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 100,
      ),

      itemBuilder: ((context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfilePicture(
              borderColor: Theme.of(context).primaryColor,

              showBorder: false,
              // borderColor: Colors.white,
              // borderWidth: 0,
              imageBorderPadding: EdgeInsets.zero,
              displayName: 'Janet Conner',
              url: liveImages[index % 10],
              headshotThumbnail: liveImages[index % 10],
              size: 70,
            ),
            Text(
              names[index % 10],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 10.sp,
                  ),
            ),
          ],
        );
      }),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.title,
    required this.textTheme,
  });

  final TextStyle? textTheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      // color: Theme.of(context).scaffoldBackgroundColor,
      color: Theme.of(context).bottomSheetTheme.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: textTheme?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
