import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';

import '../../../../../core/utils/exception_handler.dart';

// final recommendedPostsRepoInstance = RecommendedRepository.instance;

class RecommendedRepository {
  RecommendedRepository._();
  static RecommendedRepository instance = RecommendedRepository._();
  Future<Either<CustomException, Map<String, dynamic>>> getFeedStream({
    required int pageNumber,
    required int pageCount,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
  query RecommendForUser(\$pageCount: Int!, \$pageNumber: Int) {
  recommendForUser(pageCount: \$pageCount, pageNumber: \$pageNumber) {
    id
    likes
    aspectRatio
    locationInfo
    hasVideo
    caption
    likes
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
      banner {
          url
          thumbnail
        }
      user {
       id
       username
       profilePictureUrl
      }
    }
    user {
      id
      username
      displayName
      userType
      profileRing
      label
      isBusinessAccount
      thumbnailUrl
      profilePictureUrl
      isVerified
      blueTickVerified
    }
    album{
      id
      name
    }
    tagged {
      id
      username
      profilePictureUrl
      thumbnailUrl
      profileRing
    }
    media{
      id
      itemLink
      thumbnail
      description
      dimension
      mediaType
    }
    usersThatLiked{
      id
      username
      profilePictureUrl
      thumbnailUrl
      displayName
      label
      isVerified
      blueTickVerified
    }

  }
  recommendForUserTotalNumber
}
          
''',
        payload: {
          'pageCount': pageCount,
          'pageNumber': pageNumber,
        },
      );

      return result.fold((left) {
        return Left(left);
      }, (right) {
        // return Right(right!['allPosts']);
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
