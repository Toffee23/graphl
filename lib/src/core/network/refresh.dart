import 'package:vmodel/src/core/network/websocket.dart';

import '../../features/create_posts/controller/create_post_controller.dart';
import '../../features/dashboard/discover/controllers/discover_controller.dart';
import '../../features/dashboard/discover/controllers/explore_provider.dart';
import '../../features/dashboard/new_profile/controller/gallery_controller.dart';
import '../../features/jobs/job_market/controller/coupons_controller.dart';
import '../../features/jobs/job_market/controller/jobs_controller.dart';
import '../../features/jobs/job_market/controller/recommended_jobs.dart';
import '../../features/jobs/job_market/controller/recommended_services.dart';
import '../../features/jobs/job_market/controller/remote_jobs_controller.dart';
import '../../features/saved/views/delte_ml/controllers/ml_posts_controller.dart';
import '../cache/hive_provider.dart';
import '../controller/app_user_controller.dart';

void refreshPages() {
  reff?.invalidate(appUserProvider);
  reff?.invalidate(recommendedServicesProvider);
  reff?.invalidate(popularServicesProvider);
  reff?.invalidate(recommendedJobsProvider);
  reff?.invalidate(popularJobsProvider);
  reff?.invalidate(remoteJobsProvider);
  reff?.invalidate(mlFeedProvider);

  reff?.invalidate(hottestCouponsProvider);
  reff?.invalidate(hiveStoreProvider);
  reff?.invalidate(discoverProvider);
  reff?.invalidate(exploreProvider);

  reff?.invalidate(isInitialOrRefreshGalleriesLoad);
  reff?.invalidate(galleryFeedDataProvider);
  reff?.invalidate(galleryProvider(null));
}
