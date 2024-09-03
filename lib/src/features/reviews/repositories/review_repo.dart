import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class ReviewRepository {
  ReviewRepository._();
  static ReviewRepository instance = ReviewRepository._();

  /// Reporting a BUG
  Future<Either<CustomException, Map<String, dynamic>>> rateUser({required String username, required String rating, required String comment}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              mutation rateUser (\\$username: String!, \\$rating: RatingEnum!, \\$comment: String){
  reviewUser(username: \\$username, rating:\\$rating, comment: \\$comment){
    message
  }
}
      ''',
        payload: {'username': username, 'rating': rating, 'comment': comment},
      );

      //print("Result \$result");
      final Either<CustomException, Map<String, dynamic>> getReportResult = result.fold(
        (left) {
          //print("Left: \$left");
          return Left(left);
        },
        (right) {
          //print(right);
          final getReportResul = right?['reviewUser'] as Map<String, dynamic>?;

          return Right(getReportResul!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> editReview({required int reviewId, required String username, required String rating, required String comment}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              mutation editReview (\\$reviewId: Int!, \\$rating: RatingEnum!, \\$comment: String){
  editReview(reviewId: \\$reviewId, rating:\\$rating, comment: \\$comment){
    message
  }
}
      ''',
        payload: {'reviewId': reviewId, 'rating': rating, 'comment': comment},
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult = result.fold(
        (left) {
          //print("Left: \$left");
          return Left(left);
        },
        (right) {
          //print(right);
          final getReportResul = right?['editReview'] as Map<String, dynamic>?;

          return Right(getReportResul!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> deleteReviewReply({required int replyId}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
        mutation DeleteReviewReply(\$replyId: Int!){
            deleteReviewReply(replyId: \$replyId ){
                success
                message
              }
            }
      ''',
        payload: {
          "replyId": replyId,
        },
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult = result.fold(
        (left) {
          //print("Left: \$left");
          return Left(left);
        },
        (right) {
          return Right({});
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateReview({
    required String reviewText,
    required int reviewId,
    required String rating,
    required String reviewType,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
            mutation UpdateReview(\$rating: RatingsEnum!, \$reviewId: ID!, \$reviewType: ReviewTypeEnum!, \$reviewText: String) {
              updateReview(rating: \$rating, reviewId: \$reviewId, reviewType: \$reviewType, reviewText: \$reviewText) {
                errors
                success
              }
            }''',
        payload: {
          'reviewText': reviewText,
          'rating': rating,
          'reviewId': reviewId,
          'reviewType': reviewType,
        },
      );
      final Either<CustomException, Map<String, dynamic>> getReportResult = result.fold(
        (left) {
          return Left(left);
        },
        (right) {
          return Right(right ?? {});
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createOrUpdateReply({
    required String reply,
    required int reviewId,
    required String reviewType,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
         mutation ReviewReply(\$replyText: String!, \$reviewId: Int!) {
              createOrUpdateReviewReply(replyText: \$replyText, reviewId: \$reviewId){
                reply {
                  replyText
                }
                message
              }
            }''',
        payload: {
          "replyText": reply,
          "reviewId": reviewId,
        },
      );

      // final result = await vBaseServiceInstance.getQuery(
      //   queryDocument: '''
      //    mutation CreateOrUpdateReviewReply(\$replyText: String!, \$reviewId: ID!, \$reviewType: ReviewTypeEnum!) {
      //         createOrUpdateReviewReply(replyText: \$replyText, reviewId: \$reviewId, reviewType: \$reviewType){
      //           reviewReply {
      //             id
      //           }
      //         }
      //       }''',
      //   payload: {
      //     "replyText": reply,
      //     "reviewId": reviewId,
      //     "reviewType": reviewType,
      //   },
      // );

      final Either<CustomException, Map<String, dynamic>> getReportResult = result.fold(
        (left) {
          return Left(left);
        },
        (right) {
          return Right(right ?? {});
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  /// Reporting a BUG
  Future<Either<CustomException, Map<String, dynamic>>> userReviews(Map<String, bool> filters, String? order) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
             query UserReviews(\$filters: ReviewFiltersInput, \$order: String) {
                userReviews(filters: \$filters, order: \$order) {
                  id
                  rating
                  reviewText
                  reviewer {
                    profilePictureUrl
                    userType
                    username
                    profileRing
                  }
                  reviewed{
                    username
                    userType
                    profilePictureUrl
                    profileRing
                  }
                  reviewReply{
                    replyText
                    id
                    createdAt
                  }
                  createdAt
                  }
              }
      ''',
        payload: {
          "filters": {
            "all": filters['all'],
            "reviewsForMe": filters['reviewsForMe'],
            "reviewsByMe": filters['reviewsByMe'],
            "autoReview": filters['autoReview'],
          },
          "order": order,
        },
      );

      //print("Result \$result");
      final Either<CustomException, Map<String, dynamic>> getRatingResult = result.fold(
        (left) {
          //print("Left: \$left");
          return Left(left);
        },
        (right) {
          //print(right);
          final getUserReviews = right;

          return Right(getUserReviews!);
        },
      );

      return getRatingResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
