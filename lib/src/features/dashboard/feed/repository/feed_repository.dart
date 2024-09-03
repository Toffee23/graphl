import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../../core/utils/exception_handler.dart';

final feedRepoInstance = FeedRepository.instance;

class FeedRepository {
  FeedRepository._();
  static FeedRepository instance = FeedRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> getFeedStream({int? pageCount, int? pageNumber}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
          
  query feedPosts(\$pageCount: Int, \$pageNumber: Int) {
  allPosts(feed: true, pageCount: \$pageCount, pageNumber: \$pageNumber) {
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
  allPostsTotalNumber
}
          
''', payload: {
        "pageCount": pageCount,
        "pageNumber": pageNumber,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        // return Right(right!['allPosts']);
        //print("allPosts ${right!['allPostsTotalNumber']}");
        return Right(right!);
      });
    } catch (e) {
      //print(e);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getContentStream({int? pageCount, int? pageNumber}) async {
    try {
      //print('about to to do graph ql on some tinx');
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
          
  query feedPosts(\$pageCount: Int, \$pageNumber: Int, \$postType: PostTypeEnum) {
  allPosts(pageCount: \$pageCount, pageNumber: \$pageNumber, postType: \$postType) {
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
      banner{
        thumbnail
        url
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
      label
      isBusinessAccount
      thumbnailUrl
      profilePictureUrl
      isVerified
      blueTickVerified
      profileRing
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
  allPostsTotalNumber
}
          
''', payload: {
        "pageCount": pageCount,
        "pageNumber": pageNumber,
        "postType": 'VIDEO',
      });

      // return result.
      return result.fold((left) {
        //print("allContents went left");

        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      //print(e);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> likePost(int postId) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''

    mutation toggleLike(\$postId: Int!) {
    likePost(postId: \$postId) {
      success
      }
    }
          
''', payload: {"postId": postId});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['likePost']);
      });
    } catch (e) {
      //print(e);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Map<String, dynamic>> getSinglePost(int postId) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
    query getPostLikes(\$postId: Int!) {
        post(id: \$postId) {
        id
        createdAt
        updatedAt
        caption
        aspectRatio
        locationInfo
        likes
        userLiked
        userSaved
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
                isBusinessAccount
                userType
                label
                thumbnailUrl
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
                thumbnailUrl
                profilePictureUrl
              }
              media {
                id
                itemLink
                description
                thumbnail
                dimension
              }
      }
    }
          
''', payload: {"postId": postId});

      return result.fold((left) {
        //print('$left');
        return {};
      }, (right) {
        logger.f(right!['post']);
        return right['post'];
      });
    } catch (e) {
      //print(e);
      return {};
    }
  }

  Future<Map<String, dynamic>> getPostLikesInfo(int postId) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
    query getPostLikes(\$postId: Int!) {
        post(id: \$postId) {
        likes
        userLiked
      }
    }
          
''', payload: {"postId": postId});

      return result.fold((left) {
        //print('$left');
        return {};
      }, (right) {
        return right!['post'];
      });
    } catch (e) {
      //print(e);
      return {};
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> savePost(int postId) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation SavePost(\$postId: Int!) {
            savePost(postId: \$postId) {
              success
              message
            }
          }
        ''', payload: {'postId': postId});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        //print('%%%%%%%%%%%%%%% $right');
        // final isSuccessful = right!['savePost']['success'];
        return Right(right!['savePost']);
      });

      return userName;
    } catch (e) {
      // log('${e.toString()}');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> deleteSavedPost(int postId) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation DeleteSavedPost(\$postId: Int!) {
            deleteSavedPost(savedPostId: \$postId) {
              success
              message
            }
          }
        ''', payload: {'postId': postId});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        //print('%%%%%%%%%%%%%%% $right');
        // final isSuccessful = right!['savePost']['success'];
        return Right(right!['deleteSavedPost']);
      });

      return userName;
    } catch (e) {
      // log('${e.toString()}');
      return Left(CustomException(e.toString()));
    }
  }
}
