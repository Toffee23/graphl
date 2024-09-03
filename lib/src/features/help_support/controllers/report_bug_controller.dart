import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/network/urls.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/features/create_posts/controller/create_post_controller.dart';
import 'package:vmodel/src/features/create_posts/controller/cropped_data_controller.dart';
import 'package:vmodel/src/features/create_posts/models/image_upload_response_model.dart';
import 'package:vmodel/src/features/help_support/models/report_model.dart';
import 'package:vmodel/src/features/help_support/repository/report_bug_repo.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

final ticketProvider =
AsyncNotifierProvider.autoDispose<ReportUserNotifier, List<TicketModel>>(
        () => ReportUserNotifier());

class ReportUserNotifier extends AutoDisposeAsyncNotifier<List<TicketModel>> {
  final _repository = TicketRepository.instance;

  int _ticketsTotalNumber = 0;
  int _pageCount = 20;
  int _currentPage = 1;

  @override
  Future<List<TicketModel>> build() async {
    state = const AsyncLoading();
    _currentPage = 1;
    await getAllMyTickets(pageNumber: _currentPage, pageCount: _pageCount);
    //print(state.value);
    return state.value!;
  }

  Future<void> getAllMyTickets({int? pageNumber, int? pageCount}) async {
    final res = await _repository.getMyTickets(
      pageCount: _pageCount,
      pageNumber: pageNumber ?? 1,
    );
    return res.fold((left) {
      //print('in AsyncBuild left is .............. ${left.message}');
      //print('Fetching tickets===================>>>');

      return [];
    }, (right) {
      _ticketsTotalNumber = right['userTicketsTotalNumber'];
      //print(right['userTicketsTotalNumber']);
      final List tickets = right['userTickets'];
      final currentState = state.valueOrNull ?? [];
      final newState = tickets
          .map<TicketModel>(
              (e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (pageNumber == 1) {
        state = AsyncData(newState.toList());
      } else {
        if (currentState.isNotEmpty &&
            newState.any((element) => currentState.last.id == element.id)) {
          return;
        }

        state = AsyncData([...currentState, ...newState]);
      }
      _currentPage = pageNumber! + 1;
      //print('Fetched tickets===================>>>');
    });
  }

  ///Fetch More Tickets
  Future<void> fetchMoreData() async {
    //print("Tickets getting more data from page ===================================>");
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _ticketsTotalNumber;

    if (canLoadMore) {
      await getAllMyTickets(pageNumber: _currentPage);
      // ref.read(isFeedEndReachedProvider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  Future<bool> reportIssue({
    List<File?>? images,
    required String report,
    required String subject,
  }) async {
    List<ImageUploadResponseModel> imageList = [];
    if(images == null){
      return false;
    }
    //assert(images != null);

    //Set it to zero percent so that we can go back to the post page when there
    //is an error.
    ref.read(uploadProgressProvider.notifier).state = 0.01;
    final Either<CustomException, String?> uploadResult;
    uploadResult = await _repository.uploadFiles(
      VUrls.postMediaUploadUrl, images,
      onUploadProgress: (sent, total) {
        final percentage = sent / total;
        //print('[$percentage] @@@@@@@@@@@@@@@@@@@@ $sent \\ $total');
        ref.read(uploadProgressProvider.notifier).state = sent / total;
      }
    );

    uploadResult.fold((left) {
      //print("Here error uploading file");
      //print("Error ${left.message}");
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Error uploading files");
      //clear contents to free memory
      _resetUploadIndicator();
    }, (right) async {
      if (right == null) {
        return false;
      }
      VMHapticsFeedback.mediumImpact();
      final map = json.decode(right);

      final uploadedFilesMap = map["data"] as List<dynamic>;
      String baseUrl = map['base_url'] ?? '';
      if (uploadedFilesMap.isNotEmpty) {
        final uploadedImages = uploadedFilesMap
            .map((e) => ImageUploadResponseModel.fromMap(baseUrl, e))
            .toList();


        //print("!!!!!!!!!!!!!!!!! ${uploadedImages.first.file_url}");

        //Send response from upload to backend API
        final response = await _repository.createTicket(attachment: uploadedImages[0].file_url, report: report, subject: subject);
        return response.fold((left) {
          VWidgetShowResponse.showToast(ResponseEnum.failed,
              message: "Failed to report Bug");

          //print('Error reporting the ${left.message} ${StackTrace.current}');
        }, (right) {
          //print(right);
          bool success = true;
          if (success) {
            VWidgetShowResponse.showToast(ResponseEnum.sucesss,
                message: "Bug has been reported");
          }

          //print('Success reporting bug  ----------------------------->  $right');
          return success;
        });
      }
      return true;
    });
    return true;
  }

  Future<bool> reportIssueWithoutImage({
    required String report,
    required String subject,
  }) async {
    final response = await _repository.createTicket(attachment: "", report: report, subject: subject);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Failed to report Bug");

      //print('Error blocking the ${left.message} ${StackTrace.current}');
      return false;
    }, (right) {
      //print(right);
      bool success = true;
      if (success) {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss,
            message: "Bug has been reported");
      }

      //print('Success reporting bug  ----------------------------->  $right');
      return success;
    });
  }

  /// Function to Report User
  Future<bool> reportBug({
        required String osVersion,
        required String details,
        required String phoneType,
  }) async {
    final response = await _repository.reportBug(details: details, phoneType: phoneType, osVersion: osVersion);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Failed to report Bug");

      //print('Error blocking the ${left.message} ${StackTrace.current}');
      return false;
    }, (right) {
      //print(right);
      bool success = true;
      if (success) {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss,
            message: "Bug has been reported");
      }

      //print('Success reporting bug  ----------------------------->  $right');
      return success;
    });
  }

  /// Function to Report User
  Future<bool> reportUser({
        required String username,
        required String details,
        required String reason,
  }) async {
    final response = await _repository.reportAccount(details: details, username: username, reason: reason);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Failed to report $username");

      //print('Error blocking the ${left.message} ${StackTrace.current}');
      return false;
    }, (right) {
      //print(right);
      bool success = true;
      if (success) {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss,
            message: "$username has been reported");
      }

      //print('Success reporting user  ----------------------------->  $right');
      return success;
    });
  }

  void _resetUploadIndicator() {
    // ref.read(croppedImagesToUploadProviderx.notifier).state = [];
    ref.read(croppedImagesProvider.notifier).clearAll();
    ref.read(uploadProgressProvider.notifier).state = -1;
  }
}
