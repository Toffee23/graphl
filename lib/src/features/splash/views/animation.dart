import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import '../../../../main.dart';
import '../../../core/notification/redirect.dart';
import '../../../core/utils/helper_functions.dart';
import '../../../vmodel.dart';
import '../../authentication/login/provider/login_provider.dart';
import '../../dashboard/feed/controller/new_feed_provider.dart';
import '../../dashboard/feed/model/feed_model.dart';
import '../../dashboard/new_profile/views/other_profile_router.dart';
import '../../messages/views/messages_chat_screen.dart';
import '../../notifications/widgets/single_post_view.dart';

class AnimatedLogo extends ConsumerStatefulWidget {
  AnimatedLogo({Key? key, this.redirect = true}) : super(key: key);
  bool redirect;
  @override
  ConsumerState<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends ConsumerState<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  double logoOpacity = 0.1;

  @override
  void initState() {
    //print('cali');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2),
      ),
    );
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
      checkString();
    });

    super.initState();
  }

  Future<void> checkString() async {
    if (widget.redirect) {
      if (globalUsername != null) {
        if (!mounted) return;
        final user = ref.watch(appUserProvider);
      }
      if (BiometricService.isEnabled) {
        final isAuthenticated = await ref.read(loginProvider.notifier).authenticateWithBiometricsNew(context);
        if (isAuthenticated) {
          if (context.mounted) {
            ref.watch(invalidateStaleDataProvider);

            redirectNotificationScreen(ref, context, true);
          }
        } else {
          moveAppToBackGround();
        }
      } else {
        ref.watch(invalidateStaleDataProvider);
        final Map<String, dynamic>? payload = navigationPayload.payload;
        if (payload != null) {
          navigationPayload.payload = null;
          switch (payload['page']) {
            case "USER":
              navigateToRoute(
                context,
                OtherProfileRouter(
                  username: payload['object_id'],
                  deep: true,
                ),
              );
            case "CONVERSATION":
              navigateToRoute(
                  context,
                  MessagesChatScreen(
                    id: int.parse(payload['object_id']),
                    username: payload['title'],
                    profilePicture: payload['profilePicture'] ?? 'profilePicture',
                    profileThumbnailUrl: payload['profileThumbnailUrl'] ?? 'profileThumbnailUrl',
                    label: payload['label'] ?? 'label',
                    messages: [],
                    deep: true,
                  ));
            case "POST":
              {
                var post = await (ref.read(mainFeedProvider.notifier).getSinglePost(postId: int.parse(payload['object_id'])));
                if (post != null) {
                  navigateToRoute(context, SinglePostView(isCurrentUser: false, postSet: FeedPostSetModel.fromMap(post), deep: true));
                }
              }
              ;

            default:
              {
                context.push('/feedMainUI');
              }
          }
          navigationPayload.payload = null;
        } else {
          vRef.ref = ref;
          context.go('/auth_widget');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _controller.value < 0.2 ? _fadeInAnimation.value : _fadeOutAnimation.value,
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark ? VmodelAssets1.logoDark : VmodelAssets1.logo,
                height: 216,
                width: 216,
              ),
            );
          }),
    );
  }
}
