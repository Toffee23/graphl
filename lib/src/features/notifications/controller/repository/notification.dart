import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

abstract class NotificationRepository {
  Future<Either<CustomException, Map<String, dynamic>>> getNotifications({
    int? pageCount,
    int? pageNumber,
    bool profileView,
  });
}

class NotificationsRepository implements NotificationRepository {
  @override
  Future<Either<CustomException, Map<String, dynamic>>> getNotifications({
    int? pageCount,
    int? pageNumber,
    bool profileView = false,
  }) async {
    //print('[wzs1] repo page ${pageNumber}, pageCount $pageCount');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query notifications (\$pageCount: Int, \$pageNumber: Int, \$profileView: Boolean) {
        
  notifications (pageCount:\$pageCount, pageNumber:\$pageNumber,profileView: \$profileView) {
    id
    sender{
      profilePictureUrl
      profileRing
    }
    id
    modelGroup
    meta
    isConnectionRequest
    connected
    post{
      id
      likes
      aspectRatio
      locationInfo
      caption
      userLiked
      userSaved
      createdAt
      updatedAt
      service {
        id
        title
        price
        description
        period
        user {
          id
          username
        }
      }
      user {
        id
        username
        firstName
        lastName
        profilePictureUrl
        isVerified
        blueTickVerified
        profileRing
      }
      album {
        id
        name
      }
      tagged {
        id
        username
        profilePictureUrl
      }
      media{
        id
        itemLink
        thumbnail
        description
        mediaType
      }
      #id
      #user{
      #id
      #firstName
      #lastName
      #username
      #profilePictureUrl
      #}
      #aspectRatio
    }
    message
    model
    modelId
    read
    createdAt
  }
  notificationsTotalNumber
}
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
        'profileView': profileView,
      });

      final Either<CustomException, Map<String, dynamic>> response = result.fold((left) => Left(left), (right) {
        logger.f(right);
        return Right(right!);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
