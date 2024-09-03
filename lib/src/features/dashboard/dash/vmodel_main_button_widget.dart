import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget_with_icon.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/features/create_posts/views/create_post_with_images.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';

class VWidgetsVModelMainButtonFunctionality extends ConsumerWidget {
  const VWidgetsVModelMainButtonFunctionality({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    List vModelButtonItems = [
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Create a Post",
        svgPath: VIcons.galleryAddIcon,
        onTap: () {
          // popSheet(context);
          popSheet(context);
          // context.push('/createPostWithImagesMediaPicker');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostWithImagesMediaPicker(previousRoute: ModalRoute.of(context)!),
            ),
          );
          /*navigateToRoute(
              AppNavigatorKeys.instance.navigatorKey.currentContext!,
              const CreatePostWithImagesMediaPicker());*/
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Create a Job",
        svgPath: VIcons.alignVerticalIcon,
        onTap: () {
          if (user != null) {
            if (user.profilePictureUrl != null) {
              popSheet(context);
              bool _isEdit = false;
              //ref.read(singleJobProvider.notifier).state = jobDetail;
              context.push('${Routes.createJobFirstPage.split("/:").first}/$_isEdit');
            } else {
              SnackBarService().showSnackBar(message: 'Update your profile photo to create jobs', context: context);
            }
          }

          //context.push('/create_job_view_first');
          //navigateToRoute(context, const CreateJobFirstPage());
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Create a Service",
        svgPath: VIcons.addServiceOutline,
        //  const Icon(Iconsax.shop_add),
        onTap: () {
          if (user != null) {
            if (user.profilePictureUrl != null) {
              popSheet(context);

              context.push('/create_service_route');
            } else {
              SnackBarService().showSnackBar(message: 'Update your profile photo to create services', context: context);
            }
          }

          // navigateToRoute(
          //     context, const AddNewServicesHomepage(servicePackage: null));
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Create a Coupon",
        svgPath: VIcons.couponIcon,
        //  const Icon(Iconsax.shop_add),
        onTap: () {
          if (user != null) {
            if (user.profilePictureUrl != null) {
              popSheet(context);

              context.push('/add_coupons');
            } else {
              SnackBarService().showSnackBar(message: 'Update your profile photo to add coupons', context: context);
            }
          }

          // navigateToRoute(
          //     context,
          //     AddNewCouponHomepage(
          //       context,
          //       servicePackage: null,
          //     ));
        },
      ),
      VWidgetsSettingsSubMenuWithSuffixTileWidget(
        title: "Create a Live",
        keepSvgColor: Theme.of(context).brightness == Brightness.dark ? false : true,
        svgPath: Theme.of(context).brightness == Brightness.dark ? VIcons.liveClassCreateIcon : VIcons.livesNew,
        //  const Icon(Iconsax.shop_add),
        onTap: () {
          if (user != null) {
            if (user.profilePictureUrl != null) {
              popSheet(context);

              context.push('/create_live_class');
            } else {
              SnackBarService().showSnackBar(message: 'Update your profile photo to live classes', context: context);
            }
          }

          //navigateToRoute(context, CreateLiveClass());
        },
      ),
      addVerticalSpacing(25),
    ];
    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
      ),

      //shadowColor: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          addVerticalSpacing(15),
          const Align(alignment: Alignment.center, child: VWidgetsModalPill()),
          addVerticalSpacing(25),
          Flexible(
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              itemCount: vModelButtonItems.length,
              shrinkWrap: true,
              itemBuilder: ((context, index) => vModelButtonItems[index]),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
          // ...vModelButtonItems,
          // addVerticalSpacing(25),
        ],
      ),
    );
  }
}
