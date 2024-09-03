import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vmodel/src/features/settings/views/favorite_hashtags.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class ActivitiesMenu extends ConsumerStatefulWidget {
  const ActivitiesMenu({super.key});
  static const routeName = 'activities_menu';

  @override
  ConsumerState<ActivitiesMenu> createState() => _ActivitiesMenuConsumerState();
}

class _ActivitiesMenuConsumerState extends ConsumerState<ActivitiesMenu> {
  Widget _customMenuTile(BuildContext context, String title, Function() method,
      [Color? color]) {
    return InkWell(
      onTap: method,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
        ),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600, color: color, fontSize: 14),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
                addHorizontalSpacing(10),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final block = [
      _customMenuTile(context, 'Posts Interactions', () {
        context.push('/activities_page');
      }),
      _customMenuTile(context, 'Recently Deleted', () {
        context.push('/deleted_posts');
      }),
      _customMenuTile(context, 'Recently Viewed Profiles', () {
        // context.push('/');
      }),
      _customMenuTile(context, 'Marketplace interaction', () {
        // context.push('/search_history');
      }),
      _customMenuTile(context, 'Search History', () {
        context.push('/search_history');
      }),
      _customMenuTile(context, FavoriteHashtags.title, () {
        context.push(FavoriteHashtags.route);
      }),
      Container(),
    ];
    List menuItems = [
      // Card(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      //   color: !context.isDarkMode ? VmodelColors.lightBgColor : null,
      //   child:
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) => block[index]),
            separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).dividerColor,
                ),
            itemCount: block.length),
      ),
      // ),
      addVerticalSpacing(10),
    ];

    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "My Activities",
      ),
      body: Column(
        children: [
          addVerticalSpacing(25),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              // padding: const EdgeInsets.only(
              //   left: 18,
              //   right: 18,
              //   bottom: VConstants.bottomPaddingForBottomSheets,
              // ),
              // physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => menuItems[index],
              itemCount: menuItems.length,
            ),
          ),
        ],
      ),
    );
  }
}
