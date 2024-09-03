import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/models/bust_model.dart';
import 'package:vmodel/src/core/models/chest.dart';
import 'package:vmodel/src/core/models/feet_model.dart';
import 'package:vmodel/src/core/models/height_model.dart';
import 'package:vmodel/src/core/models/user_location.dart';
import 'package:vmodel/src/core/models/waist_model.dart';
import 'package:vmodel/src/core/repository/app_user_repository.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../features/authentication/controller/auth_status_provider.dart';
import '../../shared/response_widgets/toast.dart';
import '../api/file_service.dart';
import '../models/location_model.dart';
import '../models/phone_number_model.dart';
import '../models/user_socials.dart';
import '../network/urls.dart';
import '../utils/enum/ethnicity_enum.dart';
import '../utils/enum/gender_enum.dart';
import '../utils/enum/size_enum.dart';

//For most endpoints that require username as argument, 'null' indicates
// the current user whilst any other value indicates another user.
final userNameForApiRequestProvider =
    StateProvider.family.autoDispose<String?, String>((ref, arg) {
  final currentUser = ref.watch(appUserProvider).valueOrNull;
  if (arg == currentUser?.username) {
    return null;
  }
  return arg;
});

final appUserProvider =
    AsyncNotifierProvider.autoDispose<AppUserNotifier, VAppUser?>(
        AppUserNotifier.new);

class AppUserNotifier extends AutoDisposeAsyncNotifier<VAppUser?> {
  // AppUserNotifier() : super();
  AppUserRepository? _repository;
  bool _isBuilding = false;

  @override
  Future<VAppUser?> build() async {
    _isBuilding = true;
    _repository = AppUserRepository.instance;
    // final VAppUser _stateCopy;
    final userProfile = await _repository!.getMe();

    VAppUser? initialState;
    userProfile.fold((left) {
      throw left.message;
    }, (right) {
      try {
        final newState = VAppUser.fromMap(right);

        // print("this is the user profile ${newState.meta == null ? "none" : newState.meta!.toJson()}");

        initialState = newState;
      } catch (e, s) {
        logger.e(e.toString());
        logger.e(s);
        throw (e.toString());
      }
    });

    _isBuilding = false;
    return initialState;
  }

  Future<bool> createBusinessAddress(LocationData address) async {
    final response = await _repository!.createBusinessAddress(address: address);
    return response.fold(
      (e) {
        logger.e(e.toString());
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updateBusinessAddress(LocationData address) async {
    final response = await _repository!.updateBusinessAddress(address: address);
    return response.fold(
      (e) {
        logger.e(e.toString());
        return false;
      },
      (_) => true,
    );
  }

  Future<void> updateUserSocials({
    String? facebook,
    String? instagram,
    String? tiktok,
    String? pinterest,
    String? youtube,
    String? twitter,
    String? linkedin,
    String? snapchat,
    String? patreon,
    String? reddit,
    int? facebookFollows,
    int? instaFollows,
    int? twitterFollows,
    int? youtubeSubs,
    int? tiktokFollows,
    int? pinterestFollows,
    int? linkedinFollows,
    int? redditFollows,
    int? snapchatFollows,
    int? patreonFollows,
  }) async {
    final response = await _repository!.updateUserSocials(
      facebook: facebook,
      facebookFollows: facebookFollows,
      twitter: twitter,
      twitterFollows: twitterFollows,
      tiktok: tiktok,
      tiktokFollows: tiktokFollows,
      pinterest: pinterest,
      pinterestFollows: pinterestFollows,
      youtube: youtube,
      youtubeSubs: youtubeSubs,
      instagram: instagram,
      instaFollows: instaFollows,
      linkedin: linkedin,
      snapchat: snapchat,
      patreon: patreon,
      reddit: reddit,
      linkedinFollows: linkedinFollows,
      redditFollows: redditFollows,
      snapchatFollows: snapchatFollows,
      patreonFollows: patreonFollows,
    );
    response.fold((left) {}, (right) {
      final temp = state.value?.copyWith(
        socials: UserSocials.fromMap(right['socials']),
      );
      state = AsyncData(temp);
      return;
    });
  }

  Future<String> updateProfile({
    bool? allowConnectionView,
    String? bio,
    List<String>? interests,
    String? website,
    String? firstName,
    String? lastName,
    String? displayName,
    String? label,
    String? dob,
    String? trait,
    String? personality,
    String? hair,
    String? eyes,
    PhoneNumberModel? phone, //would require verification later
    WaistModel? waist, //would require verification later
    HeightModel? height, //would require verification later
    FeetModel? feet, //would require verification later
    BustModel? bust, //would require verification later
    ChestModel? chest, //would require verification later
    Gender? gender,
    Ethnicity? ethnicity,
    LocationData? location, //currently locationName can't be updated
    ModelSize? modelSize,
    String? profilePictureUrl,
    String? thumbnailUrl,
    int? yearsOfExperience,
    String? profileRing,
  }) async {
    final data = state.valueOrNull;
    try {
      final response = await _repository!.updateProfile(
        allowConnectionView: allowConnectionView ?? false,
        bio: bio ?? data?.bio,
        interests: interests ?? data?.interests,
        website: website ?? data?.website,
        firstName: firstName ?? data?.firstName,
        lastName: lastName ?? data?.lastName,
        displayName: displayName ?? data?.displayName,
        hair: hair ?? data?.hair,
        dob: dob ?? data?.dob?.toIso8601DateOnlyString,
        eyes: eyes ?? data?.eyes,
        phone: phone?.toMap() ?? data?.phone?.toMap(),
        gender: gender?.apiValue ?? data?.gender?.apiValue,
        ethnicity: ethnicity?.apiValue ?? data?.ethnicity?.apiValue,
        modelSize: modelSize?.apiValue ?? data?.modelSize?.apiValue,
        label: label ?? data?.label,
        trait: trait,
        personality: personality,
        height: height?.toMap() ?? data?.height?.toMap(),
        waist: waist?.toMap() ?? data?.waist?.toMap(),
        feet: feet?.toMap() ?? data?.feet?.toMap(),
        bust: bust?.toMap() ?? data?.bust?.toMap(),
        chest: chest?.toMap() ?? data?.chest?.toMap(),
        locationName: '',
        profilePictureUrl: profilePictureUrl ?? data?.profilePictureUrl,
        thumbnailUrl: thumbnailUrl ?? data?.thumbnailUrl,
        yearsOfExperience: yearsOfExperience ?? data?.yearsOfExperience,
        profileRing: profileRing ?? data?.profileRing,
      );

      return response.fold((left) {
        // print("------------- this is the response 1 ${left.message}");

        return left.message;
      }, (right) async {
        // print("update:$right");
        final temp = state.value?.copyWith(
          allowConnectionView: right['allowConnectionView'],
          bio: right['bio'],
          interests: right['interests'] != null
              ? List<String>.from(right['interests'])
              : null,
          firstName: right['firstName'],
          lastName: right['lastName'],
          displayName: right['displayName'],
          label: right['label'],
          trait: right['trait'],
          personality: right['personality'],
          dob: DateTime.tryParse(right['dob'] ?? ''),
          hair: right['hair'],
          eyes: right['eyes'],
          phone: PhoneNumberModel.fromMap(right['phone'] ?? {}),
          gender: Gender.genderByApiValue(right['gender']),
          ethnicity: Ethnicity.ethnicityByApiValue(right['ethnicity']),
          modelSize: ModelSize.modelSizeByApiValue(right['size']),
          profilePictureUrl: right['profilePictureUrl'],
          thumbnailUrl: right['thumbnailUrl'],
          website: right['website'],
          yearsOfExperience: right['yearsOfExperience'],
          profileRing: right['profileRing'],
        );

        state = AsyncData(temp);
        return "Successful";
      });
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> updateUsername({
    String? username,
  }) async {
    final data = state.value!;
    try {
      final response = await _repository!.updateUsername(
        username: username ?? data.username,
      );

      return response.fold((left) {
        logger.e(left.message);
        return false;
      }, (right) async {
        logger.f(right);
        final user = right['user'] ?? {};
        final temp = state.value?.copyWith(username: user['username']);
        state = AsyncData(temp);

        if (username != null) {
          await ref
              .read(authenticationStatusProvider.notifier)
              .updateCredentials(authToken: right['token']);
        }
        return true;
      });
    } catch (e) {
      logger.e(e.toString());
      return false;
    }
  }

  Future<bool> updatePrivacy(Map<String, dynamic> payload) async {
    // final data = state.value!;
    try {
      final response = await _repository!.updatePrivacy(payload);

      return response.fold((left) {
        return false;
      }, (right) async {
        // logger.d(right);
        final updatedUser = await ref.refresh(appUserProvider.future);
        // final temp = state.value?.copyWith(meta: PrivacySettings.fromJson(payload));
        state = AsyncData(updatedUser);
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<void> updateFCMToken({required String token}) async {
    try {
      final response = await _repository!.updateFCMToken(
        fcmToken: token,
      );

      response.fold((left) {
        return null;
      }, (right) async {
        return null;
      });
    } catch (e) {}
  }

  Future<void> updateNotification({
    bool? alertProfileVisit,
  }) async {
    final data = state.value!;
    try {
      final response = await _repository!.updateNotification(
        alertProfileVisit: alertProfileVisit ?? data.alertOnProfileVisit,
      );

      response.fold((left) {
        return null;
      }, (right) async {
        final user = right['user'] ?? {};
        final temp = state.value
            ?.copyWith(alertOnProfileVisit: user['alertOnProfileVisit']);
        state = AsyncData(temp);
        return null;
      });
    } catch (e) {}
  }

  Future<void> updateUserLocation({
    required double lat, //currently locationName can't be updated
    required double lon, //currently locationName can't be updated
    required String locationName, //currently locationName can't be updated
  }) async {
    // final locationData =
    //     LocationData(latitude: lat, longitude: lon, locationName: locationName);
    try {
      final response = await _repository!.updateUserLocation(
          // latitude: lat.toString(),
          // longitude: lon.toString(),
          latitude: '0',
          longitude: '0',
          locationName: locationName);

      response.fold((left) {
        return;
      }, (right) {
        final temp = state.value?.copyWith(
          location: UserLocation.fromJson(right['location']),
        );
        state = AsyncData(temp);
        return;
      });
    } catch (e) {}
  }

  Future<void> uploadProfilePicture(String path,
      {OnUploadProgressCallback? onProgress}) async {
    try {
      //Upload file to bucket
      String result = await FileService.fileUploadMultipart(
        url: VUrls.profilePictureUploadUrl,
        files: [path],
        onUploadProgress: onProgress,
      );
      // print(result);
      final map = json.decode(result);
      final files = map["data"] as List<dynamic>;
      String baseUrl = map['base_url'] ?? '';
      final url = files.first['profile_picture_url'] ?? '';
      final thumbnail = files.first['thumbnail_url'] ?? '';

      //Send url to backend API
      if (url.isNotEmpty) {
        updateProfile(
          profilePictureUrl: '$baseUrl$url',
          thumbnailUrl: '$baseUrl$thumbnail',
        );
      }
    } catch (e) {
      VWidgetShowResponse.showToast(
        ResponseEnum.failed,
        message: 'Error uploading headshot $e',
      );
    }
  }

  Future<void> updateSocialUsernames(
      {String? facebook,
      String? instagram,
      String? tiktok,
      String? pinterest,
      String? youtube,
      String? twitter}) async {
    try {
      final userSocials = await _repository!.updateUserSocials(
          facebook: facebook,
          instagram: instagram,
          tiktok: tiktok,
          pinterest: pinterest,
          youtube: youtube,
          twitter: twitter);

      userSocials.fold((left) {
        VWidgetShowResponse.showToast(
          ResponseEnum.failed,
          message: 'Error updating socials ${left.message}',
        );
      }, (right) {
        final currentState = state.valueOrNull;
        if (currentState != null) {
          final newState =
              currentState.copyWith(socials: UserSocials.fromMap(right));
          state = AsyncData(newState);
        }
      });
    } catch (e) {
      VWidgetShowResponse.showToast(
        ResponseEnum.failed,
        message: 'Error updating socials $e',
      );
    }
  }

  Future<void> deleteHeadshot() async {
    final userSocials = await _repository!.deleteProfilePicture();
    userSocials.fold((left) {}, (right) {
      final pic = right['profilePictureUrl'];
      final thumbnail = right['thumbnailUrl'];
      state = AsyncData(state.value?.copyWith(
        profilePictureUrl: "$pic",
        thumbnailUrl: "$thumbnail",
      ));
    });
  }

  Future<void> toggleZodiac(String value) async {
    final userSocials = await _repository!.toggleZodiac(value);
    userSocials.fold((left) {}, (right) {
      final currentState = state.value;

      final newState =
          AsyncData(currentState?.copyWith(displayZodiacSign: value));

      state = newState;
    });
  }

  bool isCurrentUser(String? otherUsername) {
    // final user = state.valueOrNull;
    if (otherUsername == null) return false;
    return state.valueOrNull?.username == otherUsername;
  }

  void onLogOut() {
    ref.invalidateSelf();
  }
}

enum DisplayStarSign {
  YES,
  NO,
}
