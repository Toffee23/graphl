import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/dashboard/discover/map/widget/map_search_card.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class MapSearchDetailsView extends StatefulWidget {
  const MapSearchDetailsView({Key? key}) : super(key: key);

  @override
  State<MapSearchDetailsView> createState() => _MapSearchDetailsViewState();
}

class _MapSearchDetailsViewState extends State<MapSearchDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Map Search',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey[200],
        leading: const VWidgetsBackButton(),
        actions: [
          IconButton(
            onPressed: () {
              VMHapticsFeedback.lightImpact();
            },
            icon: const RenderSvg(svgPath: VIcons.setting),
          ),
          IconButton(
            onPressed: () {
              VMHapticsFeedback.lightImpact();
              context.push('/NotificationMain');
              // navigateToRoute(context, const NotificationMain());
            },
            icon: const RenderSvg(svgPath: VIcons.notification),
          ),
          addHorizontalSpacing(5.0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: ListView(
          children: const [
            MapSearchCard(
              initialPage: 0,
            ),
            MapSearchCard(
              initialPage: 1,
            ),
            MapSearchCard(
              initialPage: 2,
            ),
          ],
        ),
      ),
    );
  }
}
