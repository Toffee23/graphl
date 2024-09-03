// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/coupon/model/coupon_model.dart';
import 'package:vmodel/src/features/coupon/repository/saved_coupon_repo.dart';

final couponBoardsSearchProvider =
    StateProvider.autoDispose<String?>((ref) => '');
final refreshingBoard = StateProvider.autoDispose<bool>((ref) => true);

final couponBoardsTotalNumberProvider = StateProvider<int>((ref) => 0);

final boardCouponsProvider = AsyncNotifierProvider.family
    .autoDispose<CouponNotifier, List<CouponBoardModel>, String?>(
        CouponNotifier.new);

final allCouponsProvider = AsyncNotifierProvider.family
    .autoDispose<AllCouponNotifier, List<SavedCouponModel>, String?>(
        AllCouponNotifier.new);

final boardCouponProvider = AsyncNotifierProvider.family
    .autoDispose<BoardCouponNotifier, List<CouponModel>, int>(
        BoardCouponNotifier.new);

class CouponNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CouponBoardModel>, String?> {
  int _totalCouponBoards = 0;
  int _currentPage = 1;
  int _pageCount = 10;

  final _repository = SavedCouponRepository.instance;
  @override
  Future<List<CouponBoardModel>> build(username) async {
    final response = await _repository.couponBoards(
        pageNumber: _currentPage, pageCount: _pageCount);

    return response.fold((left) {
      //print('Failed fetching coupoons 2');
      return [];
    }, (right) {
      //print('went right');
      //print('went right $right');
      _totalCouponBoards = right.first['numberOfCoupons'] as int;
      ref.read(couponBoardsTotalNumberProvider.notifier).state =
          _totalCouponBoards;

      if (right.isNotEmpty) {
        final parsedList = right.map<CouponBoardModel>((e) {
          return CouponBoardModel.fromMap(e);
        }).toList();

        if (_currentPage > 1) {
          // _currentPage = pageNumber;
          state =
              AsyncValue.data([...(state.valueOrNull ?? []), ...parsedList]);
        }

        //print('parsedList');
        //print(parsedList);
        return parsedList;
      }

      return [];
    });
  }

  Future<Map<String, bool>> createBoardAndAddCoupon(
      String id, String boardTitle) async {
    final response = await _repository.createCouponBoard(boardTitle);

    return response.fold((left) {
      //print("left ${left.message}");

      return {'-1': false};
    }, (right) async {
      //print('"right right"');
      //print("right ${right}");
      bool success = (right['success'] as bool?) ?? false;

      if (!success) return {'-1': false};
      final board = CouponBoardModel.fromMap(right['couponBoard']);
      final saveSuccessful = await _repository.saveCoupon(
          couponId: int.parse(id), boardId: int.parse(board.id!));
      if (saveSuccessful.isRight) {
        //Refresh state
        ref.invalidateSelf();
      }
      return {board.id!: saveSuccessful.isRight};
    });
  }

  Future<bool> addCouponToBoard(String couponId, String boardId) async {
    final saveSuccessful = await _repository.saveCoupon(
        couponId: int.parse(couponId), boardId: int.parse(boardId));
    if (saveSuccessful.isRight) {
      ref.invalidateSelf();
    }
    return saveSuccessful.isRight;
  }

  Future<bool> saveCoupon(String couponId) async {
    final saveSuccessful =
        await _repository.saveCoupon(couponId: int.parse(couponId));
    if (saveSuccessful.isRight) {
      ref.invalidateSelf();
    }
    return saveSuccessful.isRight;
  }

  Future<void> fetchMoreData() async {
    final canLoadMore = (state.valueOrNull?.length ?? 0) < _totalCouponBoards;

    //print('[slko8] The new problem $canLoadMore total: $_totalCouponBoards');
    if (canLoadMore) {
      await _repository.couponBoards(
          pageNumber: _currentPage + 1, pageCount: _pageCount);
    }
  }

  void updateItemState(CouponBoardModel board) {
    final currentState = state.valueOrNull ?? [];
    state = AsyncData([
      for (var item in currentState)
        if (item.id == board.id) board else item,
    ]);
  }
}

class AllCouponNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<SavedCouponModel>, String?> {
  int _currentPage = 1;
  int _pageCount = 100;
  final _repository = SavedCouponRepository.instance;

  @override
  Future<List<SavedCouponModel>> build(username) async {
    final response = await _repository.savedCoupons(
        pageNumber: _currentPage, pageCount: _pageCount);

    return response.fold((left) {
      return [];
    }, (right) {
      if (right.isNotEmpty) {
        final parsedList = right.map<SavedCouponModel>((e) {
          return SavedCouponModel.fromMap(e);
        }).toList();
        return parsedList;
      }

      return [];
    });
  }
}

class BoardCouponNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CouponModel>, int> {
  int _currentPage = 1;
  int _pageCount = 10;

  final _repository = SavedCouponRepository.instance;
  @override
  Future<List<CouponModel>> build(boardId) async {
    final response = await _repository.boardCoupons(
        pageNumber: _currentPage, pageCount: _pageCount, boardId: boardId);

    return response.fold((left) {
      //print('Failed fetching coupoons 1');
      return [];
    }, (right) {
      if (right.isNotEmpty) {
        final parsedList = right.map<CouponModel>((e) {
          return CouponModel.fromMap(e);
        }).toList();

        return parsedList;
      }

      return [];
    });
  }
}

// Duration get dateDuration => endTime - startTime;

//Generated

