// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/repository/file_upload_service.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/create_posts/models/image_upload_response_model.dart';
import 'package:vmodel/src/features/jobs/create_jobs/model/ai_desc_type_enum.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/banner_model.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

import '../../../../core/utils/enum/ethnicity_enum.dart';
import '../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../core/utils/enum/size_enum.dart';
import '../model/job_data.dart';
import '../repository/create_job_repo.dart';

final createJobIsSingleSelectionProvider = StateProvider<bool>((ref) {
  return true;
});

final calculatedTotalDurationProvider = StateProvider<Duration>((ref) {
  final allDurations = ref.watch(createJobNotifierProvider);
  if (allDurations.isEmpty) return Duration.zero;
  Duration res = Duration.zero;
  for (var item in allDurations) {
    res += item.dateDuration;
  }
  return res;
});

final timeOpProvider = Provider<List<Duration>>((ref) {
  return List.generate(49, (index) => Duration(minutes: index * 30)).toList();
});

final jobDataProvider = StateProvider<JobDataModel?>((ref) {
  return const JobDataModel(
    jobTitle: '',
    jobType: '',
    priceOption: '',
    priceValue: 0.0,
    talents: [],
    preferredGender: '',
    shortDescription: '',
    location: null,
    deliverablesType: '',
    isDigitalContent: false,
    acceptMultiple: false,
    usageType: '',
    usageLength: '',
    minAge: 0,
    maxAge: 0,
    height: {},
    size: ModelSize.other,
    ethnicity: Ethnicity.black,
    complexion: '',
    category: null,
  );
});

// class TimeOptionsNotifier extends Notifier<List<Duration>> {
//   @override
//   build() {
//     return List.generate(48, (index) => Duration(minutes: index * 30)).toList();
//   }
// }

final createJobNotifierProvider = NotifierProvider<CreateJobNotifier, List<JobDeliveryDate>>(CreateJobNotifier.new);
final breifFileUploadProgress = StateProvider((ref) => 0.0);

class CreateJobNotifier extends Notifier<List<JobDeliveryDate>> {
  // bool _isSingleSelection = true;
  @override
  List<JobDeliveryDate> build() {
    return [];
  }

  setAll(List<JobDeliveryDate> data) {
    state = data;
    // state.sort((a, b) => a.date.compareTo(b.date));
    // ref.invalidate(calculatedTotalDurationProvider);
  }

  add({
    required DateTime dateTime,
    required Duration start,
    required Duration end,
    required ServicePeriod priceType,
  }) {
    // final isExists = ;
    final deliveryDate = JobDeliveryDate(date: dateTime, startTime: start, endTime: end);
    // if (priceType == ServicePeriod.hour) {
    final isExist = containsDateTime(dateTime);
    if (isExist) {
      final temp = state;
      temp.removeWhere((element) => element.date == dateTime);
      // temp.remove(deliveryDate);
      state = temp;
    } else {
      final temp = state;
      temp.add(deliveryDate);
      state = temp;
    }
    // } else {
    //   if (state.isNotEmpty) {
    //     final temp = state;
    //     temp[0] = deliveryDate;
    //     state = temp;
    //   } else {
    //     final temp = state;
    //     temp.add(deliveryDate);
    //     state = temp;
    //     // state.add(deliveryDate);
    //   }
    // }
    state.sort((a, b) => a.date.compareTo(b.date));
  }

  void removeDateEntry(DateTime dateTime) {
    final isExist = containsDateTime(dateTime);
    if (isExist) {
      final temp = state;
      temp.removeWhere((element) => element.date == dateTime);
      // temp.remove(deliveryDate);
      state = temp;
    }
    state.sort((a, b) => a.date.compareTo(b.date));
  }

  bool containsDateTime(DateTime dt) {
    return state.any((element) => element.date == dt);
  }

  // void ssls(){
  //   ref.in
  // }

  void updateDeliveryDateTimes(DateTime dateTime, {Duration? start, Duration? end, bool? isFullDay}) {
    if (containsDateTime(dateTime)) {
      // state.map((e) => )
      state = [
        for (JobDeliveryDate s in state)
          if (s.date == dateTime) s.copyWith(startTime: start, endTime: end, isFullDay: isFullDay) else s
      ];
    }
  }

  Future<bool> createJob({required bool isAdvanced}) async {
    final repository = CreateJobRepository.instance;
    final data = ref.read(jobDataProvider);
    final response = await repository.createJob(
      jobData: data!,
      deliveryData: state.map((e) => e.toMap()).toList(),
      isAdvanced: isAdvanced,
    );
    return response.fold((left) {
      logger.e(left.message);
      VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: 'Failed to create job');
      return false;
    }, (right) {
      final success = right['success'] ?? false;
      // if (success) {
      //   VWidgetShowResponse.showToast(ResponseEnum.sucesss,
      //       message: 'Job created successfully');
      // }
      return success;
    });
  }

  Future<bool> createJobRequest({required bool isAdvanced, bool isRequest = false, String? requestTo}) async {
    final repository = CreateJobRepository.instance;
    final data = ref.read(jobDataProvider);
    final List? banners = await bannerUploader();
    logger.i(banners);
    if (banners == null) {
      return false;
    }

    final response = await repository.createRequest(
      jobData: data!,
      deliveryData: state.map((e) => e.toMap()).toList(),
      isAdvanced: isAdvanced,
      isRequest: isRequest,
      requestTo: requestTo,
      banner: banners,
    );
    return response.fold((left) {
      logger.e(left.message);
      if (left.message == 'rate_limited') {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: 'You have reached the limit for creating requests');
      } else {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: 'Failed to create job');
      }

      return false;
    }, (right) {
      final success = right['success'] ?? false;
      // if (success) {
      //   VWidgetShowResponse.showToast(ResponseEnum.sucesss,
      //       message: 'Job created successfully');
      // }
      return success;
    });
  }

  Future<Either<String, String>> genDesc(String jobTitle, String jobType, AIDescType descType) async {
    final repository = CreateJobRepository.instance;
    final result = await repository.generateJobDescription(title: jobTitle, location: jobType, descType: descType);
    return result.fold((p0) => Left(p0.message), (p0) => Right(p0));
  }

  Future<Map<String, dynamic>?> uploadFile(File file) async {
    final repo = CreateJobRepository.instance;
    ref.read(breifFileUploadProgress.notifier).state = 0.1;
    final uploadResult = await repo.uploadFile(file, onUploadProgress: (sent, total) {
      ref.read(breifFileUploadProgress.notifier).state = sent / total;
    });

    return uploadResult.fold((p0) {
      VWidgetShowResponse.showToast(ResponseEnum.failed, message: "An error occured uploading files");
      ref.invalidate(breifFileUploadProgress);
      logger.e(p0.message);
      return null;
    }, (data) {
      ref.invalidate(breifFileUploadProgress);
      if (data != null) {
        return jsonDecode(data);
      } else {
        return null;
      }
    });
  }

  Future<bool> updateJob({required String jobId, required bool isAdvanced}) async {
    final repository = CreateJobRepository.instance;
    final data = ref.read(jobDataProvider);

    int? id = int.tryParse(jobId);

    if (id == null) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Invalid job id provided');
      return false;
    }

    final response = await repository.updateJob(jobId: id, jobData: data!, deliveryData: state.map((e) => e.toMap()).toList(), isAdvanced: isAdvanced);

    return response.fold((left) {
      logger.e(left.message);
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Failed to upate job');
      return false;
    }, (right) {
      final success = right['success'] ?? false;
      // if (success) {
      //   VWidgetShowResponse.showToast(ResponseEnum.sucesss,
      //       message: 'Job updated successfully');
      // }
      return success;
    });
  }

  Future<bool> duplicateJob({required Map<String, dynamic> data}) async {
    final repository = CreateJobRepository.instance;
    final response = await repository.duplicateJob(
      data: data,
    );
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: 'Failed to duplicate job');
      return false;
    }, (right) {
      final success = right['success'] ?? false;
      if (success) {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: 'Job duplicated successfully');
      }
      return success;
    });
  }

  /*
    JOB REQUEST BANNER UPLOADER FUNCTION USES THRE serviceImagesProvider to access the banners
  */
  Future<List<dynamic>?> bannerUploader() async {
    final imagesToUpload = ref.read(jobRequestImagesProvider);
    final List<Map<String, dynamic>> existingBanners = [];
    List? serviceBannerMap;
    if (imagesToUpload.isNotEmpty) {
      final List<File> filesToUpload = [];
      for (var x in imagesToUpload) {
        if (x.isFile)
          filesToUpload.add(x.file!);
        else
          existingBanners.add(x.toFileAndThumbnailMap);
      }
      if (filesToUpload.isNotEmpty) {
        serviceBannerMap = await _uploadBanner(filesToUpload);
      }
      if (filesToUpload.isNotEmpty && serviceBannerMap == null) {
        return null;
      }

      serviceBannerMap = [...existingBanners, ...?serviceBannerMap];
    } else {
      serviceBannerMap = [];
    }
    return serviceBannerMap;
  }

  Future<List<dynamic>?> _uploadBanner(List<File> images) async {
    final uploadResult = await FileUploadRepository.instance.uploadFiles(images, uploadEndpoint: VUrls.serviceBannerUploadUrl, onUploadProgress: (sent, total) {
      logger.d('Upload Progress ${sent / total}');
    });

    return uploadResult.fold((left) {
      return null;
    }, (right) {
      if (right == null) {
        return null;
      }

      final map = json.decode(right);
      final uploadedFilesMap = map["data"] as List<dynamic>;
      String baseUrl = map['base_url'] ?? '';
      if (uploadedFilesMap.isNotEmpty) {
        final objs = uploadedFilesMap.map((e) => ImageUploadResponseModel.fromMap(baseUrl, e)).toList();

        final filesToPost = objs.map((e) => e.toFileAndThumbnailMap).toList();
        return filesToPost;
      }
      return null;
    });
  }
}

// Rquests Image handler class
final jobRequestImagesProvider = NotifierProvider.autoDispose<JobRequestImagesNotifier, List<BannerModel>>(JobRequestImagesNotifier.new);

class JobRequestImagesNotifier extends AutoDisposeNotifier<List<BannerModel>> {
  final int maxLimit = 10;
  @override
  build() {
    return [];
  }

  void addImages(List<BannerModel> images) {
    final int len = state.length;
    if (len > maxLimit) return;

    state = [...state, ...images.take(maxLimit - len)];
  }

  void removeImage(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = [...newState];
  }

  Future<void> pickImages() async {
    if (state.length >= VConstants.maxServiceBannerImages) {
      VWidgetShowResponse.showToast(ResponseEnum.warning, message: "Maximum of ${VConstants.maxServiceBannerImages} can be selected");
      return;
    }
    final pickedImages = await pickServiceImages();
    final banners = pickedImages.map((e) => BannerModel(file: e, isFile: true)).toList();
    addImages(banners);

    // ref
    //     .read(discardProvider.notifier)
    //     .updateState('banners', newValue: [...banners]);
  }
}

// Duration get dateDuration => endTime - startTime;
@immutable
class JobDeliveryDate {
  final DateTime date;
  final Duration startTime;
  final Duration endTime;
  final bool isFullDay;

  Duration get dateDuration => endTime - startTime;

//Generated
  const JobDeliveryDate({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isFullDay = false,
  });

  JobDeliveryDate copyWith({
    DateTime? date,
    Duration? startTime,
    Duration? endTime,
    bool? isFullDay,
  }) {
    return JobDeliveryDate(
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isFullDay: isFullDay ?? this.isFullDay,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'date': '${date.year}-${date.month}-${date.day}',
      'date': date.toIso8601String(),
      'startTime': startTime.inMinutes.toString(),
      'endTime': endTime.inMinutes.toString(),
      // 'isFullDay': isFullDay,
    };
  }

  factory JobDeliveryDate.fromMap(Map<String, dynamic> map) {
    try {
      dynamic start = map['startTime'] as String;
      start = int.parse(start);
      dynamic end = map['endTime'] as String;
      end = int.parse(end);

      return JobDeliveryDate(
        date: DateTime.parse(map['date'] as String),
        startTime: Duration(minutes: start),
        endTime: Duration(minutes: end),

        // isFullDay: map['isFullDay'] as bool,
        isFullDay: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  // factory JobDeliveryDate.fromJson(String source) =>
  //     JobDeliveryDate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'JobDeliveryDate(date: $date, startTime: $startTime, endTime: $endTime, isFullDay: $isFullDay)';
  }

  @override
  bool operator ==(covariant JobDeliveryDate other) {
    if (identical(this, other)) return true;

    return other.date == date && other.startTime == startTime && other.endTime == endTime && other.isFullDay == isFullDay;
  }

  @override
  int get hashCode {
    return date.hashCode ^ startTime.hashCode ^ endTime.hashCode ^ isFullDay.hashCode;
  }
}
