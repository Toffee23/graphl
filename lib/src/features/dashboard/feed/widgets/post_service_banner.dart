import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../res/res.dart';
import '../../../settings/views/booking_settings/models/service_package_model.dart';

class PostServiceBookNowBanner extends ConsumerWidget {
  const PostServiceBookNowBanner({super.key, required this.service});

  final ServicePackageModel service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      width: 100.w,
      // margin: EdgeInsets.symmetric(horizontal: 8),
      // padding: EdgeInsets.symmetric(horizontal: 8),
      // decoration: BoxDecoration(
      //   color: context.theme.colorScheme.primary,
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: Card(
        elevation: 4,
        color: context.theme.colorScheme.primary,
        margin: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${service.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                  ),
                ),
              ),
              addHorizontalSpacing(16),
              InkWell(
                onTap: () {
                  //print('brrrrrrrrrrrrrrrrrrrr');
                  ref.read(serviceProvider.notifier).state = service;
                  String? username = service.user?.username;
                  bool isCurrentUser = false;
                  String? serviceId = service.id;
                  context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                  /*navigateToRoute(
                      context,
                      ServicePackageDetail(
                        service: service,
                        isCurrentUser: false,
                        username: service.user!.username,
                      ));*/
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        '${VMString.bullet} Book now',
                        style: TextStyle(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme
                              ?.onPrimary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme
                            ?.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
