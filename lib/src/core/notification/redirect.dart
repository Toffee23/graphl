import 'package:go_router/go_router.dart';

import '../../../main.dart';
import '../../features/dashboard/feed/controller/new_feed_provider.dart';
import '../../vmodel.dart';

void redirectNotificationScreen(ref, BuildContext context, bool home) async {
  // try {
  vRef.ref = ref;
  final Map<String, dynamic>? payload = navigationPayload.payload;
  if (payload != null) {
    navigationPayload.payload = null;
    switch (payload['page']) {
      case "USER":
        context.go('/other-profile-router/${payload['object_id']}', extra: true);
      case "CONVERSATION":
        context.go('/messagesChatScreen/${payload['object_id']}/${payload['title']}/profilePicture/profileThumbnailUrl/label/${[]}', extra: true);
      case "POST":
        {
          var post = await (ref.read(mainFeedProvider.notifier).getSinglePost(postId: int.parse(payload['object_id'])));
          if (post != null) {
            // navigateToRoute(context, SinglePostView(isCurrentUser: false, postSet: FeedPostSetModel.fromMap(post), deep:true))
            context.go('/SinglePostView/true', extra: post as Map<String, dynamic>);
          }
        }
        ;
      default:
        {
          if (home) {
            context.go('/auth_widget');
          }
        }
    }
    navigationPayload.payload = null;
  } else {
    if (home) {
      context.go('/auth_widget');
    }
  }
  // }catch(e){
  //   print(e);
  // }
}
