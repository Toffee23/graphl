import 'package:either_option/either_option.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../../app_locator.dart';
import '../../../../core/utils/exception_handler.dart';

final discoverRepoInstance = DiscoverRepository.instance;

class DiscoverRepository {
  DiscoverRepository._();
  static DiscoverRepository instance = DiscoverRepository._();

  // Future<List<Map<String, dynamic>>> searchUsers(String searchQuery) async {
  Future<Either<CustomException, List<dynamic>>> searchUsers(
      String searchQuery) async {
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
        query SearchUsers(\$search: String!) {
          searchUsers(search: \$search) {
            id
            firstName
            lastName
            username
            displayName
            isBusinessAccount
            userType
            label
            isVerified
            blueTickVerified
            profilePictureUrl
            profileRing
            thumbnailUrl
            gender
            ethnicity
            hair
            price
            height {
              user{
                id
              }
              value
              unit
            }
            location {
              locationName
            }
            bio
          }
        }
      ''',
      payload: {'search': searchQuery},
    );

    return result.fold(
      (left) {
        //print('Error searching users: ${left.message}');
        return Left(left);
      },
      (right) {
        return Right(right?['searchUsers']);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getFeaturedTalents(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query featuredTalents(\$pageCount:Int!,\$pageNumber:Int!) {
    featuredTalents(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
            displayName
    label
    userType
            isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
    reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
  featuredTalentsTotalNumber
}
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    //print('------ fetauredTalents  $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right?['featuredTalents'] as List);
      },
    );
  }

  Future<Either<CustomException, Map<String, dynamic>>> getExplore(
      {required int dataCount}) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query explore(\$dataCount: Int!) {
  explore(dataCount: \$dataCount) {
    featuredTalents {
      id
      firstName
      lastName
      username
      displayName
      label
      userType
      isBusinessAccount
      isVerified
      blueTickVerified
      bio
      thumbnailUrl
      profilePictureUrl
      gender
      ethnicity
      hair
      price
       reviewStats{
      noOfReviews
      rating
    }
      height {
        value
        unit
      }
      location {
        locationName
      }
    }
    risingTalents {
      id
      firstName
      lastName
      username
      displayName
      label
      userType
      isBusinessAccount
      isVerified
      blueTickVerified
      bio
      thumbnailUrl
      profilePictureUrl
      gender
      ethnicity
      hair
      price
      reviewStats{
        noOfReviews
        rating
      }
      height {
        value
        unit
      }
      location {
        locationName
      }
    }
    popularTalents {
      id
      firstName
      lastName
      username
      displayName
      label
      userType
      isBusinessAccount
      isVerified
      blueTickVerified
      bio
      thumbnailUrl
      profilePictureUrl
      gender
      ethnicity
      hair
      price
       reviewStats{
      noOfReviews
      rating
    }
      height {
        value
        unit
      }
      location {
        locationName
      }
    }
    photographers {
      id
      firstName
      lastName
      username
      displayName
      label
      userType
      isBusinessAccount
      isVerified
      blueTickVerified
      bio
      thumbnailUrl
      profilePictureUrl
      gender
      ethnicity
      hair
      price
       reviewStats{
      noOfReviews
      rating
    }
      height {
        value
        unit
      }
      location {
        locationName
      }
    }
    petModels {
      id
      firstName
      lastName
      username
      displayName
      label
      userType
      isBusinessAccount
      isVerified
      blueTickVerified
      bio
      thumbnailUrl
      profilePictureUrl
      gender
      ethnicity
      hair
      price
       reviewStats{
      noOfReviews
      rating
    }
      height {
        value
        unit
      }
      location {
        locationName
      }
    }
  }
}
      ''',
      payload: {'dataCount': dataCount},
    );

    //print('------ fetauredTalents  $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right?['explore']);
      },
    );
  }

  Future<Either<CustomException, Map<String, dynamic>>> getAccountsToFollow({
    required int pageCount,
    required int pageNumber,
  }) async {
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
        query accountsToFollow(\$pageCount: Int, \$pageNumber: Int) {
          accountsToFollow(pageCount: \$pageCount, pageNumber: \$pageNumber) {
            id
            firstName
            lastName
            username
            displayName
            label
            userType
            isBusinessAccount
            isVerified
            blueTickVerified
            thumbnailUrl
            profilePictureUrl
            profileRing
             reviewStats{
              noOfReviews
              rating
            }
            location {
              locationName
            }
          }
          accountsToFollowTotalNumber
        }
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    return result.fold(
      (left) {
        //print('Error fetching account to follow list: ${left.message}');
        return Left(left);
      },
      (right) {
        return Right(right!);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getPetModels(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query petModels(\$pageCount:Int!,\$pageNumber:Int!) {
    petModels(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
     reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    petModelsTotalNumber
}
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    //print('------ petmodels  $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right   pettttt --------');
        return Right(right?['petModels'] as List);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getRT(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query risingTalents(\$pageCount:Int!,\$pageNumber:Int!) {
    risingTalents(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    risingTalentsTotalNumber
}
      ''',
      payload: {
        'pageCount': pageCount,
        //'pageNumber': pageNumber,
      },
    );

    //print('------ risingTalents  $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getPopularTalents(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query popularTalents(\$pageCount:Int!,\$pageNumber:Int!) {
    popularTalents(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
     reviewStats{
      noOfReviews
      rating
    }
  }
}
      ''',
      payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      },
    );

    return result.fold(
      (left) {
        return Left(left);
      },
      (right) {
        final data = right;
        return Right(right);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getRisingTalents(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query risingTalents(\$pageCount:Int!,\$pageNumber:Int!) {
    risingTalents(pageCount:\$pageCount, pageNumber:\$pageNumber) {
   id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
     reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    risingTalentsTotalNumber
}
      ''',
      payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      },
    );

    //print('------ risingTalents  $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right?['risingTalents'] as List);
      },
    );
  }

  Future<Either<CustomException, dynamic>> getPhotographers(
      int pageCount, int pageNumber) async {
    //print('--featured called ---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query photographers(\$pageCount:Int!,\$pageNumber:Int!) {
    photographers(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
      isVerified
      blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
    reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    photographersTotalNumber
}
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    //print('------ photography $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right?['photographers'] as List);
      },
    );
  }

  Future<Either<CustomException, Map<String, dynamic>>> getTalentsNearYou({
    required int pageCount,
    required int pageNumber,
  }) async {
    //print('--talent near you---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query talentsNearYou(\$pageCount:Int!,\$pageNumber:Int!) {
    talentsNearYou(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
      isBusinessAccount
    isVerified
    blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
    reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    talentsNearYouTotalNumber
}
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    //print('------ photography $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right!);
      },
    );
  }

  Future<Either<CustomException, Map<String, dynamic>>> getRecommendedBusiness({
    required int pageCount,
    required int pageNumber,
  }) async {
    //print('--Fetch recommended businesses---');
    final result = await vBaseServiceInstance.mutationQuery(
      mutationDocument: '''
  query talentsNearYou(\$pageCount:Int!,\$pageNumber:Int!) {
    recommendedBusinesses(pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
    firstName
    lastName
    username
    displayName
    label
    userType
    isBusinessAccount
    isVerified
    blueTickVerified
    thumbnailUrl
    profilePictureUrl
    gender
    ethnicity
    hair
    price
    reviewStats{
      noOfReviews
      rating
    }
    height {
      user{
        id
      }
      value
      unit
    }
    location {
      locationName
    }
    bio
  }
    recommendedBusinessesTotalNumber
}
      ''',
      payload: {'pageCount': pageCount, 'pageNumber': pageNumber},
    );

    //print('------ photography $result ---');

    return result.fold(
      (left) {
        //print('Error fetching featured list: ${left.message}');
        return Left(left);
      },
      (right) {
        final data = right;
        //print('yyyyayyyyy ----$data -----');
        //print('----------- $right --------');
        return Right(right!);
      },
    );
  }

  Future<Either<CustomException, List<dynamic>>> getPopularGalleries(
      {String? username}) async {
    //print('CreatePostRepo Fetching user posts');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query mostLikedGalleries{
  mostLikedGalleries {
     id
    name
    albumType
    postSet {
      id
      createdAt
      updatedAt
      caption
      aspectRatio
      locationInfo
      likes
      userLiked
      userSaved
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
        displayName
        isBusinessAccount
        userType
        label
        thumbnailUrl
        profilePictureUrl
        isVerified
        blueTickVerified
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
      photos {
        id
        itemLink
        description
        thumbnail
      }
    }
  }
}
        ''', payload: {});

      final Either<CustomException, List<dynamic>> response =
          result.fold((left) => Left(left), (right) {
        // //print("77777777777777777777777777777777 $right");

        final albumList = right?['mostLikedGalleries'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> suggestedServices(
      {required String desc, String? location}) async {
    //print('CreatePostRepo Fetching user posts');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query SuggestedServices(\$desc: String!, \$location: String){
          suggestedServices(
              desc: \$desc,
              location: \$location,
            ) {
               id
    title
    description
   serviceType{
      id
      name
       subTypes{
          id
          name
        }
    }
    subType{
        id
        name
      }
    serviceLocation
    period
    price
    #meta
    isDigitalContentCreator
    hasAdditional
    isOffer
    discount
    deliverablesType
    usageType
    likes
    saves
    shares
    userLiked
    usageLength
    #deleted
    deliveryTimeline
    views
    faq
    createdAt
    lastUpdated
    banner {
      url
      thumbnail
    }
    initialDeposit
    #category
    paused
    processing
    status
    user {
      id
      username
      displayName
      isVerified
      blueTickVerified
      isBusinessAccount
      profilePictureUrl
      thumbnailUrl
               location {
                locationName
               }
    }
    delivery {
      id
      name
    }
  }
}
        ''', payload: {
        'desc': desc,
        'location': location,
      });

      return result.fold((left) => Left(left), (right) {
        return Right(right!['suggestedServices']);
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> popularPostVideos() async {
    //print('CreatePostRepo Fetching user posts');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query RandomVideos{
          randomPostClips {
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
        }
        ''', payload: {});

      return result.fold((left) => Left(left), (right) {
        return Right(right!['randomPostClips']);
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> popularHashTag() async {
    //print('CreatePostRepo Fetching user posts');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
        query Hashtag{
          popularHashtags(top:40){
            hashtag
            count
          }
        }
              ''', payload: {});
      return result.fold((left) => Left(left), (right) {
        return Right(right!['popularHashtags']);
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }
}

//
