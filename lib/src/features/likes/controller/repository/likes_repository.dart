import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

abstract class LikeRepository {
  Future<Either<CustomException, List<dynamic>>> getLikes({String? hashSearch});
  Future<void> likeAComment({required String commentId});
}

class LikesRepository implements LikeRepository {
  @override
  Future<Either<CustomException, List<dynamic>>> getLikes(
      {String? hashSearch}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
       query postHashtagSearch(\$pageCount: Int, \$pageNumber: Int,
           \$hashSearch: String!) {
          postHashtagSearch(pageCount: \$pageCount, pageNumber: \$pageNumber,
           hashSearch: \$hashSearch) {
            id
            likes
            userLiked
            usersThatLiked{
              id
              username
            }
          }
          postHashtagSearchTotalNumber
        }
        ''', payload: {
        "hashSearch": hashSearch,
        'pageCount': 20,
        'pageNumber': 1,
      });
      final Either<CustomException, List<dynamic>> response =
          result.fold((left) => Left(left), (right) {
        final albumList = right as List<dynamic>?;
        return Right(albumList ?? []);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<void> likeAComment({
    required String commentId,
  }) async {
    try {
      final response = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
          mutation LikeComment{
          likeComment(commentId: $commentId){
            success
          }
        }
      ''',
        payload: {
          'commentId': commentId,
        },
      );
    } catch (e) {
      //print("error: $e");
    }
  }
}
