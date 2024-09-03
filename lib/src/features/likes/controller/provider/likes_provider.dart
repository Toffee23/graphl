import 'dart:async';

import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/features/likes/controller/provider/my_likes_provider.dart';
import 'package:vmodel/src/features/likes/controller/repository/likes_repository.dart';
import 'package:vmodel/src/vmodel.dart';

final likesProvider = Provider<LikeRepository>((ref) => LikesRepository());

final getLikes =
    FutureProvider<Either<CustomException, List<dynamic>>>((ref) async {
  String hashSearch = ref.read(myLikesTypeProvider);
  return ref.read(likesProvider).getLikes(hashSearch: hashSearch);
});

class LikeNotifier extends ChangeNotifier {
  LikeNotifier(this.ref) : super();
  final Ref ref;

  Future<Either<CustomException, List<dynamic>>> getLikes(
      {String? hashSearch}) async {
    final repository = ref.read(likesProvider);
    late Either<CustomException, List<dynamic>> response;

    response = await repository.getLikes(hashSearch: hashSearch);

    return response;
  }

  Future<void> likeAComment({required String commentId}) async {
    final repository = ref.watch(likesProvider);
    late Either<CustomException, List<dynamic>> response;

    try {
      await repository.likeAComment(commentId: commentId);
    } catch (e) {
      // print(e.toString());
    }
  }
}
