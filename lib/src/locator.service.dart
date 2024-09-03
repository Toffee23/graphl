import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/jobs/job_market/controller/job_controller.dart';
import 'package:vmodel/src/res/app_go_router.dart';

GetIt locator = GetIt.instance;
Future setUpLocator() async {
  locator.registerSingleton<GoRouter>(router);
  locator.registerLazySingleton<JobDetailNotifier>(() => JobDetailNotifier());
}
