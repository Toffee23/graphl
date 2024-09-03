import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/models/rating_model.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/reviews/repositories/review_repo.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

final reviewProvider = AsyncNotifierProvider.autoDispose<ReviewNotifier, List<Review>>(() => ReviewNotifier());
final reviewsFilterProvider = StateProvider<Map<String, bool>>((ref) => {
      "all": true,
      "reviewsForMe": false,
      "reviewsByMe": false,
      "autoReview": false,
    });
final reviewsOrderProvider = StateProvider(
  (ref) => {
    "Most Recent": "desc",
    "Earliest": "asc",
  },
);

final selectedReviewsOrderProvider = StateProvider((ref) => ref.watch(reviewsOrderProvider).keys.first);

class ReviewNotifier extends AutoDisposeAsyncNotifier<List<Review>> {
  final _repository = ReviewRepository.instance;

  int _reviewsTotalNumber = 0;
  int _pageCount = 20;
  int _currentPage = 1;
  String username = globalUsername ?? "";

  @override
  Future<List<Review>> build() async {
    state = const AsyncLoading();
    // _currentPage = 1;
    logger.d(ref.watch(reviewsOrderProvider).entries.singleWhere((element) => element.key == ref.watch(selectedReviewsOrderProvider)));
    await getReviews(
      ref.watch(reviewsFilterProvider),
      ref.watch(reviewsOrderProvider).entries.singleWhere((element) => element.key == ref.watch(selectedReviewsOrderProvider)).value,
    );
    return state.value ?? [];
  }

  Future<void> getReviews(Map<String, bool> filters, String? order) async {
    final res = await _repository.userReviews(filters, order);

    return res.fold((left) {
      logger.e(left.message);
      state = AsyncError(left.message, StackTrace.current);
    }, (right) {
      final List reviewsData = right['userReviews'];

      state = AsyncData(reviewsData.map<Review>((e) => Review.fromJson(e as Map<String, dynamic>)).toList());
    });
  }

  // Future<void> fetchMoreData() async {
  //   //print("Remote job getting more data from page ===================================>");
  //   final canLoadMore = (state.valueOrNull?.length ?? 0) < _reviewsTotalNumber;

  //   if (canLoadMore) {
  //     await getReviews(pageNumber: _currentPage + 1, username: username, pageCount: _pageCount);
  //     // ref.read(isFeedEndReachedProvider.notifier).state =
  //     //     itemPositon < feedTotalItems;
  //   }
  // }

  // bool canLoadMore() {
  //   return (state.valueOrNull?.length ?? 0) < _reviewsTotalNumber;
  // }

  /// Function to Rate User
  // Future<bool> rateUser({
  //   required String username,
  //   required String comment,
  //   required String rating,
  // }) async {
  //   final response = await _repository.rateUser(username: username, rating: rating, comment: comment);
  //   return response.fold((left) {
  //     VWidgetShowResponse.showToast(ResponseEnum.failed, message: left.message);

  //     //print(left.message);
  //     return false;
  //   }, (right) {
  //     bool success = true;
  //     if (success) {
  //       VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "Thanks for leaving a feedback.");
  //     }
  //     return success;
  //   });
  // }

  // Future<bool> editReview({
  //   required String username,
  //   required int reviewId,
  //   required String comment,
  //   required String rating,
  // }) async {
  //   final response = await _repository.editReview(reviewId: reviewId, username: username, rating: rating, comment: comment);
  //   return response.fold((left) {
  //     VWidgetShowResponse.showToast(ResponseEnum.failed, message: left.message);

  //     //print(left.message);
  //     return false;
  //   }, (right) {
  //     bool success = true;
  //     if (success) {
  //       VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "Success");
  //       ref.invalidateSelf();
  //     }
  //     return success;
  //   });
  // }

  Future<bool> deleteReviewReply({required String replyId, required context}) async {
    final response = await _repository.deleteReviewReply(replyId: int.parse(replyId));
    return response.fold((left) {
      logger.e(left.message);
      VWidgetShowResponse.showToast(ResponseEnum.failed, message: left.message);

      return false;
    }, (right) {
      // VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "Success");
      SnackBarService().showSnackBar(message: "Success", context: context);

      // ref.invalidateSelf();
      return true;
    });
  }

  Future<bool> updateReview({
    required String reviewText,
    required int reviewId,
    required String rating,
    required String reviewType,
  }) async {
    final response = await _repository.updateReview(reviewText: reviewText, reviewId: reviewId, rating: rating, reviewType: reviewType);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed, message: left.message);

      return false;
    }, (right) {
      bool success = true;
      if (success) {
        VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "Review updated");
        ref.invalidateSelf();
      }
      return success;
    });
  }

  Future<bool> createOrReplyReview({
    required String reply,
    required int reviewId,
    required String reviewType,
  }) async {
    final response = await _repository.createOrUpdateReply(reply: reply, reviewId: reviewId, reviewType: reviewType);
    return response.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed, message: left.message);

      return false;
    }, (right) {
      bool success = true;
      if (success) {
        //VWidgetShowResponse.showToast(ResponseEnum.sucesss, message: "Reply sent");
        ref.invalidateSelf();
      }
      return success;
    });
  }
}
