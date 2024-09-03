import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/requests/model/request_model.dart';

final requestRepoProvider = Provider((ref) => RequestRepo());

class RequestRepo {
  Future<Either<CustomException, List<RequestModel>>> myRequests() async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
       query UserRequests {
    userRequests {
        id
        status
        createdAt
        updatedAt
           job {
            id
            jobTitle
            jobType
            priceOption
            priceValue
            preferredGender
            shortDescription
            briefFile
            brief
            briefLink
            deliverablesType
            isDigitalContent
            deliveryType
            ethnicity
            isRequest
            size
            skinComplexion
            createdAt
            deleted
            views
            acceptMultiple
            closed
            paused
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
            status
            approved
            rejected
            saves
            expired
            minAge
            maxAge
            talents
            processing
            userSaved
            noOfApplicants
            creator {
                id
                firstName
                lastName
                username
                userType
                label
                email
                bio
                profilePicture
                profilePictureUrl
                profileRing         
            }
            usageType {
                id
                name
                addedBy
            }
            usageLength {
                id
                name
                addedBy
            }
            jobLocation {
              latitude
              longitude
              streetAddress
              county
              city
              country
              postalCode
            }
            jobDelivery {
                date
                startTime
                endTime
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
        bannerUrl
        location
        requestedBy {
           id
            firstName
            lastName
            username
            userType
            label
            email
            bio
            profilePicture
            profilePictureUrl
            profileRing 
        }

        requestedTo {
            id
            firstName
            lastName
            username
            userType
            label
            email
            bio
            profilePicture
            profilePictureUrl
            profileRing           
        }
    }
}
        ''',
        payload: {},
      );

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final res = right!['userRequests'] as List;
        logger.f(res);

        return Right(res.map((e) => RequestModel.fromJson(e)).toList());
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, bool>> acceptOrDeclineRequest({
    required bool accept,
    required dynamic requestId,
  }) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
       mutation AcceptOrRejectJobRequest(\$jobRequestId: Int!,\$accept: Boolean!){
        acceptRejectJobRequest(jobRequestId: \$jobRequestId, accept:\$accept){
          success
        }
      }
        ''',
        payload: {
          "accept": accept,
          "jobRequestId": requestId,
        },
      );

      return result.fold((left) {
        return Left(left);
      }, (right) {
        logger.d(right);
        return Right(right!['acceptRejectJobRequest']['success']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
