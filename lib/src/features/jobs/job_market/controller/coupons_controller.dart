// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/coupon/repository/saved_coupon_repo.dart';

import '../model/coupons_model.dart';
import '../repository/coupons_repo.dart';

final allCouponsSearchProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

final allCouponsProvider = AsyncNotifierProvider.autoDispose<
    AllCouponsController, List<AllCouponsModel>>(AllCouponsController.new);

class AllCouponsController
    extends AutoDisposeAsyncNotifier<List<AllCouponsModel>> {
  final _repository = AllCouponsRepository.instance;

  int _pageCount = 10;
  int _currentPage = 1;
  int _allCouponsTotalNumber = 0;
  @override
  Future<List<AllCouponsModel>> build() async {
    state = const AsyncLoading();
    final searchTerm = ref.watch(allCouponsSearchProvider);
    await getAllCoupons(pageNumber: _currentPage, search: searchTerm);
    return state.value!;
  }

  Future<void> getAllCoupons({int? pageNumber, String? search}) async {
    final res = await _repository.getAllCoupons(
        search: search, pageNumber: pageNumber, pageCount: _pageCount);

    return res.fold((left) {

      return [];
    }, (right) {
      _allCouponsTotalNumber = right['allCouponsTotalNumber'];
      final List allServicesData = right['allCoupons'];
      final newState = allServicesData.map((e) => AllCouponsModel.fromJson(e));

      final currentState = state.valueOrNull ?? [];
      if (pageNumber == 1) {
        state = AsyncData(newState.toList());
      } else {
        if (currentState.isNotEmpty &&
            newState.any((element) => currentState.last.id == element.id)) {
          return;
        }

        state = AsyncData([...currentState, ...newState]);
      }
      _currentPage = pageNumber!;
    });
  }

  Future<void> fetchMoreData() async {
    final canLoadMore =
        (state.valueOrNull?.length ?? 0) < _allCouponsTotalNumber;

    if (canLoadMore) {
      await getAllCoupons(pageNumber: _currentPage + 1);
      // ref.read(isFeedEndReachedPallCouponsProviderrovider.notifier).state =
      //     itemPositon < feedTotalItems;
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < _allCouponsTotalNumber;
  }

  // Future<void> recordCouponCopy(int couponId) async {
  //   final res = await _repository.registerCouponCopy(
  //     couponId: couponId,
  //   );

  //   return res.fold((left) {

  //     return [];
  //   }, (right) {
  //   });
  // }
}

final recordCouponCopyProvider =
    FutureProvider.family.autoDispose<void, String>((ref, arg) async {
  final id = int.parse(arg);
  final res = await AllCouponsRepository.instance.registerCouponCopy(
    couponId: id,
  );

  return res.fold((left) {

    return [];
  }, (right) {
  });
});

//*
//
//////////Hottest Coupons
final hottestCouponsProvider =
    AsyncNotifierProvider<HottestCouponsController, List<AllCouponsModel>>(
        HottestCouponsController.new);

class HottestCouponsController extends AsyncNotifier<List<AllCouponsModel>> {
  final _repository = AllCouponsRepository.instance;

  int _pageCount = 10;
  @override
  Future<List<AllCouponsModel>> build() async {
    state = const AsyncLoading();
    // final searchTerm = ref.watch(allCouponsSearchProvider);
    await getHottestCoupons();
    return state.value!;
  }

  Future<void> getHottestCoupons() async {
    final res = await _repository.getHottestCoupons(dataCount: _pageCount);

    return res.fold(
      (left) {
        // run this block when you have an error
        return;
      },
      (right) async {

        final data = right['hottestCoupons'] as List?;

        if (data == null) {
          state = AsyncData([]);
          return;
        }
        if (data.isNotEmpty) {
          List<AllCouponsModel> models = [];
          try {
            models = data
                .map<AllCouponsModel>(
                    (e) => AllCouponsModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
          }
          // return models;
          state = AsyncData(models);
          // RecommendedJobs = Recommended;
        }
        return;
        // return RecommendedJobs;
        // if the success field in the mutation response is true
      },
    );
    // return res.fold((left) {
    //   return [];
    // }, (right) {
    //   _allCouponsTotalNumber = right['allCouponsTotalNumber'];
    //   final List allServicesData = right['allCoupons'];
    //   final newState = allServicesData.map((e) => AllCouponsModel.fromJson(e));

    //   final currentState = state.valueOrNull ?? [];
    //   if (pageNumber == 1) {
    //     state = AsyncData(newState.toList());
    //   } else {
    //     if (currentState.isNotEmpty &&
    //         newState.any((element) => currentState.last.id == element.id)) {
    //       return;
    //     }

    //     state = AsyncData([...currentState, ...newState]);
    //   }
    //   _currentPage = pageNumber!;
    // });
  }

  Future<bool> saveCoupon(String couponId) async {
    final _repository = SavedCouponRepository.instance;
    final saveSuccessful =
    await _repository.saveCoupon(couponId: int.parse(couponId));
    return saveSuccessful.fold((left) {
      return false;
    }, (right) {
      try {
        final bool success = right['success'] as bool;
        final couponList = state.value;
        if (saveSuccessful.isRight) {
          state = AsyncValue.data([
            for (final coupon in couponList!)
              if (coupon.id == couponId)
                coupon.copyWith(
                  userSaved: success,
                )
              else
                coupon,
          ]);
          return success;
        }

        state = AsyncValue.data([
          for (final coupon in couponList!)
            if (coupon.id == couponId) coupon.copyWith(userSaved: success) else coupon,
        ]);

        return success;
      } catch (e) {
        //print("AAAAAAA error parsing json response $e ${StackTrace.current}");
      }
      return false;
    });
  }

}
