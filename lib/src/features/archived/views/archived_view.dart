import 'package:flutter/services.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/saved/controller/saved_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class ArchivedView extends GetView<SavedController> {
  final refreshController = RefreshController();
  Future<void> reloadData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VmodelColors.background,
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Archived",
      ),
      body: _buildGridView(context),
    );
  }

  _buildGridView(
    BuildContext context,
  ) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: () async {
        VMHapticsFeedback.lightImpact();
        refreshController.refreshCompleted();
        return reloadData();
      },
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 202,
            maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 2,
          ),
          itemCount: assets["models"]!.length,
          itemBuilder: (BuildContext ctx, index) {
            return Image.asset(
              assets["models"]![index],
              fit: BoxFit.cover,
            );
          }),
    );
  }
}
