import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/messages/model/conversation_model.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:web_socket_channel/io.dart';

import '../../../core/network/urls.dart';
import '../repository/message_repo.dart';

// final MessageRepository _messageRepository = MessageRepository.instance;
// final messageRepository = MessageRepository.instance;

final messageProvider =
    Provider<MessagingRepository>((ref) => MessagesRepository());

final chatIdProvider = StateProvider<int>((ref) {
  return 0;
});

final failedMessagesProvider = StateProvider<Map<int, List<String>>>(
  (ref) => {},
);

// final getConversations =
//     FutureProvider<Either<CustomException, List<dynamic>>>((ref) async {
//   return ref.read(messageProvider).getConversations();
// });

final getConversationsProvider = FutureProvider((ref) async {
  final result = await ref.read(messageProvider).getConversations();
  return result.fold((p0) {
    logger.e(p0.message);
    throw "An error occured!";
  }, (p0) {
    logger.f(p0);
    return p0;
  });
});

class ConversationsNotifier extends AutoDisposeAsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    Either<CustomException, List<dynamic>> data =
        await ref.read(messageProvider).getConversations();
    return data.fold((p0) => [], (p0) {
      return p0;
    });
  }
}

final isUserArchivedProvider =
    StateProvider.autoDispose.family<Future<bool>, String>((ref, args) async {
  final result = await ref.read(messageProvider).getArchivedConversations();
  final archivedUsers =
      result.fold((left) => <ConversationModel>[], (right) => right);

  if (archivedUsers.isEmpty) return false;
  return archivedUsers.any((element) => element.recipient.username == args);
});

final getArchivedConversations = FutureProvider((ref) async {
  final result = await ref.read(messageProvider).getArchivedConversations();

  return result.fold(
    (left) => throw left.message,
    (right) => right,
  );
});

// final getConversation = FutureProvider.autoDispose
//     .family<Either<CustomException, List<dynamic>>, int>((ref, id) async {
//   return ref.read(messageProvider).getConversation(id);
// });

/// NEW CONVERSATION CONTROLLER
final conversationProvider =
    AsyncNotifierProvider.family<ConversationNotifier, List<MessageModel>, int>(
        () => ConversationNotifier());

class ConversationNotifier
    extends FamilyAsyncNotifier<List<MessageModel>, int> {
  final _repository = MessagesRepository();
  int conversationTotalNumber = 0;
  int pageCount = 50;
  int _currentPage = 2;

  @override
  Future<List<MessageModel>> build(id) async {
    _currentPage = 2;
    // state = const AsyncLoading();
    // await ;
    return getConversation(currentPage: _currentPage, id: id);
  }

  Future<List<MessageModel>> getConversation(
      {required int currentPage, required int id}) async {
    final response =
        await _repository.getConversation(id, pageCount, currentPage);
    return response.fold((left) {
      throw left.message;
    }, (right) {
      _currentPage = currentPage;
      // final List<MessageModel> conversationList = [];
      // if (right.is) {
      //   conversationTotalNumber = right[1];
      //   conversationList.addAll(right[0]);
      // }
      final currentState = state.valueOrNull ?? [];
      if (currentPage == 1) {
        // state = AsyncData(conversationList);
        return right;
      } else {
        return [...currentState, ...right];
      }
    });
  }

  Future<void> fetchMoreData(int id) async {
    final canLoadMore =
        (state.valueOrNull?.length ?? 0) < conversationTotalNumber;
    if (canLoadMore) {
      await getConversation(currentPage: _currentPage + 1, id: id);
    }
  }

  bool canLoadMore() {
    return (state.valueOrNull?.length ?? 0) < conversationTotalNumber;
  }
}

final archiveConversation = FutureProvider.autoDispose
    .family<Either<CustomException, String>, int>((ref, id) async {
  return ref.read(messageProvider).archiveConversation(id);
});

final unarchiveConversation = FutureProvider.autoDispose
    .family<Either<CustomException, String>, int>((ref, id) async {
  return ref.read(messageProvider).unarchiveConversation(id);
});

final messageFileUploadProgress = StateProvider((ref) => 0.00);
final messageDownloadProgress = StateProvider((ref) => 0);
final messagesNotifierProvider = AsyncNotifierProvider(MessageNotifier.new);

class MessageNotifier extends AsyncNotifier {
  Future<String?> createChat(String name, String recipient) async {
    final repository = ref.read(messageProvider);
    final response = await repository.createChat(name, recipient);
    return response;
  }

  void sendMessage(String message) {
    final repository = ref.read(messageProvider);
    final response = repository.sendMessage(message);
    return response;
  }

  Future<Map<String, dynamic>?> uploadFile(File file) async {
    final repo = ref.read(messageProvider);
    final uploadResult =
        await repo.uploadFile(file, onUploadProgress: (sent, total) {
      ref.read(messageFileUploadProgress.notifier).state = sent / total;
    });

    return uploadResult.fold((p0) {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "An error occured uploading files");
      ref.invalidate(messageFileUploadProgress);

      return null;
    }, (data) {
      ref.invalidate(messageFileUploadProgress);
      if (data != null) {
        return jsonDecode(data);
      } else {
        return null;
      }
    });
  }

  Future<void> markMessageAsRead(List<String> messageIds) async {
    final repo = ref.read(messageProvider);

    final result = await repo.readMessages(messageIds);

    state =
        result.fold((p0) => AsyncError(p0.message, StackTrace.current), (p0) {
      ref.read(getConversationsProvider);
      return AsyncData({});
    });
  }

  @override
  FutureOr build() {}
}

// Future<String?> createChat(String name, String recipient) async {
//   final repository = ref.read(messageProvider);
//   final response = await messageProvider..createChat(name, recipient);
//   return response;
// }

// void startListeningForMessages() {

//   messageRepository.startListeningForMessages();
// }

final switchedProvider = StateProvider<bool>((ref) => false);
final connectedStatusProvider = StateProvider<bool>((ref) => false);
final cycleStatusProvider = StateProvider<int>((ref) => 0);
final forceStatusProvider = StateProvider<int>((ref) => 0);

final webSocketProvider = StateProvider<IOWebSocketChannel>((ref) {
  // final channel = IOWebSocketChannel.connect(Uri.parse('wss://vmodel-app.herokuapp.com/ws/chat/68/'));
  final channel = IOWebSocketChannel.connect(
      Uri.parse('${VUrls.webSocketBaseUrl}/chat/68/'));
  ref.onDispose(() => channel.sink.close());
  return channel;
});

void updateStateFromMessage(String message, WidgetRef ref) {
  //print(message);
  Map<String, dynamic> jsondat = json.decode(message);
  String data = json.encode(jsondat);
  if (data.contains("connected")) {
    ref.read(connectedStatusProvider.notifier).state = true;
    ref.read(cycleStatusProvider.notifier).state = jsondat['cycle'];
    ref.read(forceStatusProvider.notifier).state = jsondat['force'];
  }
}

final providerOfMessages = StreamProvider.autoDispose<String>(
  (ref) async* {
    final channel = ref.watch(webSocketProvider);
    // Close the connection when the stream is destroyed
    ref.onDispose(() => channel.sink.close());

    await for (final value in channel.stream) {
      yield value.toString();
    }
  },
);

final getMessages = StreamProvider.autoDispose((ref) async* {
  //print('here now');
  final response = ref.watch(messageProvider).startListeningForMessages();
  yield response;
  yield null;
});

final getNotifications = StreamProvider.autoDispose<Object?>((ref) {
  //print('here now');
  final response = ref.read(messageProvider).startListeningForNotifications();
  return response;
});

  // void stopListeningForMessages() {
  //   final messageRepository = MessageRepository.instance;
  //   messageRepository.stopListeningForMessages();
  // }



