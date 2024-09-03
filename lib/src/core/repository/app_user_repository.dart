import 'package:either_option/either_option.dart';
import 'package:vmodel/src/core/models/location_model.dart';
import 'package:vmodel/src/core/models/notification_preference_model.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../app_locator.dart';
import '../utils/exception_handler.dart';

class AppUserRepository {
  AppUserRepository._();

  //For debugging purposes only
  final _TAG = 'AppUserRepository';

  static AppUserRepository instance = AppUserRepository._();

  Future<Either<CustomException, Map<String, dynamic>>>
      getNotificationSettings() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      
query GetNotificationPreferences{
  notificationPreference {
    isPushNotification
    isEmailNotification
    inappNotifications
    emailNotifications
  }
}
        ''', payload: {});

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        final notificationSettings = right!['notificationPreference'];
        // debugPrint(
        //     // "Fortune graph ${right!['notificationPreference']["inappNotifications"]}");
        //     "Fortune graph ${right!['notificationPreference']}");

        return Right(notificationSettings);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getMe() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      
query{
  viewMe{
    id
    dob
    profileRing
    email
    username
    firstName
    lastName
    displayName
    bio
    interests
    zodiacSign
    displayStarSign
    connectionStatus
    allowConnectionView
    connectionId
    gender
    alertOnProfileVisit
    whoCanMessageMe
    whoCanFeatureMe
    whoCanViewMyNetwork
    whoCanConnectWithMe
    isVerified
    blueTickVerified
    dateJoined
    lastLogin
    responseTime
    meta
    businessaddress{
      city
      country
      county
      postalCode
      latitude
      longitude
      streetAddress
    }
    profilePercentage {
     percentage
     completedFields
     uncompletedFields
    }
    reviewStats{
      noOfReviews
      rating
      reviews {
           id
          rating
          reviewText
          reviewer {
            profilePictureUrl
            userType
            username
            profileRing
          }
          reviewed{
            username
            userType
            profilePictureUrl
            profileRing
          }
          reviewReply{
            replyText
            id
            createdAt
          }
          createdAt
                  
      }
    }
    phone {
      countryCode
      number
      completed
    }
    height {
      value
      unit
    }
    location{
      latitude
      longitude
      locationName
    }
    website
    price
    postcode
    gender
    ethnicity
    size
    hair
    eyes
    profilePictureUrl
    thumbnailUrl
    isBusinessAccount
    userType
    label
    isFollowing
    trait
    personality
    yearsOfExperience
     waist{
      value
      unit
    }
    height{
      value
      unit
    }
    bust{
      value
      unit
    }
    feet{
      value
      unit
    }
    chest{
      value
      unit
    }
    socials {
     facebook {
      username
      noOfFollows
     }
     instagram {
      username
      noOfFollows
     }
     twitter {
      username
      noOfFollows
     }
     tiktok {
      username
      noOfFollows
     }
     pinterest {
      username
      noOfFollows
     }
     youtube {
      username
      noOfFollows
     }
    }
  }
}
        ''', payload: {});

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        final profile = right!['viewMe'];

        return Right(profile);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getAppUserInfo(
      {required String username, required bool notify}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      
  query getUser(\$username: String!, \$notify: Boolean){
  getUser(username:\$username, notify: \$notify){
    username
    id
    email
    bio
    interests
    profileRing
    zodiacSign
    personality
    connectionStatus
    allowConnectionView
    connectionId
    gender
    dob
    userType
    isVerified
    postNotification
    jobNotification
    couponNotification
    blueTickVerified
    responseTime
    meta
    businessaddress{
      city
      country
      county
      postalCode
      latitude
      longitude
      streetAddress
    }
    height {
      value
      unit
    }
    location{
      locationName
    }
    website
    price

    reviewStats{
      noOfReviews
      rating
      reviews {
           id
          rating
          reviewText
          reviewer {
            profilePictureUrl
            userType
            username
            profileRing
          }
          reviewed{
            username
            userType
            profilePictureUrl
            profileRing
          }
          reviewReply{
            replyText
            id
            createdAt
          }
          createdAt
                  
      }
    }
    profilePercentage {
     percentage
     completedFields
     uncompletedFields
    }
    postcode
    gender
    ethnicity
    size
    firstName
    lastName
    displayName
    hair
    eyes
    thumbnailUrl
    profilePictureUrl
    isBusinessAccount
    userType
    label
    isFollowing
    yearsOfExperience
      waist{
      value
      unit
    }
    height{
      value
      unit
    }
    bust{
      value
      unit
    }
    feet{
      value
      unit
    }
    chest{
      value
      unit
    }
    socials {
     facebook {
      username
      noOfFollows
     }
     instagram {
      username
      noOfFollows
     }
     twitter {
      username
      noOfFollows
     }
     tiktok {
      username
      noOfFollows
     }
     pinterest {
      username
      noOfFollows
     }
     youtube {
      username
      noOfFollows
     }
    }
  
  }
}
        ''', payload: {
        'username': username,
        'notify': notify,
      });

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        final profile = right!['getUser'];
        return Right(profile);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateProfile({
    // int? id,
    bool? allowConnectionView,
    String? firstName,
    String? lastName,
    String? displayName,
    String? label,
    String? trait,
    String? personality,
    String? bio,
    List<String>? interests,
    String? website,
    String? dob,
    String? hair,
    String? eyes,
    Map<String, dynamic>? phone,
    Map<String, dynamic>? chest,
    Map<String, dynamic>? bust,
    Map<String, dynamic>? waist,
    Map<String, dynamic>? feet,
    Map<String, dynamic>? height,
    String? gender,
    String? locationName,
    String? modelSize,
    String? ethnicity,
    String? profilePictureUrl,
    String? thumbnailUrl,
    int? yearsOfExperience,
    String? profileRing,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
           mutation updateProfile(
            \$allowConnectionView: Boolean,
      \$bio: String,
      \$interests: [String],
      \$country: String,
      \$ethnicity: String,
      \$eyes: String,
      \$firstName: String,
      \$gender: String,
      \$hair: String,
      \$lastName: String,
      \$phoneNumber: PhoneInputType,
      \$postcode: String,
      \$dob: Date,
      \$price: String,
      \$size: String,
      \$displayName: String,
      \$label: String,
      \$trait: String,
      \$personality: String,
      \$website: String,
      \$profilePictureUrl: String,
      \$thumbnailUrl: String,
      \$yearsOfExperience: Int,

      \$bust: BustInputType,
      \$height: UserHeightInputType,
      \$chest: ChestInputType,
      \$feet: FeetInputType,
      \$waist: WaistInputType,
      \$profileRing:ProfileRingChoicesEnum!
       ) {
  updateProfile(
    allowConnectionView: \$allowConnectionView
      bio: \$bio,
      interests: \$interests,
      country: \$country,
      ethnicity: \$ethnicity,
      eyes: \$eyes,
      firstName: \$firstName,
      gender: \$gender,
      hair: \$hair,
      dob: \$dob,
      lastName: \$lastName,
      displayName: \$displayName,
      phoneNumber: \$phoneNumber,
      postcode: \$postcode,
      price: \$price,
      size: \$size,
      label: \$label,
      trait: \$trait,
      personality: \$personality,
      website: \$website,
      profilePictureUrl: \$profilePictureUrl,
      thumbnailUrl: \$thumbnailUrl,
      yearsOfExperience: \$yearsOfExperience,
      bust: \$bust
      height: \$height
      chest: \$chest
      feet: \$feet
      waist: \$waist
      profileRing: \$profileRing
  ) {
    user {
      id
      username
      lastName
      firstName
      displayName
      bio
      interests
      country
      profileRing
      allowConnectionView
      email
      ethnicity
      eyes
      dob
      gender
      hair
      trait
      personality
       waist{
      value
      unit
    }
    height{
      value
      unit
    }
    bust{
      value
      unit
    }
    feet{
      value
      unit
    }
    chest{
      value
      unit
    }
      phone {
        countryCode
        number
        completed
      }
      postcode
      price
      size
      website
      isActive
      thumbnailUrl
      profilePictureUrl
      isBusinessAccount
      userType
      label
      isFollowing
      yearsOfExperience
    }
  }
}
        ''', payload: {
        // 'id': id ,
        // 'profilePictureUrl': profilePictureUrl,
        'allowConnectionView': allowConnectionView,
        'bio': bio,
        'interests': interests,
        'website': website,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'label': label,
        'hair': hair,
        'eyes': eyes,
        'dob': dob,
        'phoneNumber': phone,
        'gender': gender,
        'ethnicity': ethnicity,
        'size': modelSize,
        'trait': trait,
        'personality': personality,
        'profilePictureUrl': profilePictureUrl,
        'thumbnailUrl': thumbnailUrl,
        'yearsOfExperience': yearsOfExperience,

        'height': height,
        'chest': chest,
        'feet': feet,

        'waist': waist,
        'bust': bust,
        'profileRing': profileRing,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold((left) => Left(left),
              (right) => Right(right!['updateProfile']['user']));
      return result;
    } catch (e) {
      _tagPrint('Error updating profile picture in  ===> $e');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateFCMToken({
    required String fcmToken,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
             mutation updateFCMToken(\$fcmToken: String!) {
             updateFcmToken(fcmToken:\$fcmToken) {
                success
               }
              }

        ''', payload: {
        'fcmToken': fcmToken,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold(
              (left) => Left(left), (right) => Right(right!['updateFcmToken']));
      return result;
    } catch (e) {
      _tagPrint('Error updating FCM  ===> $e');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateUsername({
    String? username,
    // String? email,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation updateProfile(\$username: String) {
              updateProfile(username: \$username) {
                message
                token
                user {
                  id
                  username
                }
              }
            }
        ''', payload: {
        'username': username,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold(
              (left) => Left(left), (right) => Right(right!['updateProfile']));
      return result;
    } catch (e) {
      _tagPrint('Error updating profile picture in  ===> $e');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createBusinessAddress({
    required LocationData address,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: r'''
            mutation CreateBusinessAddress($city: String!, $country: String!, $county: String!, $latitude: Float!, $longitude: Float!, $postalCode: String!, $streetAddress: String!) {
              createBusinessAddress(city: $city, country: $country, county: $county, latitude: $latitude, longitude: $longitude, postalCode: $postalCode, streetAddress: $streetAddress) {
                success
              }
            }
        ''', payload: {
        'city': address.city,
        'country': address.country,
        'county': address.county,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'postalCode': address.postalCode,
        'streetAddress': address.streetAddress,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold((left) => Left(left),
              (right) => Right(right!['createBusinessAddress']));
      return result;
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateBusinessAddress({
    required LocationData address,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: r'''
            mutation UpdateBusinessAddress($city: String, $country: String, $county: String, $latitude: Float, $longitude: Float, $postalCode: String, $streetAddress: String) {
              updateBusinessAddress(city: $city, country: $country, county: $county, latitude: $latitude, longitude: $longitude, postalCode: $postalCode, streetAddress: $streetAddress) {
                success
              }
            }
        ''', payload: {
        'city': address.city,
        'country': address.country,
        'county': address.county,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'postalCode': address.postalCode,
        'streetAddress': address.streetAddress,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold((left) => Left(left),
              (right) => Right(right!['updateBusinessAddress']));
      return result;
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updatePrivacy(
      payload) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
            mutation PrivacySettings(\$ethnicity: Boolean!, \$location: Boolean!, \$personality: Boolean!, \$pronoun: Boolean, \$specialty: Boolean, \$starSign: Boolean, \$traits: Boolean) {
              updatePrivacySettings(ethnicity: \$ethnicity, location: \$location, personality: \$personality, pronoun: \$pronoun, specialty: \$specialty, starSign: \$starSign, traits: \$traits) {
                success
              }
            }''',
        payload: payload,
      );
      final Either<CustomException, Map<String, dynamic>> getReportResult =
          result.fold(
        (left) {
          return Left(left);
        },
        (right) {
          return Right(right ?? {});
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>>
      updateNotificationPreference(Map<String, dynamic> payload) async {
    NotificationPreference notificationPreference =
        NotificationPreference.fromJson2(payload);
    print(
        "ADE1 first touch ${notificationPreference.emailNotifications.toJson()}");

    try {
      final result = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
            mutation updateNotificationPreference(
             \$isPushNotification: Boolean!,
             \$isEmailNotification: Boolean!,
              \$isSilentModeOn: Boolean!,
              \$inappNotifications: NotificationsPreferenceInputType, 
              \$emailNotifications: NotificationsPreferenceInputType
              ) {
                updateNotificationPreference(
                isPushNotification: \$isPushNotification 
                isEmailNotification: \$isEmailNotification 
                isSilentModeOn: \$isSilentModeOn
                emailNotifications: \$emailNotifications
                inappNotifications: \$inappNotifications
                ) {
                success
                  notificationPreference {
                    isPushNotification
                    inappNotifications
                    emailNotifications
                    isEmailNotification
                  }
                }
}''',
        payload: {
          "isPushNotification": notificationPreference.isPushNotification,
          "isEmailNotification": notificationPreference.isEmailNotification,
          "isSilentModeOn": notificationPreference.isSilentModeOn,
          "inappNotifications": notificationPreference.inappNotifications,
          "emailNotifications": notificationPreference.emailNotifications
        },
      );
      final Either<CustomException, Map<String, dynamic>> getReportResult =
          result.fold(
        (left) {
          return Left(left);
        },
        (right) {
          return Right(right ?? {});
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateNotification({
    bool? alertProfileVisit,
    // String? email,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation updateProfile(\$alertOnProfileVisit: Boolean) {
              updateProfile(alertOnProfileVisit: \$alertOnProfileVisit) {
                message
                token
                user {
                  alertOnProfileVisit
                }
              }
            }
        ''', payload: {
        'alertOnProfileVisit': alertProfileVisit,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold((left) {
        return Left(left);
      }, (right) => Right(right!['updateProfile']));
      return result;
    } catch (e) {
      _tagPrint('Error updating profile picture in  ===> $e');
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateUserSocials({
    String? facebook,
    String? instagram,
    String? tiktok,
    String? pinterest,
    String? youtube,
    String? twitter,
    String? linkedin,
    String? patreon,
    String? reddit,
    String? snapchat,
    int? facebookFollows,
    int? instaFollows,
    int? twitterFollows,
    int? youtubeSubs,
    int? tiktokFollows,
    int? pinterestFollows,
    int? linkedinFollows,
    int? patreonFollows,
    int? redditFollows,
    int? snapchatFollows,
  }) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
mutation updateUserSocials(
  \$facebook: String, \$facebookFollows: Int, \$instagram: String,
  \$instaFollows: Int, \$pinterest: String, \$pinterestFollows: Int,
  \$tiktok: String, \$tiktokFollows: Int, \$twitter: String, \$twitterFollows: Int,
  \$youtube: String, \$youtubeSubs: Int, \$linkedin: String, \$linkedinFollows: Int,
  \$patreon: String, \$patreonFollows: Int, \$reddit: String, \$redditFollows: Int,
  \$snapchat: String, \$snapchatFollows: Int
){
  updateUserSocials(
    facebook: \$facebook,
    facebookFollows: \$facebookFollows,
    instagram: \$instagram,
    instaFollows:\$instaFollows,
    tiktok:\$tiktok,
    tiktokFollows: \$tiktokFollows,
    twitter:\$twitter,
    twitterFollows:\$twitterFollows,
    pinterest:\$pinterest,
    pinterestFollows:\$pinterestFollows,
    youtube: \$youtube,
    youtubeSubs:\$youtubeSubs,
    patreon:\$patreon,
    patreonFollows: \$patreonFollows,
    linkedin: \$linkedin,
    linkedinFollows:\$linkedinFollows,
    reddit:\$reddit,
    redditFollows:\$redditFollows,
    snapchat:\$snapchat,
    snapchatFollows:\$snapchatFollows,
  ){
    socials{
      instagram{
        username
        noOfFollows
      },
      facebook{
        username
        noOfFollows
      },
      tiktok{
        username
        noOfFollows
      },
    	youtube{
        username
        noOfFollows
      },
      pinterest{
        username
        noOfFollows
      },
      twitter{
        username
        noOfFollows
      },

       snapchat{
        username
        noOfFollows
      },
       reddit{
        username
        noOfFollows
      },
       linkedin{
        username
        noOfFollows
      },
       patreon{
        username
        noOfFollows
      },
    }
  }
}
        ''', payload: {
        'facebook': facebook,
        'facebookFollows': facebookFollows,
        'instagram': instagram,
        'instaFollows': instaFollows,
        'tiktok': tiktok,
        'tiktokFollows': tiktokFollows,
        'pinterest': pinterest,
        'pinterestFollows': pinterestFollows,
        'youtube': youtube,
        'youtubeSubs': youtubeSubs,
        'twitter': twitter,
        'twitterFollows': twitterFollows,
        'snapchat': snapchat,
        'linkedin': linkedin,
        'reddit': reddit,
        'patreon': patreon,
        'patreonFollows': patreonFollows,
        'snapchatFollows': snapchatFollows,
        'linkedinFollows': linkedinFollows,
        'redditFollows': redditFollows,
      });

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['updateUserSocials']);
      });

      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>>
      deleteProfilePicture() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''

mutation deleteProfilePicture{
  deleteProfilePic {
    user {
      thumbnailUrl
      profilePictureUrl
    }
  }
}

        ''', payload: {});

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['deleteProfilePic']['user']);
      });
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> toggleZodiac(
      String value) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''

mutation updatePermissions() {
  updatePermissions(
    displayStarSign: $value,
  )
  {
    message
  }
}

        ''', payload: {});

      final Either<CustomException, Map<String, dynamic>> response =
          result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  String _tagPrint(String message) {
    return '[$_TAG] $message';
  }

  Future<Either<CustomException, Map<String, dynamic>>> updateUserLocation({
    // int? id,
    // required Map<String, dynamic> location,
    required String latitude,
    required String longitude,
    required String locationName,
  }) async {
    try {
      final response =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
           mutation myUpdateProfile(
         \$latitude : String!,
         \$longitude : String!,
         \$locationName : String,
       ) {
  updateProfile(
      location: {
        latitude: \$latitude
        longitude: \$longitude
        locationName: \$locationName
      }
  ) {
    user {
      id
      username
      location{
        latitude
        longitude
        locationName
      }
    }
  }
}
        ''', payload: {
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
      });

      final Either<CustomException, Map<String, dynamic>> result =
          response.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['updateProfile']['user']);
      });
      return result;
    } catch (e) {
      _tagPrint('Error updating profile picture in  ===> $e');
      return Left(CustomException(e.toString()));
    }
  }

  //
  // Future<Either<CustomException, Map<String, dynamic>>> updateProfilePicture({
  //   required String profilePictureUrl,
  // }) async {
  //   try {
  //     final response = await vBaseServiceInstance.mutationQuery(
  //       mutatonDocument: '''
  //       mutation updateProfile(\$profilePictureUrl: String!) {
  //         updateProfile(profilePictureUrl: \$profilePictureUrl) {
  //           user {
  //             username
  //             lastName
  //             firstName
  //             isActive
  //             bio
  //             id
  //             profilePictureUrl
  //             profilePicture
  //           }
  //         }
  //       }
  //     ''',
  //       payload: {
  //         'profilePictureUrl': profilePictureUrl,
  //       },
  //     );
  //
  //     final Either<CustomException, Map<String, dynamic>> result =
  //     response.fold(
  //             (left) => Left(left),
  //             (right) => Right(right!['updateProfile']['user']));
  //     return result;
  //   } catch (e) {
  //     return Left(CustomException(e.toString()));
  //   }
  // }
}
