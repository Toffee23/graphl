import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class LocalServicesRepository {
  LocalServicesRepository._();
  static LocalServicesRepository instance = LocalServicesRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> getAllServices({
    bool? popular,
    int? pageCount,
    int? pageNumber,
    String? search,
    String? remote,
    String? discounted,
    String? sort = 'NEWEST_FIRST',
  }) async {
    //print('[oe9s] print remote $remote, discounted $discounted');

    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
query allServices(\$pageNumber: Int, \$popular: Boolean, \$pageCount: Int,
                  \$search: String,  \$remote: String,
                  \$discounted: String, \$sort: SortEnum
) {
 
  allServices(pageNumber: \$pageNumber, pageCount: \$pageCount, popular: \$popular,
  search: \$search,  remote: \$remote, discounted: \$discounted, sort: \$sort
  ) {
    id
    title
    discount
    userLiked
    banner {
      url
      thumbnail
    }
    views
    price
    deliverablesType
    description
    period
    isOffer
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
    expressDelivery
    travelFee
    tiers{
      id
      tier
      customTitle
      customDescription
      price
      revisions
      addons{
        id
        addOnName
        price
        description
      }
    }
    usageType
    createdAt
    faq
    lastUpdated
    #deleted
    paused
    status
    user {
      id
      username
      fullName
      userType
      label
       reviewStats{
        noOfReviews
        rating
      }
      isBusinessAccount
      isVerified
      blueTickVerified
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
    hasAdditional
    likes
  }
   allServicesTotalNumber
}
        ''', payload: {
        'popular': popular,
        'pageCount': pageCount,
        'pageNumber': pageNumber,
        'search': search,
        'remote': remote,
        'discounted': discounted,
        'sort': sort,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getPopularServices({
    required int dataCount,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query popularServices(\$dataCount: Int!, ) {
  explore(dataCount: \$dataCount,) {
       popularServices {
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
        expressDelivery
        travelFee
        tiers{
          id
          tier
          customTitle
          customDescription
          price
          revisions
          addons{
            id
            addOnName
            price
            description
          }
        }
        period
        price
        deliverablesType
        isDigitalContentCreator
        hasAdditional
        discount
        usageType
        usageLength      
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
    paused
    processing
    status
        user {
          id
          username
          profilePictureUrl
           reviewStats{
            noOfReviews
            rating
          }
          isBusinessAccount
          userType
          label
        }
        delivery {
          id
          name
        }
      }
    }
  }

        ''', payload: {"dataCount": dataCount});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        //print('popularJobsss ${right!['explore']['popularJobs']}');
        return Right(right!['explore']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

class SavedServicesRepository {
  SavedServicesRepository._();
  static SavedServicesRepository instance = SavedServicesRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> getSavedServices({
    int? pageCount,
    int? pageNumber,
  }) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
query savedServices(\$pageCount: Int, \$pageNumber: Int) {
  savedServices(pageCount: \$pageCount, pageNumber: \$pageNumber) {
    id
    service {
      id
      title
      discount
      banner {
        url
        thumbnail
      }
      views
      price
      description
      period
      isOffer
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
      expressDelivery
    travelFee
    tiers{
      id
      tier
      customTitle
      customDescription
      price
      revisions
      addons{
        id
        addOnName
        price
        description
      }
    }
      usageType
      deliverablesType
      createdAt
      lastUpdated
      paused
      status
      user {
        id
        username
        fullName
        userType
        label
         
        reviewStats{
          noOfReviews
          rating
        }
        isBusinessAccount
        isVerified
        blueTickVerified
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
      hasAdditional
      likes
    }
  }
  savedServicesTotalNumber
}
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> searchSavedServices({
    int? pageCount,
    int? pageNumber,
    String? search = "",
  }) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
query searchSavedServices(\$pageCount: Int, \$pageNumber: Int, \$search: String!) {
  searchSavedServices(pageCount: \$pageCount, pageNumber: \$pageNumber, search: \$search) {
      id
      title
      discount
      banner {
        url
        thumbnail
      }
      views
      price
      description
      deliverablesType
      period
      isOffer
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
      expressDelivery
    travelFee
    tiers{
      id
      tier
      customTitle
      customDescription
      price
      revisions
      addons{
        id
        addOnName
        price
        description
      }
    }
      usageType
      createdAt
      lastUpdated
      paused
      status
      user {
        id
        username
        fullName
        userType
        label
        isBusinessAccount
      
         reviewStats{
            noOfReviews
            rating
          }
        isVerified
        blueTickVerified
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
      hasAdditional
      likes
    }
  
}
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
        "search": search,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getLikedServices() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
            query likedServices {
              likedServices(pageCount: 10, pageNumber: 1){
                service{
                  user{
                    id
                    reviewStats{
                    noOfReviews
                    rating
                  }
                    username
                  }
                  title
                  description
                  deliverablesType
                }
              }
            }

        ''', payload: {
        'pageCount': 10,
        'pageNumber': 1,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> removeSavedService({required int serviceId}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation RemovedSavedService(\$serviceId: Int!) {
            removeSavedService(serviceId: \$serviceId) {
              success
              message
            }
          }
        ''', payload: {
        "serviceId": serviceId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['removeSavedService']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
