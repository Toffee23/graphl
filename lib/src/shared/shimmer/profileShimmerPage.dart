import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/shimmer/profile_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

class ProfileShimmerPage extends StatelessWidget {
   ProfileShimmerPage(
      {super.key, this.onTap, this.isPopToBackground = true, this.onRefresh});

  final refreshController = RefreshController();
  final bool isPopToBackground;
  final Function? onTap;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SmartRefresher(
            controller: refreshController,
            onRefresh: () async {
            await onRefresh?.call();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                children: [
                  profileShimmer(context),
                  addVerticalSpacing(20),
                ],
              )),
        ),
      ),
    );
  }
}
