import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/other_user_profile.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/remote/remote_business_profile.dart';

import '../../../../shared/shimmer/profileShimmerPage.dart';
import '../../../../vmodel.dart';
import '../../profile/controller/profile_controller.dart';

class OtherProfileRouter extends ConsumerWidget {
  const OtherProfileRouter({super.key,this.deep, required this.username});
  final String username;
  final bool? deep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(profileProvider(username));
    return userState.maybeWhen(data: (data) {
      if (data == null) {
        return  ProfileShimmerPage();
      } else if ((data.isBusinessAccount ?? false)) {
        return RemoteBusinessProfileBaseScreen(username: username,deep:deep);
      } else {
        return OtherUserProfile(username: username,deep:deep);
      }
    }, orElse: () {
      return  ProfileShimmerPage();
    });
  }
}
