import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../core/repository/file_upload_service.dart';
import '../../../../../shared/response_widgets/toast.dart';
import '../../../../create_posts/models/image_upload_response_model.dart';
import '../../../../dashboard/new_profile/profile_features/services/repository/services_repository.dart';
import '../models/service_package_model.dart';
import 'service_images_controller.dart';

final proTierProvider = StateProvider<ServiceTierModel?>((ref) => null);
final premiumTierProvider = StateProvider<ServiceTierModel?>((ref) => null);

final serviceProvider = StateProvider<ServicePackageModel?>((ref) {
  return null;
});

final hasServiceProvider = Provider.autoDispose.family<bool, String?>((ref, username) {
  final services = ref.watch(servicePackagesProvider(username)).valueOrNull ?? [];
  return services.isNotEmpty;
});

final likeProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final userServiceProvider = FutureProvider.autoDispose((ref) async {
  final repo = ServicesRepository.instance;

  final service = await repo.getUserServices(filterBy: 'Creator');

  return service.fold((left) {
    logger.e(left.message);
    throw left.message;
  }, (right) {
    final servicesList = right.map<ServicePackageModel>((e) => ServicePackageModel.fromMiniMap(e as Map<String, dynamic>, discardUser: false)).toList();
    servicesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return servicesList;
  });
});

final servicePackagesProvider = AsyncNotifierProvider.autoDispose.family<ServicePackageController, List<ServicePackageModel>, String?>(() => ServicePackageController());

class ServicePackageController extends AutoDisposeFamilyAsyncNotifier<List<ServicePackageModel>, String?> {
  final _repository = ServicesRepository.instance;
// final servicePackagesProvider =
// AutoDisposeAsyncNotifier<ServicePackageController, List<ServicePackageModel>>(() {
//   return ServicePackageController();
// });
//   class ServicePackageController
//   extends AutoDisposeAsyncNotifier<List<ServicePackageModel>> {
  // List<ServicePackageModel> build() {
  //   final authState = ref.watch(authProvider);
  //
  //   return [
  //     ServicePackageModel(
  //         id: "${authState.username}_1000",
  //         price: authState.price ?? -999,
  //         title: "Default",
  //         description: '',
  //         delivery: '',
  //         usageType: '',
  //         usageLength: '',
  //         servicePricing: ServicePackagePricingType.hour),
  //   ];
  // }
  @override
  Future<List<ServicePackageModel>> build(username) async {
    List<ServicePackageModel>? services;

    final res = await _repository.getUserServices(username: username);
    // //print('resssssssssssssssssssssssss');

    return res.fold((left) {
      //print('[9kw] $username fail');
      logger.e(left.message);
      return [];
    }, (right) {
      final servicesList = right.map<ServicePackageModel>((e) => ServicePackageModel.fromMap(e as Map<String, dynamic>)).toList();
      servicesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return servicesList;
    });
  }

  Future<ServicePackageModel> getService({required String serviceId, String? username}) async {
    ServicePackageModel? serviceData;
    final response = await _repository.getUserService(
      serviceId: int.parse(serviceId),
      username: username,
    );

    response.fold(
      (left) {
        //print('failed to get service ${left.message}');
        // run this block when you have an error
        serviceData = null;
      },
      (right) async {
        //print('successfully fetched service');

        final userService = right;
        serviceData = ServicePackageModel.fromMap(userService);

        // if the success field in the mutation response is true
      },
    );
    return serviceData!;
  }

  Future<List<dynamic>?> _uploadBanner(List<File> images) async {
    final uploadResult = await FileUploadRepository.instance.uploadFiles(images, uploadEndpoint: VUrls.serviceBannerUploadUrl, onUploadProgress: (sent, total) {
      final percentage = sent / total;
      logger.i('$percentage%');
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

  Future<bool> addPackage({
    required String period,
    required String title,
    required String description,
    required String deliverablesType,
    required String serviceLocation,
    required double price,
    required String deliveryTimeline,
    required ServiceType serviceType,
    required ServiceType serviceSubType,
    String? usageType,
    String? usageLength,
    bool? isOffer,
    required bool isDigitalContent,
    required bool hasAddtionalSerices,
    int? percentDiscount,
    XFile? image,
    double? deposit,
    List? faqs,
    double? travelFee,
    String? travelPolicy,
    double? expressDeliveryPrice,
    String? expressDelivery,
    required List<ServiceTierModel> tiers,
  }) async {
    final List? banners = await bannerUploader();
    if (banners == null) {
      return false;
    }

    final response = await _repository.createService(
      period: period,
      title: title,
      description: description,
      price: price,
      serviceType: serviceType,
      serviceSubType: serviceSubType,
      serviceLocation: serviceLocation,
      deliveryTimeline: deliveryTimeline,
      usageType: usageType,
      deliverablesType: deliverablesType,
      usageLength: usageLength,
      isDigitalContent: isDigitalContent,
      hasAdditionalServices: hasAddtionalSerices,
      percentDiscount: percentDiscount,
      banner: banners,
      initialDeposit: deposit,
      faqs: faqs,
      isOffer: isOffer ?? false,
      travelFee: travelFee,
      travelPolicy: travelPolicy,
      expressDeliveryPrice: expressDeliveryPrice,
      expressDelivery: expressDelivery,
      tiers: tiers,
    );

    return response.fold(
      (left) {
        return false;
      },
      (right) async {
        final newServicePackage = ServicePackageModel.fromMiniMap(right, discardUser: false);
        state = AsyncValue.data([
          newServicePackage,
          ...?state.value,
        ]);
        return true;
      },
    );
  }

  Future<Map<String, dynamic>> createOffer({
    required String period,
    required String title,
    required String description,
    required String serviceLocation,
    required double price,
    required String deliveryTimeline,
    required String deliverablesType,
    required ServiceType serviceType,
    required ServiceType serviceSubType,
    String? usageType,
    String? usageLength,
    bool? isOffer,
    required bool isDigitalContent,
    required bool hasAddtionalSerices,
    int? percentDiscount,
    XFile? image,
    double? deposit,
    List? faqs,
  }) async {
    final List? banners = await bannerUploader();
    if (banners == null) {
      return {};
    }

    final response = await _repository.createService(
      period: period,
      title: title,
      description: description,
      price: price,
      serviceType: serviceType,
      serviceSubType: serviceType,
      serviceLocation: serviceLocation,
      deliveryTimeline: deliveryTimeline,
      usageType: usageType,
      deliverablesType: deliverablesType,
      usageLength: usageLength,
      isDigitalContent: isDigitalContent,
      hasAdditionalServices: hasAddtionalSerices,
      percentDiscount: percentDiscount,
      banner: banners,
      initialDeposit: deposit,
      faqs: faqs,
      isOffer: isOffer ?? false,
      tiers: [],
    );

    return response.fold(
      (left) {
        //print('failed to create service ${left.message}');
        return {};
      },
      (right) async {
        return right;
      },
    );
  }

  Future<void> publishService({required String serviceId}) async {
    final id = int.parse(serviceId);
    final response = await _repository.publishService(id);

    response.fold(
      (left) {
        //print('failed to create service ${left.message}');
        // run this block when you have an error
        VWidgetShowResponse.showToast(ResponseEnum.failed, message: "Error duplicating service");
      },
      (right) async {
        //print('successfully duplicated service');
        //print(right);

        VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Service published');
        // final newServicePackage =
        //     ServicePackageModel.fromMiniMap(right, discardUser: false);
        // state = AsyncValue.data([
        //   newServicePackage,
        //   ...?state.value,
        // ]);
        ref.invalidateSelf();

        // if the success field in the mutation response is true
      },
    );
  }

  Future<void> duplicate({required Map<String, dynamic> data}) async {
    final response = await _repository.duplicate(data: data);

    response.fold(
      (left) {
        //print('failed to create service ${left.message}');
        // run this block when you have an error
        VWidgetShowResponse.showToast(ResponseEnum.failed, message: "Error duplicating service");
      },
      (right) async {
        //print('successfully duplicated service');
        //print(right);

        VWidgetShowResponse.showToast(ResponseEnum.warning, message: 'Service duplicated');
        final newServicePackage = ServicePackageModel.fromMiniMap(right, discardUser: false);
        state = AsyncValue.data([
          newServicePackage,
          ...?state.value,
        ]);

        // if the success field in the mutation response is true
      },
    );
  }

  Future<bool> pauseOrResumeService(String packageId, {bool isResume = false}) async {
    final List<ServicePackageModel> packageList = state.valueOrNull ?? [];
    // //print('[pd] The id to delete is $packageId');

    final action = isResume ? "resume" : "pause";
// final sss = packageList.any((element) => element.id ==)
//     //print('[kkm] ${}')

    final makeRequest = isResume
        ? await _repository.resumeService(
            int.parse(packageId),
          )
        : await _repository.pauseService(
            int.parse(packageId),
          );

    return makeRequest.fold((onLeft) {
      //print('Failed to $action service ${onLeft.message}');
      return false;
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (!success) return false;

      state = AsyncValue.data([
        for (final package in packageList)
          if (package.id == packageId) package.copyWith(paused: isResume ? false : true) else package,
      ]);

      VWidgetShowResponse.showToast(
        ResponseEnum.sucesss,
        message: 'Successfully ${action}d service',
      );
      // //print('[pd] $onRight');
      //print('successfully $action service');
      return success;
      // if the success field in the mutation response is true
    });
  }

  // Future<void> resumeService(String packageId) async {
  //   final List<ServicePackageModel>? packageList = state.value;
  //   // //print('[pd] The id to delete is $packageId');

  //   final makeRequest = await _repository.resumeService(
  //     int.parse(packageId),
  //   );

  //   makeRequest.fold((onLeft) {
  //     //print('Failed to delete service ${onLeft.message}');
  //     // run this block when you have an error
  //   }, (onRight) async {
  //     final success = onRight['success'] ?? false;
  //     if (!success) return;
  //     state = AsyncValue.data([
  //       for (final package in packageList!)
  //         if (package.id != packageId) package,
  //     ]);

  //     // //print('[pd] $onRight');
  //     //print('successfully deleted service');
  //     // if the success field in the mutation response is true
  //   });
  // }

  Future<void> deleteService(String packageId) async {
    final List<ServicePackageModel>? packageList = state.value;
    // //print('[pd] The id to delete is $packageId');

    final makeRequest = await _repository.deleteService(
      int.parse(packageId),
    );

    makeRequest.fold((onLeft) {
      //print('Failed to delete service ${onLeft.message}');
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (!success) return;
      state = AsyncValue.data([
        for (final package in packageList!)
          if (package.id != packageId) package,
      ]);

      // //print('[pd] $onRight');
      //print('successfully deleted service');
      toastContainer(text: "Service deleted successfully");
      // if the success field in the mutation response is true
    });
  }

  Future<bool> likeService(String packageId) async {
    bool success = false;
    final makeRequest = await _repository.likeService(
      int.parse(packageId),
    );

    makeRequest.fold((onLeft) {
      //print('Failed to like service ${onLeft.message}');

      // run this block when you have an error
    }, (onRight) async {
      success = onRight['success'] ?? false;
      if (!success) return;
      final currentData = state.value;
      state = AsyncValue.data([
        for (ServicePackageModel package in currentData!)
          if (package.id == packageId) package.copyWith(likes: package.likes! + 1, userLiked: success) else package,
      ]);

      // //print('[pd] $onRight');
      //print('successfully liked service');
      // if the success field in the mutation response is true
    });

    return success;
  }

  Future<void> saveService(String packageId) async {
    final makeRequest = await _repository.saveService(
      int.parse(packageId),
    );

    makeRequest.fold((onLeft) {
      //print('Failed to save service ${onLeft.message}');
      // run this block when you have an error
    }, (onRight) async {
      final success = onRight['success'] ?? false;
      if (!success) return;

      final currentData = state.value;
      state = AsyncValue.data([
        for (ServicePackageModel package in currentData!)
          if (package.id == packageId) package.copyWith(saves: package.saves! + 1) else package
      ]);

      //print('successfully saved service');
    });
  }

  // Future<void> getUnavailableDays({int? pageCount, int? pageNumber}) async {
  //   // //print('[pd] The id to delete is $packageId');

  //   final makeRequest = await _repository.getUnavailableDays(
  //     pageCount: pageCount,
  //     pageNumber: pageNumber,
  //   );

  //   return makeRequest.fold((left) {
  //     //print('Failed to fetch days');
  //     return [];
  //   }, (right) {
  //     //print('Failed to fetch days');
  //     final dList = right.map((e) => UnavailableDaysModel.fromJson(e));
  //     // return right;
  //     return dList.toList();
  //   });
  // }

  Future<bool> updatePackage(ServicePackageModel model, {ValueChanged<ServicePackageModel>? onSuccessCallback, XFile? image}) async {
    final List? banners = await bannerUploader();
    if (banners == null) {
      return false;
    }

    final List<ServicePackageModel>? packageList = state.value;
    final response = await _repository.updateService(
      serviceId: int.parse(model.id),
      period: model.servicePricing.toString(),
      title: model.title,
      description: model.description,
      price: model.price,
      deliverablesType: model.deliverablesType!,
      serviceLocation: model.serviceLocation.apiValue,
      deliveryTimeline: model.delivery,
      usageType: model.usageType,
      usageLength: model.usageLength,
      isDigitalContent: model.isDigitalContentCreator,
      hasAdditionalServices: model.hasAdditional,
      percentDiscount: model.percentDiscount,
      faqs: model.faq!.map((e) => {"answer": e.answer, "question": e.question}).toList(),
      // Todo {service fix}
      // banner: serviceBannerUrl ?? model.bannerUrl,
      banner: banners,
      initialDeposit: model.initialDeposit,
    );

    return response.fold((onLeft) {
      //print('failed to update service ${onLeft.message}');
      // run this block when you have an error

      // VWidgetShowResponse.showToast(
      //   ResponseEnum.failed,
      //   message: 'Error updating service ${onLeft.message}',
      // );
      return false;
    }, (onRight) async {
      final isSuccess = onRight['success'] ?? false;
      if (isSuccess) {
        // VWidgetShowResponse.showToast(
        //   ResponseEnum.sucesss,
        //   message: onRight['message'],
        // );
        final serviceMap = onRight['service'] as Map<String, dynamic>;
        final updatedService = ServicePackageModel.fromMiniMap(serviceMap);
        //print('555555555555555555555 ${packageList?.length}');
        // //print('555555555555555555555 $updatedService');

        state = AsyncValue.data([
          for (final package in packageList!)
            if (package.id == updatedService.id)
              package.copyWith(
                price: updatedService.price,
                title: updatedService.title,
                description: updatedService.description,
                serviceType: updatedService.serviceType,
                delivery: updatedService.delivery,
                usageType: updatedService.usageType,
                usageLength: updatedService.usageLength,
                servicePricing: updatedService.servicePricing,
                percentDiscount: updatedService.percentDiscount,
                isDigitalContentCreator: updatedService.isDigitalContentCreator,
                hasAdditional: updatedService.hasAdditional,
                banner: updatedService.banner,

                // Todo {service fix}
                // bannerUrl: updatedService.bannerUrl,
                initialDeposit: updatedService.initialDeposit,
              )
            else
              package,
        ]);
        if (onSuccessCallback != null) {
          onSuccessCallback(updatedService);
        }

        return true;
      } else {
        VWidgetShowResponse.showToast(
          ResponseEnum.failed,
          message: onRight['message'],
        );
      }
      return false;

      //print(onRight);
      //print('successful updated service');
      // if the success field in the mutation response is true
    });
  }

  /*
    SERVICE BANNER UPLOADER FUNCTION USES THRE serviceImagesProvider to access the banners
  */
  Future<List<dynamic>?> bannerUploader() async {
    final imagesToUpload = ref.read(serviceImagesProvider);
    //print('[mages] ${imagesToUpload.length}');
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
        //print("[mages] uploading banner files ");
        serviceBannerMap = await _uploadBanner(filesToUpload);
      }

      //print('uploaded files is s s s s s  $serviceBannerMap');
      if (filesToUpload.isNotEmpty && serviceBannerMap == null) {
        return null;
      }

      serviceBannerMap = [...existingBanners, ...?serviceBannerMap];
      // } else if (filesToUpload.isNotEmpty) {
    } else {
      serviceBannerMap = [];
    }
    return serviceBannerMap;
  }
}

//SERVICE TYPE PROVIDER
final serviceTypeProvider = FutureProvider((ref) async {
  final repo = ServicesRepository.instance;

  final result = await repo.allServiceTypes();

  return result.fold((left) => throw (left.message), (right) => right);
});
