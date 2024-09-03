import 'dart:async';

import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/cache/local_storage.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/service_booking_model.dart';
import 'package:web_socket_channel/io.dart';

import '../../model/booking_model.dart';
import '../model/booking_id_tab.dart';
import '../repository/created_gigs_booking_repo.dart';

enum BookingTab { all, job, service, offer }

typedef BOOKING_ERROR = String;

final selectedGigProvider = Provider.family
    .autoDispose<BookingModel, BookingIdTab>((ref, bookingIdTab) {
  final items =
      ref.watch(userBookingsProvider(bookingIdTab.tab)).valueOrNull ?? [];
  final booking = items.firstWhere((element) => element.id == bookingIdTab.id);
  return booking;
});

/// this provider returns booking with pending payments
final pendingPaymentBookingsProvider = FutureProvider.autoDispose((ref) async {
  final repo = MyCreatedBookingsRepository.instance;

  final bookings =
      await repo.pendingPaymentBooking(pageCount: 2000, pageNumber: 1);
  return bookings.fold((left) {
    logger.e(left.message);
    throw left.message;
  }, (right) {
    logger.w(right);
    final List bookings = right['userPendingBookings'] as List;
    return bookings.map((e) => BookingModel.fromMap(e)).toList();
  });
});

final userBookingsProvider = AsyncNotifierProvider.family<UserBookingsNotifier,
    List<BookingModel>, BookingTab>(UserBookingsNotifier.new);

class UserBookingsNotifier
    extends FamilyAsyncNotifier<List<BookingModel>, BookingTab> {
  int _totalDataCount = 0;
  int _currentPage = 1;
  int _pageCount = 1000;
  final repo = MyCreatedBookingsRepository.instance;

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
    state = AsyncLoading();
    final List<BookingModel> bookings = [];
    if (arg == BookingTab.job) {
      final jobBooking = await ref
          .watch(jobBookingProvider.notifier)
          .getJobBooking(ref.watch(jobBookingProvider.notifier).currentPage);

      for (var job in jobBooking) {
        if (job.bookings != null) {
          bookings.addAll(job.bookings!);
        }
      }
    }
    if (arg == BookingTab.service) {
      final serviceBooking = await ref
          .watch(serviceBookingProvider.notifier)
          .getServiceBookings(
              ref.watch(serviceBookingProvider.notifier).currentPage);

      for (var service in serviceBooking) {
        bookings.addAll(service.bookings);
      }
    }
    return bookings;
  }

  Future<List<BookingModel>> userBookings({
    required int pageNumber,
    String? module,
    bool isUpdateState = false,
  }) async {
    final response = await repo.userBookings(
        module: module, pageNumber: pageNumber, pageCount: _pageCount);

    return response.fold((left) {
      logger.e(left.message);
      return [];
    }, (right) {
      _totalDataCount = right['iBookedTotalNumber'] as int;
      final List bookings = right['userBookings'] as List;
      //dev.log('####3www ${bookings.length} and total is $_totalDat aCount');

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

  @Deprecated('Needs Update ')
  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      await userBookings(pageNumber: _currentPage + 1, isUpdateState: true);
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;

  Future<void> bookerConfirmBookingCompleted(String id) async {
    //dev.log('{oxz} >>>>Confirming completion booking ID: $id<<<<<<');
    final repo = MyCreatedBookingsRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return;
    final res = await repo.bookerCompleteBooking(bookingId: _id);
    return res.fold((left) {
      logger.e(left.message);
      return left.message;
    }, (right) {
      // final newState = BookingModel.fromMap(right['booking']);
      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([newState]);
      return right;
    });
    // return res;
  }

  Future<Either<BOOKING_ERROR, void>> reviewBookedUser(String id,
      {required String rating, String? review}) async {
    logger.i('booking review initiated');
    final repo = MyCreatedBookingsRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) {
      return Left('Booking ID is required');
    }
    final res = await repo.reviewBookedUser(
        bookingId: _id, rating: rating, review: review);
    return res.fold((left) {
      logger.e('booking failed: ${left.message}');
      return Left(left.message);
    }, (right) {
      // final newState = BookingModel.fromMap(right['booking']);

      // logger.f('Review sent successfully ${right['review']}');
      // logger.f('Booking Status ${right['booking']['status']}');

      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([
      //   for (var x in currentState)
      //     if (x.id == newState.id) newState else x,
      // ]);
      return Right({});
    });
    // return res;
  }

  Future<Either<BOOKING_ERROR, void>> reviewBookingCreator(String id,
      {required String rating, String? review}) async {
    //dev.log('{oxz} >>>>Confirming completion booking ID: $id<<<<<<');
    final repo = MyCreatedBookingsRepository.instance;
    final _id = int.tryParse(id);
    if (_id == null) return Left('Invalid booking ID');
    final res = await repo.reviewBookingCreator(
        bookingId: _id, rating: rating, review: review);
    return res.fold((left) {
      logger.e(left.message);

      return Left(left.message);
      // return {

      // };
    }, (right) {
      // final newState = BookingModel.fromMap(right['booking']);
      // logger.f('Review sent successfully ${right['review']}');
      // logger.f('Booking Status ${right['booking']['status']}');
      // final currentState = state.valueOrNull ?? [];

      // state = AsyncData([
      //   for (var x in currentState)
      //     if (x.id == newState.id) newState else x,
      // ]);
      return Right({});
    });
    // return res;
  }
}

final bookingFilter = Provider(
  (ref) => {
    'All': 'All',
    'Applied': 'Applicant',
    'Created': 'Creator',
  },
);

final currentBookingFilter =
    StateProvider((ref) => ref.watch(bookingFilter).keys.first);

final jobBookingProvider =
    AsyncNotifierProvider<JobBookingNotifier, List<JobPostModel>>(
        JobBookingNotifier.new);
final isRefreshingBookingProvider = StateProvider((ref) => false);

class JobBookingNotifier extends AsyncNotifier<List<JobPostModel>> {
  int currentPage = 1;
  int pageCount = 10;
  int _totalDataCount = 0;
  final repo = MyCreatedBookingsRepository.instance;
  @override
  FutureOr<List<JobPostModel>> build() {
    if (!ref.watch(isRefreshingBookingProvider)) {
      _dispose();
    }

    return getJobBooking(currentPage);
  }

  int get totalBookings => _totalDataCount;

  void _dispose() {
    currentPage = 1;
  }

  Future<List<JobPostModel>> getJobBooking(int pageNumber) async {
    final result = await repo.getBookingsJob(
      pageCount: pageCount,
      pageNumber: pageNumber,
      filterBy: ref.watch(bookingFilter)[ref.watch(currentBookingFilter)],
    );
    return result.fold(
      (p0) {
        logger.e(p0.message);
        throw p0.message;
      },
      (p0) {
        _totalDataCount = p0['jobsTotalNumber'];

        try {
          final List jobsData = p0['userJobs'];

          if (pageNumber == 1) {
            final jobs = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();
            jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return jobs;
          } else {
            final data = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();

            currentPage = pageNumber;
            final currentState = state.valueOrNull ?? [];

            final jobs = [...currentState, ...data];

            jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return jobs;
          }
        } catch (e, st) {
          logger.e(e);
          logger.e(st);

          throw e.toString();
        }
      },
    );
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      final booking =
          await AsyncValue.guard(() => getJobBooking(currentPage + 1));
      state = booking;
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;
}

final serviceBookingProvider =
    AsyncNotifierProvider<ServiceBookingNotifier, List<ServiceBookingModel>>(
        ServiceBookingNotifier.new);

class ServiceBookingNotifier extends AsyncNotifier<List<ServiceBookingModel>> {
  int currentPage = 1;
  int pageCount = 10;
  int _totalDataCount = 0;
  final repo = MyCreatedBookingsRepository.instance;

  @override
  FutureOr<List<ServiceBookingModel>> build() {
    return getServiceBookings(currentPage);
  }

  int get totalBookings => _totalDataCount;

  Future<List<ServiceBookingModel>> getServiceBookings(int pageNumber) async {
    final result = await repo.getBookingsService(
      pageNumber: pageNumber,
      pageCount: pageCount,
      filterBy: ref.watch(bookingFilter)[ref.watch(currentBookingFilter)],
    );

    return result.fold(
      (p0) {
        logger.e(p0);
        throw p0.message;
      },
      (p0) {
        try {
          _totalDataCount = p0['allServicesTotalNumber'];
          final List servicessData = p0['userServices'];

          if (pageNumber == 1) {
            final services = servicessData
                .map<ServiceBookingModel>((e) =>
                    ServiceBookingModel.fromMap(e as Map<String, dynamic>))
                .toList();
            services.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return services;
          } else {
            final parsedServices = servicessData
                .map<ServiceBookingModel>((e) =>
                    ServiceBookingModel.fromMap(e as Map<String, dynamic>))
                .toList();

            currentPage = pageNumber;
            final currentState = state.valueOrNull ?? [];

            final services = [...currentState, ...parsedServices];

            services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return services;
          }
        } catch (e, st) {
          logger.e(e, stackTrace: st);
          throw e.toString();
        }
      },
    );
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      final booking =
          await AsyncValue.guard(() => getServiceBookings(currentPage + 1));
      state = booking;
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;
}

final jobRequestBookingProvider =
    AsyncNotifierProvider<JobRequestBookingNotifier, List<JobPostModel>>(
        JobRequestBookingNotifier.new);

class JobRequestBookingNotifier extends AsyncNotifier<List<JobPostModel>> {
  int _currentPage = 1;
  int _pageCount = 10;
  int _totalDataCount = 0;
  final repo = MyCreatedBookingsRepository.instance;
  @override
  FutureOr<List<JobPostModel>> build() {
    if (!ref.watch(isRefreshingBookingProvider)) {
      _dispose();
    }

    return _getJobBooking(_currentPage);
  }

  int get totalBookings => _totalDataCount;

  void _dispose() {
    _currentPage = 1;
  }

  Future<List<JobPostModel>> _getJobBooking(int pageNumber) async {
    final result = await repo.getBookingsJob(
        pageCount: _pageCount,
        pageNumber: pageNumber,
        filterBy: ref.watch(bookingFilter)[ref.watch(currentBookingFilter)],
        isRequested: true);
    return result.fold(
      (p0) {
        logger.e(p0.message);
        throw p0.message;
      },
      (p0) {
        _totalDataCount = p0['jobsTotalNumber'];

        try {
          final List jobsData = p0['userJobs'];

          if (pageNumber == 1) {
            final jobs = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();
            jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return jobs;
          } else {
            final data = jobsData
                .map<JobPostModel>(
                    (e) => JobPostModel.fromMap(e as Map<String, dynamic>))
                .toList();
            // jobs.sort((a, b) => b.bookings!.first.dateCreated.compareTo(a.bookings!.first.dateCreated));

            _currentPage = pageNumber;
            final currentState = state.valueOrNull ?? [];

            final jobs = [...currentState, ...data];

            jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return jobs;
          }
        } catch (e, st) {
          logger.e(e);
          logger.e(st);

          throw e.toString();
        }
      },
    );
  }

  Future<void> fetchMoreHandler() async {
    final currentItemsLength = state.valueOrNull?.length;
    final canLoadMore = (currentItemsLength ?? 0) < _totalDataCount;

    if (canLoadMore) {
      final booking =
          await AsyncValue.guard(() => _getJobBooking(_currentPage + 1));
      state = booking;
    }
  }

  bool get canLoadMore => (state.valueOrNull?.length ?? 0) < _totalDataCount;
}

/// [bookingRealtimeProvider] that updates this [userBookingsProvider] that controls the bookings
final bookingRealtimeProvider = AsyncNotifierProvider.family
    .autoDispose<BookingRealTimeNotifier, void, String>(
        BookingRealTimeNotifier.new);

// final bookingRealtimeProvider = StreamProvider.family<void, String>((ref,id) {
//   final socketChannel =
//         SocketChannel('wss://uat-api.vmodel.app/ws/booking_status/$id/');
//       ref.onDispose(() {
//       socketChannel.close();
//       logger.i('Connection closed with websocket');
//     });

//   return socketChannel.stream;
// });

/// Booking realtime notifier
class BookingRealTimeNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  StreamSubscription? _subscription;

  @override
  FutureOr build(String id) async {
    final socketChannel =
        SocketChannel('wss://uat-api.vmodel.app/ws/booking_status/$id/');
    // final socket = await _connect(id);

    _subscription = socketChannel.stream.listen((event) {
      logger.i('Recieved a booking event \n$event\nInvalidating provider....');
      ref.invalidate(userBookingsProvider);
    });

    ref.onDispose(() {
      _subscription?.cancel();
      socketChannel.close();
      logger.i('Connection closed with websocket');
    });
  }

  /// connects to [IOWebSocketChannel] to access the booking websocket
  @Deprecated('Redundant')
  Future<IOWebSocketChannel> _connect(String bookingId) async {
    final token = await VModelSecureStorage()
        .getSecuredKeyStoreData(VSecureKeys.restTokenKey);
    final channel = IOWebSocketChannel.connect(
        'wss://uat-api.vmodel.app/ws/booking_status/$bookingId/',
        headers: {
          "authorization": "Token ${token.toString().trim()}",
        });
    logger.d("Connection in progress...");
    await channel.ready;
    logger.d("Websocket connected!");

    return channel;
  }
}
