import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

class HorizontalListViewViewAll extends ConsumerWidget {
  final String title;
  final List items;
  final bool? eachUserHasProfile;
  final Widget? route;
  final ValueChanged onTap;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int) separatorBuilder;
  final VoidCallback? onViewAllTap;
  final bool isCurrentUser;
  final String username;
  final String? defaultText;
  const HorizontalListViewViewAll({
    Key? key,
    required this.isCurrentUser,
    required this.username,
    required this.title,
    this.defaultText,
    required this.items,
    required this.onTap,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.onViewAllTap,
    this.eachUserHasProfile = false,
    this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        addVerticalSpacing(10),
        GestureDetector(
          onTap: () {
            onViewAllTap?.call();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              Text(
                "View all".toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(),
              ),
            ],
          ),
        ),
        addVerticalSpacing(9),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              (defaultText!=null?defaultText!:"No data for ${title}"),
              style: Theme.of(context).textTheme.displayLarge!.copyWith(),
            ),
          ),
        if (items.isNotEmpty)
          SizedBox(
            height: 33.h,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (BuildContext context, int index) {
                  return separatorBuilder(context, index);
                },
                itemBuilder: (BuildContext context, int index) {
                  return itemBuilder(context, index);
                }),
          ),
        addVerticalSpacing(5),
      ],
    );
  }
}
