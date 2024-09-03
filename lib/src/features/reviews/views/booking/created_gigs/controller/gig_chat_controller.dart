
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/booking_chat_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/repository/created_gigs_booking_repo.dart';

final bookingChatStateNotiferProvider = StateNotifierProvider<BookingChatStateNotifier, List<BookingMessage>>((ref) => BookingChatStateNotifier());

class BookingChatStateNotifier extends StateNotifier<List<BookingMessage>> {
  BookingChatStateNotifier() : super([]);

  final _repository = MyCreatedBookingsRepository.instance;



  Future<List<BookingMessage>> init({String? bookingId}) async {

    final response = await _repository.getBookingsChats(bookingId: int.parse(bookingId!));

    // BookingMessage modelData = BookingMessage.fromJson(response);
    // state = modelData;

      return response.fold((left) {
      logger.e(left.message);
      return [];
    }, (right) {

      print(right['bookingConversation']);
      List<BookingMessage> data = List.generate(right['bookingConversation'].length, (index) => BookingMessage.fromJson(right['bookingConversation'][index]));

      state = data;

      return data;
    });

  }

  
}
