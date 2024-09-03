import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/repository/app_user_repository.dart';
import '../../../create_posts/models/post_set_model.dart';
import '../repository/profile_repo.dart';

final profileProvider = AsyncNotifierProvider.autoDispose.family<ProfileNotifier, VAppUser?, String?>(() => ProfileNotifier());

final profileProviderNoFlag = AsyncNotifierProvider.autoDispose.family<ProfileNotifierNoFlag, VAppUser?, String?>(() => ProfileNotifierNoFlag());

final _allPostSet = StateProvider<List<AlbumPostSetModel>>((ref) => []);

class ProfileNotifier extends AutoDisposeFamilyAsyncNotifier<VAppUser?, String?> {
  // ProfileNotifier() : super();
  final _repository = ProfileRepository.instance;
  final _userRepository = AppUserRepository.instance;

  @override
  Future<VAppUser?> build(arg) async {
    // getUserPosts(arg);
    if (arg != null) {
      return await getUserProfile(arg, notify: true);
    }
    return null;
  }

  Future<VAppUser?> getUserProfile(String username, {bool notify = true}) async {
    final userProfile = await _userRepository.getAppUserInfo(username: username, notify: notify);
    VAppUser? initialState;
    userProfile.fold((left) {
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      //print("response ${right['jobNotification']}");
      try {
        final newState = VAppUser.fromMap(right);
        initialState = newState;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });

    return initialState;
  }

  Future<void> followUser(String username) async {
    final response = await _repository.followUser(username);

    response.fold((left) {
      //print("error on following ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) async {
      try {
        if (right['success']) {
          VAppUser? user = await getUserProfile(username);
          final currentUser = user; //state.value;
          state = AsyncData(currentUser);
        }
      } catch (e) {
        //print(" $e");
      }
    });
    return;
  }

  Future<void> unFollowUser(String username) async {
    final response = await _repository.unFollowUser(username);

    response.fold((left) {
      //print("error on unfollowing ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      try {
        if (right['success']) {
          final currentUser = state.value;
          state = AsyncData(currentUser?.copyWith(isFollowing: false));
          //print("unfollowing");
        }
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });
    return;
  }

  void toggleFollowingNotification({
    required bool notifyOnJob,
    required bool notifyOnPost,
    required bool notifyOnCoupon,
    required bool notifyOnService,
    required String username,
  }) async {
    final response = await _repository.toggleFollowingNotification(
      notifyOnJob: notifyOnJob,
      notifyOnPost: notifyOnPost,
      notifyOnCoupon: notifyOnCoupon,
      notifyOnService: notifyOnService,
      username: username,
    );

    response.fold((left) {
      //print("error on following ${left} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      //print('qqqqqq');
      try {
        if (right['toggleFollowingNotification']['success']) {
          final currentState = state.value;
          state = AsyncData(currentState?.copyWith(
            postNotification: notifyOnPost,
            jobNotification: notifyOnJob,
            couponNotification: notifyOnCoupon,
          ));
          //print("notification updated");
        }
      } catch (e) {
        //print(" $e");
      }
    });
  }

  Future<void> toggleStarSign(String username) async {
    final response = await _repository.unFollowUser(username);

    response.fold((left) {
      //print("error on unfollowing ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      try {
        if (right['success']) {
          final currentUser = state.value;
          state = AsyncData(currentUser?.copyWith(displayZodiacSign: 'NO'));
          //print("TOGGLED star sign");

          //print('new user star is ${state.value!.displayZodiacSign!}');
        }
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });
    return;
  }
}

class ProfileNotifierNoFlag extends AutoDisposeFamilyAsyncNotifier<VAppUser?, String?> {
  // ProfileNotifier() : super();
  final _repository = ProfileRepository.instance;
  final _userRepository = AppUserRepository.instance;

  @override
  Future<VAppUser?> build(arg) async {
    // getUserPosts(arg);
    if (arg != null) {
      return await getUserProfile(arg, notify: false);
    }
    return null;
  }

  Future<VAppUser?> getUserProfile(String username, {bool notify = false}) async {
    final userProfile = await _userRepository.getAppUserInfo(username: username, notify: notify);
    VAppUser? initialState;
    userProfile.fold((left) {
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      //print("response ${right['jobNotification']}");
      try {
        final newState = VAppUser.fromMap(right);
        initialState = newState;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });

    return initialState;
  }

  Future<void> followUser(String username) async {
    final response = await _repository.followUser(username);

    response.fold((left) {
      //print("error on following ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) async {
      try {
        if (right['success']) {
          VAppUser? user = await getUserProfile(username);
          final currentUser = user; //state.value;
          state = AsyncData(currentUser);
        }
      } catch (e) {
        //print(" $e");
      }
    });
    return;
  }

  Future<void> unFollowUser(String username) async {
    final response = await _repository.unFollowUser(username);

    response.fold((left) {
      //print("error on unfollowing ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      try {
        if (right['success']) {
          final currentUser = state.value;
          state = AsyncData(currentUser?.copyWith(isFollowing: false));
          //print("unfollowing");
        }
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });
    return;
  }

  void toggleFollowingNotification({
    required bool notifyOnJob,
    required bool notifyOnPost,
    required bool notifyOnCoupon,
    required bool notifyOnService,
    required String username,
  }) async {
    final response = await _repository.toggleFollowingNotification(
      notifyOnJob: notifyOnJob,
      notifyOnPost: notifyOnPost,
      notifyOnCoupon: notifyOnCoupon,
      notifyOnService: notifyOnService,
      username: username,
    );

    response.fold((left) {
      //print("error on following ${left} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      //print('qqqqqq');
      try {
        if (right['toggleFollowingNotification']['success']) {
          final currentState = state.value;
          state = AsyncData(currentState?.copyWith(
            postNotification: notifyOnPost,
            jobNotification: notifyOnJob,
            couponNotification: notifyOnCoupon,
          ));
          //print("notification updated");
        }
      } catch (e) {
        //print(" $e");
      }
    });
  }

  Future<void> toggleStarSign(String username) async {
    final response = await _repository.unFollowUser(username);

    response.fold((left) {
      //print("error on unfollowing ${left.message} ${StackTrace.current}");
      // return AsyncError(left.message, StackTrace.current);
    }, (right) {
      try {
        if (right['success']) {
          final currentUser = state.value;
          state = AsyncData(currentUser?.copyWith(displayZodiacSign: 'NO'));
          //print("TOGGLED star sign");

          //print('new user star is ${state.value!.displayZodiacSign!}');
        }
      } catch (e) {
        //print("AAAAAAA error parsing json response $e");
      }
    });
    return;
  }
}
