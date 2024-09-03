import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

class MyApplicationsRepository {
  MyApplicationsRepository._();
  static MyApplicationsRepository instance = MyApplicationsRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> getMyApplications({
    int? pageCount,
    int? pageNumber,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query userApplications(
  \$pageNumber: Int!,
  
  \$pageCount: Int!,
	
	){
  userApplications(
   pageNumber:\$pageNumber,
    pageCount: \$pageCount
  ){
    id,
    dateCreated,
    job{
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
     brief
     briefLink
     briefFile
     saves
     userSaved
     deliverablesType
     requests{
        id
        status
        createdAt
        updatedAt
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
        bannerUrl
        location
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
     acceptMultiple
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
       #firstName
       #lastName
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
     applications {
      id
      proposedPrice
      accepted
      rejected
      coverMessage
      applicant {
        id
        username
        displayName
        label
        profileRing
        responseTime
         reviewStats{
          noOfReviews
          rating
        }
         location {
          latitude
          longitude
          locationName
        }
        isVerified
        blueTickVerified
        profilePictureUrl
        thumbnailUrl
      }
    }
    },
    proposedPrice,
    accepted,
    rejected,
    deleted,
   
  }
}
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });

      return result.fold((left) {
        logger.e(left.message);
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }
}



//       maxAge,
//       talents,
//       talentHeight{
//         value,
//         unit,
//       },
//       jobDelivery{
//         date,
//         startTime,
//         endTime,
//       },
//       jobLocation{
//         latitude,
//         longitude,
//         locationName
//       }
//     },
//     proposedPrice,
//     accepted,
//     rejected,
//     deleted,
//   }
// }