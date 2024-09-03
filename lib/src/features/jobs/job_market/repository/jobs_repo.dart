import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

class JobsRepository {
  JobsRepository._();
  static JobsRepository instance = JobsRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> getJobs({
    bool? myJobs,
    bool? popular,
    String? search,
    String? category,
    String? username,
    int? pageCount,
    int? pageNumber,
    String? remote,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query getJobs(
      \$myJobs: Boolean,
      \$search: String,
      \$category: String,
      \$pageCount: Int,
      \$pageNumber: Int,
      \$username: String,
      \$remote: String,
      \$popular: Boolean,
){
  jobs(
    myJobs: \$myJobs,
    search: \$search,
    category: \$category,
    popular: \$popular,
    pageCount: \$pageCount,
    pageNumber: \$pageNumber,
    username: \$username,
    remote: \$remote,
  ) {
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
      #firstName
      #lastName
      displayName
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
      profileRing
    }
  }
  jobsTotalNumber
}

        ''', payload: {
        'myJobs': myJobs,
        'search': search,
        'category': category,
        'pageCount': pageCount,
        'pageNumber': pageNumber,
        'username': username,
        'remote': remote,
        'popular': popular,
      });

      return result.fold((left) {
        logger.e(left.message);
        return Left(left);
      }, (right) {
        logger.d(right);
        return Right(right!);
      });
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getJob(
      {required int jobId}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
        query getJob(\$jobId: Int!) {
  job(jobId: \$jobId){
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
  }
      }
        ''', payload: {
        "jobId": jobId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['job']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> applyToJob({
    required int jobId,
    required double proposedPrice,
    String coverMessage = "",
  }) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''

mutation applyToJob(\$jobId:Int!, \$proposedPrice: Float!, \$coverMessage: String) {
  applyToJob(jobId: \$jobId, proposedPrice: \$proposedPrice, coverMessage: \$coverMessage) {
    message
    application {
      id
      proposedPrice
      accepted
      coverMessage
      rejected
      job {
       id
        jobTitle
      }
      applicant {
        username
      }
    }
  }
}

        ''', payload: {
        "jobId": jobId,
        "proposedPrice": proposedPrice,
        "coverMessage": coverMessage,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        logger.d(right);
        return Right(right!['applyToJob']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getPopularJobs({
    required int dataCount,
    required String? category,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query popularJobsByCategory(\$dataCount: Int!, \$jobCategory: String) {
  explore(dataCount: \$dataCount, jobCategory: \$jobCategory) {
  popularJobs {
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
          profileRing
          #lastName
          displayName
          #bio
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
      }

    }
  }

        ''', payload: {
        "dataCount": dataCount,
        "jobCategory": category,
      });

      return result.fold((left) {
        print("Fortuna ${left.message}");
        return Left(left);
      }, (right) {
        print("Fortuna ${right}");

        return Right(right!['explore']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getRecommendedJobs({
    required int dataCount,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query recommendedJobs(\$dataCount: Int!) {
  explore(dataCount: \$dataCount){
  recommendedJobs {
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
      }

       popularServices {
        id
        title
        description
        serviceType{
      id
      name
      subType
    }
    serviceLocation
        period
        price
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
        isDigitalContentCreator
        hasAdditional
        discount
        usageType
        usageLength      
        deliveryTimeline
        views
        createdAt
        lastUpdated
    banner {
      url
      thumbnail
    }
    initialDeposit
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
    processing
    status
        user {
          id
          username
          profilePictureUrl
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
        return Right(right!['explore']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getSimilarJobs({
    required int jobId,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query similarJobs(\$jobId: Int!) {
  similarJobs(jobId: \$jobId){
 
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
          profileRing
          username
          #firstName
          #lastName
          displayName
          #bio
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
      }
    }

        ''', payload: {"jobId": jobId});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final List<dynamic> list = right!['similarJobs'];
        return Right(list);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getRecentlyViewedJobs() async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
query recentlyViewedJobs {
  recentlyViewedJobs {
    job {
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
      deliverablesType
      jobDelivery {
        date
        startTime
        endTime
      }
      ethnicity
      talentHeight {
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
        displayName
        profileRing
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
    }
  }
}

        ''',
        payload: {},
      );

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final List<dynamic> list = right!['recentlyViewedJobs'];
        return Right(list);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> userHasJob(
      {required String username}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
     mutation (\$username: String!){
      getIfUsernameCreatedJob(username: \$username) {
        message
        createdJob
      }
    }
        ''', payload: {"username": username});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['getIfUsernameCreatedJob']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getJobApplications(
    int jobId,
    String status,
    int pageCount,
    int currentPage,
  ) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query jobApplications(\$jobId: Int!, \$status: ApplicationStatusEnum, \$pageCount: Int, \$pageNumber: Int) {
  jobApplications(jobId: \$jobId, status: \$status, pageCount: \$pageCount, pageNumber: \$pageNumber) {
    id
    coverMessage
    proposedPrice
    accepted
    rejected
    deleted
    dateCreated
    job {
      id
    }
    applicant {
      id
      username
      displayName
      profilePictureUrl
      thumbnailUrl
      email
      label
      isVerified
      blueTickVerified
      bio
      profileRing
      responseTime
      location {
        latitude
        longitude
        locationName
      }
      reviewStats{
      noOfReviews
      rating
    }
    }
  }
  jobApplicationsTotalNumber
}

        ''', payload: {
        "jobId": jobId,
        "status": status ?? "ALL",
        "pageCount": pageCount,
        "pageNumber": currentPage,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final applicantsList = right?['jobApplications'] as List<dynamic>?;
        final jobApplicationsTotalNumber =
            int.parse("${right?['jobApplicationsTotalNumber'] ?? 0}");
        return Right([applicantsList ?? [], jobApplicationsTotalNumber]);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> acceptApplicationOffer({
    required int applicationId,
    required bool acceptApplication,
    required bool rejectApplication,
  }) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
mutation acceptApplication(\$applicationId: Int!, \$acceptApplication: Boolean, \$rejectApplication: Boolean) {
  acceptOrRejectApplication(applicationId: \$applicationId, acceptApplication: \$acceptApplication, rejectApplication: \$rejectApplication) {
    message
    application {
      id
      proposedPrice
      accepted
      rejected
      deleted
      dateCreated
      job {
        id
      }
      applicant {
        id
        username
        fullName
        profilePictureUrl
        email
        label
        isVerified
        bio
        profileRing
      }
    }
  }
}
        ''', payload: {
        "applicationId": applicationId,
        "acceptApplication": acceptApplication,
        "rejectApplication": rejectApplication
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

  Future<Either<CustomException, Map<String, dynamic>>> pauseJob(
      int jobId) async {
    //print(jobId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation pauseJob(\$jobId: Int!) {
            pauseJob(jobId: \$jobId) {
              success
            }
          }
        ''', payload: {
        "jobId": jobId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[pauseJob] %%%%%%%%%%%%%%% $right');
        return Right(right!['pauseJob']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> resumeJob(
      int jobId) async {
    //print(jobId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation resumeJob(\$jobId: Int!) {
            resumeJob(jobId: \$jobId) {
              success
            }
          }
        ''', payload: {
        "jobId": jobId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[resumeJob] %%%%%%%%%%%%%%% $right');
        return Right(right!['resumeJob']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> closeJob(
      int jobId) async {
    //print(jobId);
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation closeJob(\$jobId: Int!) {
            closeJob(jobId: \$jobId) {
              success
            }
          }
        ''', payload: {
        "jobId": jobId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) => Left(left), (right) {
        //print('[closeJob] %%%%%%%%%%%%%%% $right');
        return Right(right!['closeJob']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> saveJob(
      int jobId) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation saveJob(\$jobId: Int!) {
  saveJob(jobId: \$jobId) {
    success
  }
}
        ''', payload: {
        "jobId": jobId,
      });

      final Either<CustomException, Map<String, dynamic>> userName =
          result.fold((left) {
        return Left(left);
      }, (right) {
        //print('[pd] %%%%%%%%%%%%%%% $right');
        return Right(right!['saveJob']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
