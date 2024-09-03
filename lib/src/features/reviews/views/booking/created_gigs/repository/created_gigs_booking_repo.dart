import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

class MyCreatedBookingsRepository {
  MyCreatedBookingsRepository._();
  static MyCreatedBookingsRepository instance = MyCreatedBookingsRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> userBookings({
    required int? pageCount,
    required int? pageNumber,
    String? module,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
        query UserBookings(\$module: BookingModuleEnum, \$pageNumber: Int, \$pageCount: Int, \$filters: BookingFiltersInput) {
          userBookings(module: \$module, pageNumber: \$pageNumber, pageCount: \$pageCount, filters: \$filters) {
            id
            title
            price
            pricingOption
            bookingType
            module
            moduleId
            userreviewSet{
              reviewText
              rating
              id
              reviewer{
                profilePictureUrl
                username
              }
              reviewed{
                profilePictureUrl
                username
              }
              createdAt
            }
            moduleUser {
              id
              username
              profilePictureUrl
              lastName
              firstName
              label
              profileRing
              reviewStats{
               noOfReviews
               rating
              }
            location {
                latitude
                longitude
                locationName
              }
            }
            status
            address
            haveBrief
            deliverableType
            expectDigitalContent
            usageType {
              id
              name
            }
            usageLength {
              id
              name
            }
            brief
            briefFile
            briefLink
            startDate
            dateDelivered
            completionDate
            dateCreated
            lastUpdated
            deleted
            user{
              id
              username
              profilePictureUrl
              lastName
              firstName
              profileRing
             reviewStats{
                noOfReviews
                rating
              }
            }
            paymentSet {
              id
              amount
              paymentRef
              status
            }
          }
          iBookedTotalNumber
        }

        ''', payload: {
        "module": module,
        "pageCount": pageCount,
        "pageNumber": pageNumber,
        "filters": {
          "booker": filters?['booker'],
          "bookie": filters?['bookie'],
          "status": filters?['status'],
          "title": filters?['title']
        }
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e, s) {
      logger.e(s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> pendingPaymentBooking({
    required int? pageCount,
    required int? pageNumber,
    String? module,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
        query UserPendingBookings(\$module: BookingModuleEnum, \$pageNumber: Int, \$pageCount: Int) {
          userPendingBookings(module: \$module, pageNumber: \$pageNumber, pageCount: \$pageCount) {
            id
            title
            price
            pricingOption
            bookingType
            module
            moduleId
            userreviewSet{
              reviewText
              rating
              id
              reviewer{
                profilePictureUrl
                username
              }
              reviewed{
                profilePictureUrl
                username
              }
              createdAt
            }
            moduleUser {
              id
              username
              profilePictureUrl
              lastName
              firstName
              label
              profileRing
              reviewStats{
               noOfReviews
               rating
              }
            location {
                latitude
                longitude
                locationName
              }
            }
            status
            address
            haveBrief
            deliverableType
            expectDigitalContent
            usageType {
              id
              name
            }
            usageLength {
              id
              name
            }
            brief
            briefFile
            briefLink
            startDate
            dateDelivered
            completionDate
            dateCreated
            lastUpdated
            deleted
            user{
              id
              username
              profilePictureUrl
              lastName
              firstName
              profileRing
             reviewStats{
                noOfReviews
                rating
              }
            }
            paymentSet {
              id
              amount
              paymentRef
              status
            }
          }
          iBookedTotalNumber
        }

        ''', payload: {
        "module": module,
        "pageCount": pageCount,
        "pageNumber": pageNumber,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e, s) {
      logger.e(s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createBooking(
      {required Map<String, dynamic> bookingData}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''

      mutation CreateBooking(\$bookingData: BookingInput!) {
        createBooking(bookingData: \$bookingData) {
          booking {
            id
            title
          }
        }
      }

        ''', payload: {
        "bookingData": bookingData,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createPayment(
      {required int bookingId}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation createPayment (\$bookingId: Int!) {
              createPayment(bookingId: \$bookingId) {
                paymentLink
                paymentRef
              }
            }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createPayment']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> confirmPayment(
      {required String paymentRef}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation confirmPayment(\$paymentRef: String!) {
              confirmPayment(paymentRef: \$paymentRef) {
                paymentStatus
              }
            }
        ''', payload: {
        "paymentRef": paymentRef,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['confirmPayment']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> bookerCompleteBooking(
      {required int bookingId}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation BookerCompleteBooking(\$bookingId: Int!) {
            bookerCompleteBooking(bookingId: \$bookingId) {
              message
            }
          }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['bookerCompleteBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> reviewBookedUser(
      {required int bookingId, required String rating, String? review}) async {
    logger.d('Booking Id: $bookingId');
    try {
      final result = await vBaseServiceInstance.mutationQuery(
          mutationDocument: '''
          mutation ReviewMyBookie(\$bookingId: Int!,\$rating: RatingsEnum!, \$reviewText: String!) {
            bookerReview(bookingId: \$bookingId, rating: \$rating, reviewText: \$reviewText) {
              message
          }
      }
        ''',
          payload: {
            "bookingId": bookingId,
            "rating": rating,
            "reviewText": review
          });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['bookerReview']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> reviewBookingCreator(
      {required int bookingId, required String rating, String? review}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(
          mutationDocument: '''
         mutation ReviewMyBooker(\$bookingId: Int!, \$reviewText: String!, \$rating: RatingsEnum!) {
           bookieReview(bookingId: \$bookingId, reviewText: \$reviewText, rating: \$rating) {
              message
          }
        }
        ''',
          payload: {
            "bookingId": bookingId,
            "rating": rating,
            "reviewText": review
          });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['bookieReview']);
      });
    } catch (e, s) {
      logger.e(s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getBookingsJob(
      {int? pageCount,
      int? pageNumber,
      String? filterBy,
      String? username,
      bool isRequested = false}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
          query UserJobs(\$pageCount: Int, \$pageNumber: Int, \$filterBy: String, \$username: String,\$isRequested: Boolean) {
            userJobs(pageCount: \$pageCount, pageNumber: \$pageNumber, filterBy: \$filterBy, username: \$username,isRequested: \$isRequested) {
              id
              createdAt
              jobTitle
              jobType
              priceOption
              priceValue
              preferredGender
              shortDescription
              category{
                id
                name
                subTypes{
                  id
                  name
                }
              }
               subCategory{
                  id
                  name
                }
              paused
              closed
              processing
              status
              status
              brief
              briefLink
              briefFile
              noOfApplicants
              deliverablesType
              jobDelivery {
                date
                startTime
                endTime
              }
              ethnicity
              talentHeight{
                value
                unit
              }
              size
              skinComplexion
              minAge
              maxAge
              isDigitalContent
              talents
              jobLocation {
                latitude
                longitude
                streetAddress
                county
                city
                country
                postalCode
              }
              usageType {
                id
                name
              }
              usageLength {
                id
                name
              }
              creator {
                id
                username
                displayName
                profileRing
                #bio
                reviewStats{
                    noOfReviews
                    rating
                  }
                location {
                  latitude
                  longitude
                  locationName
                }
                profilePictureUrl
                thumbnailUrl
                isBusinessAccount
                userType
                label
              }
              bookings {
                id
                title
                price
                pricingOption
                bookingType
                module
                moduleId
                userreviewSet{
                  reviewText
                  rating
                  id
                  reviewer{
                    profilePictureUrl
                    username
                  }
                  reviewed{
                    profilePictureUrl
                    username
                  }
                  createdAt
                }
                moduleUser {
                  id
                  username
                  profilePictureUrl
                  lastName
                  firstName
                  label
                  profileRing
                  reviewStats{
                    noOfReviews
                    rating
                  }
                location {
                    latitude
                    longitude
                    locationName
                  }
                }
                status
                address
                haveBrief
                deliverableType
                expectDigitalContent
                usageType {
                  id
                  name
                }
                usageLength {
                  id
                  name
                }
                brief
                briefFile
                briefLink
                startDate
                dateDelivered
                completionDate
                dateCreated
                lastUpdated
                deleted
                user{
                  id
                  username
                  profileRing
                  profilePictureUrl
                  lastName
                  firstName
                  reviewStats{
                    noOfReviews
                    rating
                  }
                }
                paymentSet {
                  id
                  amount
                  paymentRef
                  status
                }
              }
            }
            jobsTotalNumber
          }

        ''', payload: {
        "username": username,
        "pageCount": pageCount,
        "pageNumber": pageNumber,
        "filterBy": filterBy,
        'isRequested': isRequested
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

  Future<Either<CustomException, Map<String, dynamic>>> getBookingsChats({
    int? bookingId,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
          query BookingConversation(\$bookingId: ID!) {
            bookingConversation(bookingId: \$bookingId) {
              id
              sender{
                id
                username
                displayName
                profilePictureUrl
                thumbnailUrl
              }
              text
              attachment
              attachmentType
              conversation{
                id
                name
                participant1{
                id
                username
                displayName
                profilePictureUrl
                thumbnailUrl
              }
                participant2{
                id
                username
                displayName
                profilePictureUrl
                thumbnailUrl
              }
                recipient{
                id
                username
                displayName
                profilePictureUrl
                thumbnailUrl
              }
              }
              createdAt
              read
              deleted
              senderName
              receiverProfile
            
            }
          }

        ''', payload: {"bookingId": bookingId});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getBookingsService({
    int? pageCount,
    int? pageNumber,
    String? filterBy,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
          query UserServices(\$pageCount: Int, \$pageNumber: Int, \$filterBy: String,) {
              userServices(pageCount: \$pageCount, pageNumber: \$pageNumber, filterBy: \$filterBy,){
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
                    label
                    profileRing
                    reviewStats{
                      noOfReviews
                      rating
                    }
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
                  bookings {
                    id
                    title
                    price
                    pricingOption
                    bookingType
                    module
                    moduleId
                    userreviewSet{
                      reviewText
                      rating
                      id
                      reviewer{
                        profilePictureUrl
                        username
                      }
                      reviewed{
                        profilePictureUrl
                        username
                      }
                      createdAt
                    }
                    moduleUser {
                      id
                      username
                      profilePictureUrl
                      lastName
                      firstName
                      label
                      profileRing
                      reviewStats{
                      noOfReviews
                      rating
                      }
                    location {
                        latitude
                        longitude
                        locationName
                      }
                    }
                    status
                    address
                    haveBrief
                    deliverableType
                    expectDigitalContent
                    usageType {
                      id
                      name
                    }
                    usageLength {
                      id
                      name
                    }
                    brief
                    briefFile
                    briefLink
                    startDate
                    dateDelivered
                    completionDate
                    dateCreated
                    lastUpdated
                    deleted
                    user{
                      id
                      username
                      profilePictureUrl
                      lastName
                      firstName
                      label
                      profileRing
                    reviewStats{
                        noOfReviews
                        rating
                      }
                    }
                    paymentSet {
                      id
                      amount
                      paymentRef
                      status
                    }
              }
                }
                allServicesTotalNumber
              }

        ''', payload: {
        "pageCount": pageCount,
        "pageNumber": pageNumber,
        "filterBy": filterBy,
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
}
