import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/all_users_model.dart';
import 'package:vmodel/src/features/dashboard/new_profile/repository/all_users_repo.dart';

import '../../../live_classes/model/live_class_type.dart';

final allUsersProvider =
    AutoDisposeAsyncNotifierProvider<AllUsersController, List<AllUsersModel>>(
        () => AllUsersController());

class AllUsersController extends AutoDisposeAsyncNotifier<List<AllUsersModel>> {
  final _repository = AllUsersRepository.instance;

  @override
  FutureOr<List<AllUsersModel>> build() async {
    final getUsers = await _repository.getUsers();
    return getUsers.fold((left) {
      //print("Failed to get users");
      return [];
    }, (right) {
      final blockedUsers = right;
      //print("=======================> >> $blockedUsers");
      try {
        final usersList = blockedUsers.map((e) => AllUsersModel.fromJson(e));
        return usersList.toList();
      } catch (err) {
        //print("========================> $err");
      }
      return [];
    });
  }

  Future<List<dynamic>> getLives(String username) async {
    final getLives = await _repository.getLives(username);
    return getLives.fold((left) {
      //print("Failed to get users");
      return [];
    }, (right) {
      final lives = right;

      return [...lives];
    });
  }
}

final hasLivesProvider =
Provider.autoDispose.family<bool, String?>((ref, username) {
  final lives =
      ref.watch(userLivesProvider(username)).valueOrNull ?? [];
  return lives.isNotEmpty;
});


final userLivesProvider = AsyncNotifierProvider.autoDispose
    .family<UserLivesNotifier, List<dynamic>, String?>(
    UserLivesNotifier.new);

class UserLivesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<dynamic>, String> {
final _repository = AllUsersRepository.instance;

  @override
  Future<List<dynamic>> build(arg) async {
    final res =
    //  isCurrentUser
    //     ?
    await AllUsersRepository.instance
        .getLives(arg);

    return res.fold((left) {

      return [];
    }, (right) {
      final List lives = right;

      var newState;
      try {
        newState = lives.map((e) =>
            LiveClasses.fromJson(e)).toList();
      }catch(e){
      }
      return newState;
    });
  }

}
