import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_data.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_pricing_option.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_status.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_type.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/payment_data_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/my_bookings/repository/booking_repo.dart';
import 'package:vmodel/src/features/vmodel_credits/models/leaderboard_model.dart';
import 'package:vmodel/src/features/vmodel_credits/models/achievement_model.dart';

import '../models/vmc_history_model.dart';
import '../repository/vmc_history_repo.dart';

final vmcTotalProvider = StateProvider<int>((ref) {
  return 0;
});

final achievementProvider = FutureProvider.family<List<AchievementModel>, String?>(
  (ref, username) async {
    final result = await VMCRepository.instance.userAchievement(username);

    return result.fold(
      (left) => throw left.message,
      (right) => right,
    );
  },
);

final vmcRecordProvider = AutoDisposeAsyncNotifierProvider<VMCHistoryNotifier, List<VMCHistoryModel>?>(VMCHistoryNotifier.new);

class VMCHistoryNotifier extends AutoDisposeAsyncNotifier<List<VMCHistoryModel>?> {
  VMCRepository? _repository;

  int _totalDataCount = 0;
  int _currentPage = 1;

  @override
  // Future<VMCRecordModel?> build() async {
  Future<List<VMCHistoryModel>?> build() async {
    _repository = VMCRepository.instance;

    // final vmcRecord = await _repository!.vmcHistory();
    // VMCRecordModel? initialState;
    // vmcRecord.fold((left) {
    //   //print("${left.message} ${StackTrace.current}");
    // }, (right) {
    //   //print('more info ${right['vmcrecord']}');
    //   try {
    //     final newState = VMCRecordModel.fromJson(right);
    //     initialState = newState;
    //   } catch (e) {
    //     //print(" $e ${StackTrace.current}");
    //   }
    // });
    _currentPage = 1;
    return await fetchData(page: _currentPage, addToState: false);

    // return initialState;
  }

  Future<List<VMCHistoryModel>?> fetchData({required int page, bool addToState = true}) async {
    final vmcRecord = await _repository!.vmcHistory(pageNumber: page, pageCount: 20);
    return vmcRecord.fold((left) {
      //print("${left.message} ${StackTrace.current}");
      return null;
    }, (right) {
      ref.read(vmcTotalProvider.notifier).state = right['vmcPointsTotal'] ?? 0;
      _totalDataCount = right['vmcPointsHistoryTotalNumber'];
      final historyData = right['vmcPointsHistory'] as List;
      //print('[lsa1] more info ${historyData.length}');
      try {
        final history = historyData.map((e) => VMCHistoryModel.fromMap(e));
        //print('[lsa2] more info ${history.length}');
        // final newState = VMCRecordModel.fromJson(right);
        // initialState = newState;
        if (addToState) {
          final currentState = state.valueOrNull ?? [];
          state = AsyncData([...currentState, ...history]);
          return null;
        } else {
          return history.toList();
        }
      } catch (e) {
        //print(" $e ${StackTrace.current}");
      }
      return null;
    });
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      await fetchData(page: _currentPage + 1);
    }
  }
}

final vmcLeaderboardProvider = AutoDisposeAsyncNotifierProvider<VMCLeaderboardNotifeier, List<VMCLeaderboardModel>>(VMCLeaderboardNotifeier.new);

class VMCLeaderboardNotifeier extends AutoDisposeAsyncNotifier<List<VMCLeaderboardModel>> {
  final _repository = VMCRepository.instance;
  @override
  FutureOr<List<VMCLeaderboardModel>> build() async {
    state = AsyncLoading();
    return await vmcLeaderBoard();
  }

  Future<List<VMCLeaderboardModel>> vmcLeaderBoard() async {
    final response = await _repository.vmcLeaderboard();
    return response.fold((left) {
      //print(left.message);
      return [];
    }, (right) {
      final List leaderboardList = right['leaderboard'];
      if (leaderboardList.isNotEmpty) {
        return leaderboardList.map((e) => VMCLeaderboardModel.fromJson(e)).toList();
      }
      return [];
    });
  }
}

final bookingStateNotiferProvider = StateNotifierProvider<BookingStateNotifier, BookingModel?>((ref) => BookingStateNotifier());

class BookingStateNotifier extends StateNotifier<BookingModel?> {
  BookingStateNotifier() : super(null);

  final _repository = BookingRepository.instance;

  Future<BookingModel?> init({String? id}) async {
    final bookingId = int.tryParse(id!);

    final res = await _repository.singleBooking(bookingId: bookingId!);

    return res.fold((left) {
      return null;
    }, (right) {

      BookingModel data = BookingModel(
          id: right['id'],
          module: BookingModule.values.byName(right['module'] as String),
          moduleId: right['moduleId'],
          title: right['title'],
          price: right['price'],
          pricingOption: BookingPricingOption.values.byName(right['pricingOption'] as String),
          bookingType: BookingType.values.byName(right['bookingType'] as String),
          haveBrief: right['haveBrief'],
          deliverableType: right['deliverableType'],
          user: right['user'] != null ? VAppUser.fromMinimalMap(right['user'] as Map<String, dynamic>) : null,
          // startDate: right['startDate'],
          // completionDate: right['completionDate'],
          // dateDelivered: right['dateDelivered'],
          startDate: DateTime.parse(right['startDate'] as String),
          completionDate: right['completionDate'] != null ? DateTime.parse(right['completionDate']) : null,
          dateDelivered: right['dateDelivered'] != null ? DateTime.parse(right['dateDelivered']) : null,
          address:  Map<String, dynamic>.from(jsonDecode(right['address'] as String)),
          status:  BookingStatus.byApiValue(right['status'] as String),
          expectDigitalContent: right['expectDigitalContent'],
          dateCreated:  DateTime.parse(right['dateCreated'] as String),
          lastUpdated: DateTime.parse(right['lastUpdated'] as String),
          deleted: right['deleted'],
          paymentSet: List<PaymentData>.from(
          (right['paymentSet'] as List).map<PaymentData>(
            (x) => PaymentData.fromMap(x as Map<String, dynamic>),
          ),
        ),
          userReviewSet: []);

      final booking = data;
      state = booking;
      return booking;
    });
  }
}
