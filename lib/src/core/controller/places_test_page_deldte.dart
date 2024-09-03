import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../shared/text_fields/places_autocomplete_field.dart';
import 'gmap_places_controller.dart';

class PlacesListview extends ConsumerStatefulWidget {
  const PlacesListview({super.key});

  @override
  ConsumerState<PlacesListview> createState() => _PlacesListviewState();
}

class _PlacesListviewState extends ConsumerState<PlacesListview> {
  final controller = TextEditingController();
  final refreshController = RefreshController();
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Places",
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          VMHapticsFeedback.lightImpact();
          ref.invalidate(suggestedPlacesProvider);
          refreshController.refreshCompleted();
        },
        child: Portal(
          // labels: [PortalLabel("wow")],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PlacesAutocompletionField(
                  // initialValue: _selectedLocation,
                  isFollowerTop: false,
                  label: "Location",
                  hintText: "Search location",
                  onItemSelected: (value) {
                    if (!mounted) return;
                    // _selectedLocation = value['description'];
                  },
                  postOnChanged: (String value) {
                    if (!mounted) return;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
