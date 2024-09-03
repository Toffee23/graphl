import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class MarketPlaceFeedV2 extends ConsumerStatefulWidget {
  const MarketPlaceFeedV2({super.key, required this.tabController});
  final TabController tabController;

  @override
  ConsumerState<MarketPlaceFeedV2> createState() => _MarketPlaceFeedV2State();
}

class _MarketPlaceFeedV2State extends ConsumerState<MarketPlaceFeedV2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
            Row(
              children: [
                Text('Don’t know which one to choose? ',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16)),
                InkWell(
                  onTap: () => VBottomSheetComponent.customBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Marketplace options',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                            IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(Icons.close)),
                          ],
                        ),
                        MarketplaceSheetTile(
                          title: 'Services',
                          subtitle:
                              'View all your services, book for a service\nand do so much more with marketplace',
                          icon: VIcons.marketplaceService,
                          onTap: () => widget.tabController.animateTo(1),
                        ),
                        MarketplaceSheetTile(
                          title: 'Jobs',
                          subtitle:
                              'View all your jobs, apply for a jobs and do\nso much more with marketplace',
                          icon: VIcons.marketplaceJob,
                          onTap: () => widget.tabController.animateTo(2),
                        ),
                        MarketplaceSheetTile(
                          title: 'Coupons',
                          subtitle:
                              'View all your coupons, create a coupon and\ndo so much more with marketplace',
                          icon: VIcons.marketplaceCoupon,
                          onTap: () => widget.tabController.animateTo(3),
                        ),
                        MarketplaceSheetTile(
                          title: 'Requests',
                          subtitle:
                              'View all your requests, apply for a request\nand do so much more with marketplace',
                          icon: VIcons.marketplaceRequest,
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Tap here',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      MarketplaceCard(
                        name: 'Services',
                        color: VmodelColors.serviceColor,
                        foregroundColor: VmodelColors.serviceLightColor,
                        icon: VIcons.marketplaceService,
                        onTap: () => widget.tabController.animateTo(1),
                        isMini: false,
                      ),
                      const SizedBox(height: 20),
                      MarketplaceCard(
                        name: 'Coupons',
                        color: VmodelColors.couponColor,
                        foregroundColor: VmodelColors.couponLightColor,
                        icon: VIcons.marketplaceCoupon,
                        onTap: () => widget.tabController.animateTo(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      MarketplaceCard(
                        name: 'Jobs',
                        color: VmodelColors.jobColor,
                        foregroundColor: VmodelColors.jobLightColor,
                        icon: VIcons.marketplaceJob,
                        onTap: () => widget.tabController.animateTo(2),
                      ),
                      const SizedBox(height: 20),
                      MarketplaceCard(
                          name: 'Requests',
                          color: VmodelColors.requestColor,
                          foregroundColor: VmodelColors.requestLightColor,
                          icon: VIcons.marketplaceRequest,
                          onTap: () {
                            ref
                                .read(dashTabProvider.notifier)
                                .changeIndexState(3);
                            context.push(
                              '/myRequestPage',
                            );
                          },
                          isMini: false),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            Column(
              children: [
                MarketplaceSection(
                  title: 'Services',
                  subtitle: 'Book a service',
                  description:
                      'View all your services, book for a \nservice and do so much more with \nmarketplace',
                  icon: VIcons.marketplaceService,
                  color: context.isDarkMode
                      ? VmodelColors.serviceColor
                      : VmodelColors.serviceLightColor,
                  foregroundColor: context.isDarkMode
                      ? VmodelColors.serviceLightColor
                      : VmodelColors.serviceColor,
                  onTap: () => widget.tabController.animateTo(1),
                ),
                MarketplaceSection(
                  title: 'Jobs',
                  subtitle: 'Apply for a job',
                  description:
                      'View all your jobs, apply for a \njob and do so much more with \nmarketplace',
                  icon: VIcons.marketplaceJob,
                  color: context.isDarkMode
                      ? VmodelColors.jobColor
                      : VmodelColors.jobLightColor,
                  foregroundColor: context.isDarkMode
                      ? VmodelColors.jobLightColor
                      : VmodelColors.jobColor,
                  onTap: () => widget.tabController.animateTo(2),
                ),
                MarketplaceSection(
                  title: 'Request',
                  subtitle: 'Make a request',
                  description:
                      'View all your requests, apply for a \nrequest and do so much more with \nmarketplace',
                  icon: VIcons.marketplaceRequest,
                  color: context.isDarkMode
                      ? VmodelColors.requestColor
                      : VmodelColors.requestLightColor,
                  foregroundColor: context.isDarkMode
                      ? VmodelColors.requestLightColor
                      : VmodelColors.requestColor,
                  onTap: () {
                    context.push(
                      '/createRequestPage',
                    );
                  },
                ),
                MarketplaceSection(
                  title: 'Coupon',
                  subtitle: 'Create a coupon',
                  description:
                      'View all your coupons, create a \ncoupon and do so much more \nwith marketplace',
                  icon: VIcons.marketplaceCoupon,
                  color: context.isDarkMode
                      ? VmodelColors.couponColor
                      : VmodelColors.couponLightColor,
                  foregroundColor: context.isDarkMode
                      ? VmodelColors.couponLightColor
                      : VmodelColors.couponColor,
                  onTap: () => widget.tabController.animateTo(3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarketplaceCard extends StatelessWidget {
  const MarketplaceCard({
    super.key,
    required this.name,
    required this.color,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
    this.isMini = true,
  });
  final String name;
  final Color color;
  final Color foregroundColor;
  final bool isMini;
  final String icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        onTap();
      },

      child: Container(
        child: Stack(
          children: [Container(
            height: isMini ? 165 : 195,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
             color: color,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: foregroundColor,
                  child: RenderSvg(svgPath: icon, color: VmodelColors.white),
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Color.fromARGB(37, 255, 255, 255)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontSize: 18, color: VmodelColors.white)),
                        SizedBox(width: 10),
                        Icon(Icons.chevron_right_rounded,
                            color: VmodelColors.white),
                      ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class MarketplaceSection extends StatelessWidget {
  const MarketplaceSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final Color color;
  final Color foregroundColor;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(fontSize: 16)),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            VMHapticsFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.only(top: 22, bottom: 38, left: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: context.isDarkMode ? color : color.withOpacity(.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: foregroundColor,
                  child: RenderSvg(svgPath: icon, color: VmodelColors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(description,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: foregroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text('Get Started',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 26),
      ],
    );
  }
}

class MarketplaceSheetTile extends StatelessWidget {
  const MarketplaceSheetTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap,
      this.isLast = false});
  final String title;
  final String subtitle;
  final String icon;
  final Function() onTap;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        VMHapticsFeedback.lightImpact();
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RenderSvg(
                svgPath: icon,
                color: context.isDarkMode
                    ? VmodelColors.white
                    : VmodelColors.primaryColor.withOpacity(.4)),
            addHorizontalSpacing(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  addVerticalSpacing(16),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 16),
                  ),
                  addVerticalSpacing(16),
                  if (!isLast)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: .4,
                            width: 80,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
