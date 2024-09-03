import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/utils/enum/album_type.dart';
import '../controller/print_gallery_controller.dart';

class PrintHomepage extends ConsumerWidget {
  const PrintHomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(printGalleryTypeFilterProvider(null));
    ref.watch(printGalleryListProvider(null));
    List printItems = [
      VWidgetsSettingsSubMenuTileWidget(
          title: "Portfolio",
          onTap: () {
            ref.read(printGalleryTypeFilterProvider(null).notifier).state =
                AlbumType.portfolio;
            context.push('/print_profile/${null}');
            // navigateToRoute(
            //     context,
            //     const PrintProfile(
            //       username: null,
            //     ));
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Polaroid",
          onTap: () {
            ref.read(printGalleryTypeFilterProvider(null).notifier).state =
                AlbumType.polaroid;
            context.push('/print_profile/${null}');
            // navigateToRoute(
            //     context,
            //     const PrintProfile(
            //       username: null,
            //     ));
          }),
      VWidgetsSettingsSubMenuTileWidget(
          title: "Print Settings",
          onTap: () {
            context.push('/printings');
            //navigateToRoute(context, const PrintingSettingsPage());
          }),
    ];

    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Print",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Container(
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
          ),
          child: ListView.separated(
              itemBuilder: ((context, index) => printItems[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: printItems.length),
        ),
      ),
    );
  }
}
