import 'dart:async';

import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../created_gigs/controller/gig_controller.dart';
import '../../created_gigs/model/booking_id_tab.dart';
import '../../model/booking_data.dart';
import '../../model/booking_model.dart';
import '../repository/booking_repo.dart';

final selectedBookingProvider = Provider.family.autoDispose<BookingModel, BookingIdTab>((ref, bookingIdTab) {
  final items = ref.watch(myBookingsProvider(bookingIdTab.tab)).valueOrNull ?? [];
  final booking = items.firstWhere((element) => element.id == bookingIdTab.id);
  return booking;
});

final createBookingProvider = FutureProvider.family.autoDispose<String?, BookingData>((ref, data) async {
  final repo = BookingRepository.instance;
  final res = await repo.createBooking(bookingData: data.toMap());
  return res.fold((left) {
    logger.e(left.message);
    return null;
  }, (right) {
    logger.f(right);
    return right['booking']['id'];
  });
});
final bookingProvider = FutureProvider.family.autoDispose<BookingModel?, String>((ref, id) async {
  final repo = BookingRepository.instance;
  final bookingId = int.tryParse(id);
  final res = await repo.singleBooking(bookingId: bookingId!);
  return res.fold((left) {
    return null;
  }, (right) {
    final booking = BookingModel.fromMap(right);
    return booking;
  });
});

///address for booking booking services with address
final servicebookingAddressProvider = StateProvider.autoDispose<String?>((ref) => null);

/// boolean provider for expressDelivery for services
final serviceBookingExpressDelivery = StateProvider.autoDispose((ref) => false);

///serviceTier price holder for booking
final serviceTierPriceProvider = StateProvider.autoDispose<double?>((ref) => null);

/// currently initiated booking id provider when making payment by default this value would be null
/// the value changes once a booking has been initiated
final currentBookingIdProvider = StateProvider.autoDispose<String?>((ref) => null);

///selected addon price provider
final serviceBookingAddProvider = StateProvider.autoDispose<double?>((ref) => null);

/// service booking total price for all selected features
final serviceBookingTotalPriceProvider = StateProvider.autoDispose<double?>((ref) => null);

final confirmPaymentProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, paymentRef) async {
  final repo = BookingRepository.instance;
  final res = await repo.confirmPayment(paymentRef: paymentRef);
  return res.fold((left) {
    return {};
  }, (right) {
    return right;
  });
  // return res;
});

final myBookingsProvider = AsyncNotifierProvider.family.autoDispose<MyBookingsNotifier, List<BookingModel>, BookingTab>(MyBookingsNotifier.new);

class MyBookingsNotifier extends AutoDisposeFamilyAsyncNotifier<List<BookingModel>, BookingTab> {
  int _totalDataCount = 0;
  int _currentPage = 1;
  int _pageCount = 8;
  final repo = BookingRepository.instance;

  int get totalBookings => _totalDataCount;

  String? getApiModuleString(BookingTab tab) {
    switch (tab) {
      case BookingTab.all:
        return null;
      default:
        return tab.name.toUpperCase();
    }
  }

  @override
  build(arg) async {
    _currentPage = 1;
    return await getMyBookings(pageNumber: _currentPage);
  }

  Future<List<BookingModel>> getMyBookings({
    required int pageNumber,
    bool isUpdateState = false,
  }) async {
    final response = await repo.myBookings(pageNumber: pageNumber, pageCount: _pageCount);

    return response.fold((left) {
      return [];
    }, (right) {
      _totalDataCount = right['bookedMeTotalNumber'] as int;
      final List bookings = right['bookedMe'];

      if (pageNumber == 1) {
        final newState = bookings.map((e) => BookingModel.fromMap(e)).toList();
        return newState;
      } else {
        final newState = bookings.map((e) => BookingModel.fromMap(e)).toList();
        final currentState = state.valueOrNull ?? [];

        state = AsyncData([...currentState, ...newState]);
        _currentPage = pageNumber;
      }
      return [];
    });
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      await getMyBookings(pageNumber: _currentPage + 1, isUpdateState: true);
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;

  Future<void> startBooking(String id) async {
    final repo = BookingRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return;
    final res = await repo.startBooking(bookingId: _id);
    return res.fold((left) {
      return {};
    }, (right) {
      // final newState = BookingModel.fromMap(right['booking']);
      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([
      //   for (var x in currentState)
      //     if (x.id == newState.id) newState else x,
      // ]);
      // return right;
    });
  }

  Future<void> bookieMarkBookingCompleted(String id) async {
    final repo = BookingRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return;
    final res = await repo.bookieCompleteBooking(bookingId: _id);
    return res.fold((left) {
      return {};
    }, (right) {
      // final newState = BookingModel.fromMap(right['booking']);
      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([
      //   for (var x in currentState)
      //     if (x.id == newState.id) newState else x,
      // ]);
      // return right;
    });
  }

  Future<void> bookerConfirmBookingCompleted(String id) async {
    //dev.log('>>>>Creating payment ID: $id<<<<<<');
    final repo = BookingRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return;
    final res = await repo.bookerCompleteBooking(bookingId: _id);
    return res.fold((left) {
      //dev.log('Error creating payment ${left.message}');
      return {};
    }, (right) {
      // //dev.log('Success stripe payment ${right}');
      // final newState = BookingModel.fromMap(right['booking']);
      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([
      //   for (var x in currentState)
      //     if (x.id == newState.id) newState else x,
      // ]);
      // return right;
    });
    // return res;
  }
}

typedef VOID = void;

final bookingPaymentNotifierProvider = AsyncNotifierProvider(BookingPaymentNotifier.new);

class BookingPaymentNotifier extends AsyncNotifier {
  late final _repo = BookingRepository.instance;
  @override
  FutureOr build() async {}

  Future<void> createBookingPayment(String bookingId) async {
    state = AsyncLoading();

    final result = await _repo.createPayment(bookingId: int.parse(bookingId));

    state = result.fold(
      (p0) {
        logger.e(p0.message);
        return AsyncError(p0.message, StackTrace.current);
      },
      (p0) {
        logger.d(p0);
        return AsyncData(p0);
      },
    );

    logger.f(state);
  }

  Future<void> makePayment(String clientSecret) async {
    state = AsyncLoading();
    logger.d('Make Payment was called');
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'VModel',
        ),
      );
      final displaySheet = await _displayPaymentSheet();
      state = displaySheet.fold(
        (p0) {
          logger.e(p0.error);
          return AsyncError(p0.error, StackTrace.current);
        },
        (p0) => AsyncData(p0),
      );
    } catch (e) {
      if (e is StripeConfigException) {
        logger.e(e.message);
        state = AsyncError(e.message, StackTrace.current);
      } else {
        logger.e(e.toString());
        state = AsyncError(e.toString(), StackTrace.current);
      }
    }
  }

  Future<Either<StripeException, dynamic>> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return Right({});
    } on StripeException catch (e) {
      return Left(e);
    }
  }
}
