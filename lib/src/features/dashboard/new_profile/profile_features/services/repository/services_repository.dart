
import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
// import 'package:get/get.dart';

final servicesRepoInstance = ServicesRepository.instance;

class ServicesRepository {
  ServicesRepository._();

  static ServicesRepository instance = ServicesRepository._();

  Future<Either<CustomException, List<dynamic>>> getUserServices(
      {String? username, String? filterBy}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query userServices(\$username: String,\$filterBy: String,) {
  userServices(username: \$username,filterBy: \$filterBy,) {
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
    serviceLocation
    period
    price
    #meta
    deliverablesType
    isDigitalContentCreator
    hasAdditional
    isOffer
    discount
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
    paused
    processing
    status
    user {
      id
      username
      displayName
      isVerified
     
       reviewStats{
        noOfReviews
        rating
      }
      blueTickVerified
      isBusinessAccount
      profilePictureUrl
      thumbnailUrl 
      businessaddress{
        city
        country
        county
        postalCode
        latitude
        longitude
        streetAddress
      }
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
        "username": username,
        "filterBy": filterBy,
      });

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        final servicesList = right?['userServices'] as List<dynamic>?;
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getRecommendedServices(
      {required int dataCount}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            query recommendedServices(\$dataCount: Int!) {
              explore(dataCount: \$dataCount) {
                recommendedServices {
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
                  serviceLocation
                  period
                  price
                  isDigitalContentCreator
                  deliverablesType
                  hasAdditional
                  isOffer
                  discount
                  usageType
                  likes
                  saves
                  shares
                  userLiked
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
                    displayName
                    isVerified
                    blueTickVerified
                    
                     reviewStats{
                     noOfReviews
                      rating
                    }
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
            }

        ''', payload: {'dataCount': dataCount});

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final servicesList =
            right?['explore']['recommendedServices'] as List<dynamic>?;
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getSimilarServices(
      {String? serviceId}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query similarServices(\$serviceId: Int!) {
  similarServices(serviceId: \$serviceId) {
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
        "serviceId": serviceId,
      });

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final servicesList = right?['similarServices'] as List<dynamic>?;
        //print("nkjwnefwejh ${servicesList!.length}");
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>>
      getRecentlyViewedServices() async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query recentlyViewedServices {
  recentlyViewedServices {
    id
    service {
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
    serviceLocation
      period
      price
      isDigitalContentCreator
      hasAdditional
      deliverablesType
      isOffer
      discount
      usageType
      likes
      faq
      saves
      shares
      userLiked
      usageLength
      deliveryTimeline
      views
      createdAt
      lastUpdated
      delivery {
        id
        name
      }
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
      displayName
      reviewStats{
        noOfReviews
        rating
      }
      isVerified
      blueTickVerified
      isBusinessAccount
      profilePictureUrl
      thumbnailUrl 
               location {
                locationName
               }
    }
    }
  }
}
        ''', payload: {});

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final servicesList = right?['recentlyViewedServices'] as List<dynamic>?;
        //print("nkjwnefwejhwefw ${servicesList!.length}");
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getLikedServices() async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query likedServices {
  likedServices {
    id
    service {
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
      isDigitalContentCreator
      hasAdditional
      isOffer
      deliverablesType
      discount
      usageType
      likes
      faq
      saves
      shares
      userLiked
      usageLength
      deliveryTimeline
      views
      createdAt
      lastUpdated
      delivery {
        id
        name
      }
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
    }
  }
}
        ''', payload: {});

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final servicesList = right?['likedServices'] as List<dynamic>?;
        //print("nkjwnefwejhwefw ${servicesList!.length}");
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> allServices(
      {required String sort}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query AllServices(\$sort: SortEnum) {
  allServices(sort:\$sort) {
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
        "sort": sort,
      });

      final Either<CustomException, List<dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final servicesList = right?['allServices'] as List<dynamic>?;
        //print("nkjwnefwejhwefw ${servicesList!.length}");
        return Right(servicesList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getUserService(
      {required int serviceId, String? username}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
    query userService(\$serviceId: Int!, \$username: String) {
  userService(serviceId:\$serviceId, username: \$username) {
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
   ##meta
   isDigitalContentCreator
   hasAdditional
   discount
   deliverablesType
   usageType
   usageLength
   deliveryTimeline
   views
   createdAt
   lastUpdated
   user {
     id
     username
     displayName
   }
   delivery {
     id
     name
   }
  }
}
        ''', payload: {
        "serviceId": serviceId,
        "username": username,
      });

      final Either<CustomException, Map<String, dynamic>> servicesResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ${right?['userService'].runtimeType}");

        final servicesList = right?['userService'] as Map<String, dynamic>?;
        return Right(servicesList ?? {});
      });

      //print("''''''''''''''''''''''''''''''$servicesResponse");
      return servicesResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createService({
    required String period,
    required String title,
    required String serviceLocation,
    required String description,
    required String deliverablesType,
    required double price,
    required String deliveryTimeline,
    required bool isOffer,
    required ServiceType serviceType,
    required ServiceType serviceSubType,
    String? usageType,
    String? usageLength,
    required bool isDigitalContent,
    required bool hasAdditionalServices,
    int? percentDiscount,
    List? banner,
    double? initialDeposit,
    List? faqs,
    double? travelFee,
    String? travelPolicy,
    double? expressDeliveryPrice,
    String? expressDelivery,
    required List<ServiceTierModel> tiers,
  }) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation createService(\$period: String!,\$title: String!,
          \$serviceType: String!,\$serviceSubType: String!, \$description: String,\$price: Float!,
          \$deliveryTimeline: String!, \$usageType: String,\$usageLength: String,
          \$isDigitalContentCreator:Boolean!, \$hasAdditional:Boolean!, \$isOffer: Boolean!,
          \$discount: Int, \$initialDeposit: Int, \$bannerUrl: [BannerInputType], 
          \$faq: [FAQType], \$deliverablesType: ServiceDeliverablesTypeEnum!, \$serviceLocation: ServiceLocationEnum,
          \$travelFee: TravelFeeInputType, \$expressDelivery: ExpressDeliveryInputType,
          \$tiers: [PricingTierInputType],
          ) {
             createService(period: \$period,title: \$title, serviceType: \$serviceType, serviceSubType: \$serviceSubType
             description: \$description, price: \$price,deliveryTimeline: \$deliveryTimeline,
             usageType: \$usageType, usageLength: \$usageLength,
              isDigitalContentCreator: \$isDigitalContentCreator, isOffer: \$isOffer,
               hasAdditional: \$hasAdditional, discount: \$discount,
               initialDeposit: \$initialDeposit, bannerUrl: \$bannerUrl,
                faq: \$faq, deliverablesType: \$deliverablesType, serviceLocation: \$serviceLocation,
               travelFee: \$travelFee,, expressDelivery: \$expressDelivery, tiers: \$tiers
               ) {
             success
             message
             service {
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
              serviceLocation
              period
              price
              usageType
              usageLength
              #deleted
              deliveryTimeline
              createdAt
              deliverablesType
              lastUpdated
              isDigitalContentCreator
              hasAdditional
              views
              discount
              isOffer
              banner {
                url
                thumbnail
              }
              initialDeposit
              
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
          }

        ''', payload: {
        "title": title,
        "price": price,
        "serviceLocation": serviceLocation,
        "description": description,
        "deliveryTimeline": deliveryTimeline,
        "usageLength": usageLength,
        "usageType": usageType,
        "period": period,
        "isDigitalContentCreator": isDigitalContent,
        "hasAdditional": hasAdditionalServices,
        "isOffer": isOffer,
        "discount": percentDiscount ?? 0,
        "bannerUrl": banner,
        "initialDeposit": initialDeposit,
        "faq": faqs,
        "deliverablesType": deliverablesType,
        "serviceType": serviceType.name,
        "serviceSubType": serviceSubType.name,
        if (travelFee != null)
          "travelFee": {
            'price': travelFee,
            'travelPolicy': travelPolicy,
          },
        if (expressDeliveryPrice != null && expressDelivery != null)
          "expressDelivery": {
            'price': expressDeliveryPrice,
            "delivery": expressDelivery,
          },
        'tiers': tiers.map((x) => x.toJson(x)).toList(),
      });

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        logger.e(left.message);
        return Left(left);
      }, (right) {
        final parentMap = right?['createService'];
        final isSuccess = parentMap['success'] ?? false;
        if (isSuccess) {
          return Right(parentMap['service']);
        }
        return Right({});
      });

      return response;
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<ServiceType>>> allServiceTypes() async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
        query AllServiceTypes{
            allServiceTypes{
              id
              name
              subTypes{
                  id
                  name
                }
            }
        }
        ''',
        payload: {},
      );

      return result.fold((left) {
        return Left(left);
      }, (right) {
        logger.f(right!['allServiceTypes']);
        final result = (right['allServiceTypes'] as List)
            .map((e) => ServiceType.fromJson(e))
            .toList();

        return Right(result);
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> duplicate(
      {required Map<String, dynamic> data}) async {
    //print('duplicating a service');
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation createService(\$period: String!,\$title: String!,
          \$serviceType: String!, \$description: String,\$price: Float!,
          \$deliveryTimeline: String!, \$usageType: String,\$usageLength: String,
          \$isDigitalContentCreator:Boolean!, \$hasAdditional:Boolean!, \$isOffer: Boolean!,
          \$discount: Int, \$initialDeposit: Int, \$bannerUrl: [BannerInputType], 
         \$publish: Boolean, \$faq: [FAQType], \$deliverablesType: ServiceDeliverablesTypeEnum!) {
             createService(period: \$period,title: \$title, serviceType: \$serviceType,
             description: \$description, price: \$price,deliveryTimeline: \$deliveryTimeline,
             usageType: \$usageType, usageLength: \$usageLength,
              isDigitalContentCreator: \$isDigitalContentCreator, isOffer: \$isOffer,
               hasAdditional: \$hasAdditional, discount: \$discount,
               initialDeposit: \$initialDeposit, bannerUrl: \$bannerUrl,
               publish: \$publish, faq: \$faq, deliverablesType: \$deliverablesType,) {
             success
             message
             service {
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
    serviceLocation
              period
              price
              usageType
              usageLength
              #deleted
              deliveryTimeline
              createdAt
              lastUpdated
              deliverablesType
              isDigitalContentCreator
              hasAdditional
              views
              discount
              isOffer
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
          }

        ''', payload: data);

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        //print("leftttttttt ${left.message}");
        return Left(left);
      }, (right) {
        final parentMap = right?['createService'];
        final isSuccess = parentMap['success'] ?? false;
        if (isSuccess) {
          //print('[uu1] ${parentMap["service"]["user"]}');
          return Right(parentMap['service']);
        }
        //print('LLLLLLLLLLLLLLLLL got here');
        return Right({});
      });

      return response;
    } catch (e) {
      //print('failed to create service $e \n $st');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateService({
    required int serviceId,
    required String period,
    required String title,
    required String description,
    required String deliverablesType,
    required String serviceLocation,
    required double price,
    required String deliveryTimeline,
    String? usageType,
    String? usageLength,
    required bool isDigitalContent,
    required bool hasAdditionalServices,
    int? percentDiscount,
    int? initialDeposit,
    List? banner,
    List? faqs,
  }) async {
    //print('updating service with id $serviceId');
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''

          mutation updateService(\$serviceId:Int!, \$period: String!,\$title: String!,
          \$serviceLocation: String!, \$description: String,\$price: Float!,
          \$deliveryTimeline: String!, \$usageType: String,\$usageLength: String,
           \$isDigitalContentCreator:Boolean!, \$hasAdditional:Boolean!,
           \$discount: Int, \$initialDeposit: Int, \$bannerUrl: [BannerInputType],
            \$faq: [FAQType], \$deliverablesType: ServiceDeliverablesTypeEnum!, 
           ) {
             updateService(serviceId:\$serviceId, period: \$period,title: \$title, serviceLocation: \$serviceLocation,
             description: \$description, price: \$price,deliveryTimeline: \$deliveryTimeline,
             usageType: \$usageType, usageLength: \$usageLength,
              isDigitalContentCreator: \$isDigitalContentCreator,
               hasAdditional: \$hasAdditional, discount: \$discount,
               initialDeposit: \$initialDeposit, bannerUrl: \$bannerUrl,
                faq: \$faq, deliverablesType: \$deliverablesType,
               ) {
             success
             message
             service {
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
                serviceLocation
              period
              price
              deliverablesType
              usageType
              usageLength
              #deleted
              deliveryTimeline
              createdAt
              lastUpdated
              isDigitalContentCreator
              hasAdditional
              discount

              views
              banner {
                url
                thumbnail
              }
              initialDeposit
              isOffer
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
          }

        ''', payload: {
        "serviceId": serviceId,
        "title": title,
        "price": price,
        "description": description,
        "serviceLocation": serviceLocation,
        "deliveryTimeline": deliveryTimeline,
        "usageLength": usageLength,
        "usageType": usageType,
        "period": period,
        "isDigitalContentCreator": isDigitalContent,
        "hasAdditional": hasAdditionalServices,
        "discount": percentDiscount,
        "bannerUrl": banner,
        "initialDeposit": initialDeposit,
        "faq": faqs,
        "deliverablesType": deliverablesType,
      });

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) => Left(left), (right) {
        final parentMap = right?['updateService'];
        if (parentMap != null) {
          return Right(parentMap);
        }
        return Right({"message": "Something went wrong updating service"});
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> pauseService(
      int serviceId) async {
    //print(serviceId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation pauseService(\$serviceId: Int!) {
            pauseService(serviceId: \$serviceId) {
              success
            }
          }
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[pauseService] %%%%%%%%%%%%%%% $right');
        return Right(right!['pauseService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> resumeService(
      int serviceId) async {
    //print(serviceId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation resumeService(\$serviceId: Int!) {
            resumeService(serviceId: \$serviceId) {
              success
            }
          }
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[resumeService] %%%%%%%%%%%%%%% $right');
        return Right(right!['resumeService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> publishService(
      int serviceId) async {
    //print('publish a service');
    //print(serviceId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation publishService(\$serviceId: Int!) {
          publishService(serviceId:\$serviceId) {
            success
            }
          }
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[pd] %%%%%%%%%%%%%%% $right');
        return Right(right!['publishService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> deleteService(
      int serviceId) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation deleteService(\$serviceId: Int!) {
          deleteService(serviceId:\$serviceId) {
            success
            message
            }
          }
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        return Right(right!['deleteService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> likeService(
      int serviceId) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation likeService(\$serviceId: Int!) {
  likeService(serviceId: \$serviceId) {
    success
  }
}
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        return Right(right!['likeService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> saveService(
      int serviceId) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation saveService(\$serviceId: Int!) {
  saveService(serviceId: \$serviceId) {
    success
  }
}
        ''', payload: {
        "serviceId": serviceId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        return Right(right!['saveService']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getEarnings(
      {String? username}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: r'''
          query UserEarnings($username: String!) {
            userEarnings(username: $username) {
              earningsInMonth
              activeBookings{
                count
                value
              }
              expensesToDate
              completedJobsCount
              completedServicesCount
              completionRate{
                completionRate
                totalBookings
                completedBookings
              }
              jobsInProgress{
                count
                value
              }
              servicesInProgress{
                count
                value
              }
              totalEarnings{
                count
                value
              }
            }
          }
        ''', payload: {"username": username});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final earnings = right?['userEarnings'];
        return Right(earnings);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
