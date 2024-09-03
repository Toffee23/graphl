import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

abstract class ActivityRepository {
  Future<Either<CustomException, Map<String, dynamic>>> getActivities({
    required int pageCount,
    required int pageNumber,
  });
}

class ActivitiesRepository implements ActivityRepository {
  @override
  Future<Either<CustomException, Map<String, dynamic>>> getActivities({
    required int pageCount,
    required int pageNumber,
  }) async {
    //print('[wzs1] repo page ${pageNumber}, pageCount $pageCount');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query UserActivities (\$pageCount: Int, \$pageNumber: Int) {
        
        userActivities (pageCount:\$pageCount, pageNumber:\$pageNumber) {
          id
          deleted
          user {
            username
            email
            firstName
            lastName
          }
          content
          activityType
          post {
            id
            hasVideo
            hasAudio
            likes
            caption
            media {
              itemLink
              thumbnail
              deleted
            }
            userLiked
            user {
              id
              username
            }
          }
          comment {
            id
            user {
              id
              username
            }
            upVotes
            comment
            userLiked
            post {
              hasVideo
              hasAudio
              likes
              media {
                itemLink
                thumbnail
                deleted
              }
            }
          }
          coupon {
            id
            code
            deleted
          }
          createdAt
        }
        # notificationsTotalNumber
      }
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });
      //print('Notification Fetching user notifications $result');

      final Either<CustomException, Map<String, dynamic>> response = result.fold((left) => Left(left), (right) {
        // //print("77777777777777777777777777777777 $right");

        // final albumList = right?['notifications'] as List<dynamic>?;
        return Right(right!);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}




