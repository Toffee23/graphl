import 'dart:async';

import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class DeletedPostRepository {
  DeletedPostRepository._();

  static DeletedPostRepository instance = DeletedPostRepository._();

  // Method to fetch deleted posts
  Future<Either<CustomException, List<dynamic>>> getDeletedPosts({
    required String? username,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
        query DeletedPosts {
          deletedPosts {
            id
            caption
            daysRemaining
            deleted
            media{
              thumbnail
            }
          }
        }
        ''',
        payload: {
          'user': username,
        },
      );

      return result.fold(
        (left) => Left(left),
        (right) => Right(right!['deletedPosts'] as List<dynamic>),
      );
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  // Method to restore a deleted post
  Future<Either<CustomException, Map<String, dynamic>>> restorePost({
    required String postId,
  }) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
         mutation restorePost(\$postId: String!) {
            restorePost(postId: \$postId) {
              status
              message
            }
         }
        ''',
        payload: {
          'postId': postId,
        },
      );

      return result.fold(
        (left) => Left(left),
        (right) => Right(right!['restorePost']),
      );
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}