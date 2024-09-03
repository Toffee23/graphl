import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmodel/src/core/api/file_service.dart';
import 'package:vmodel/src/core/cache/credentials.dart';
import 'package:vmodel/src/core/network/graphql_confiq.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/messages/model/conversation_model.dart';
import 'package:vmodel/src/features/messages/model/messages_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../app_locator.dart';
import '../../../core/network/urls.dart';
import '../../../core/utils/exception_handler.dart';

// class MessageRepository {
//   MessageRepository._();
//   static MessageRepository instance = MessageRepository._();
//   final WebSocketChannel channel = IOWebSocketChannel.connect(
//       'wss://vmodel-app.herokuapp.com/ws/graphql/?token=e91f954ec2ace103c012cb540c315829a868b492');

//   StreamSubscription? _messageSubscription;

//   Future<String?> createChat(String name, String recipient) async {
//     try {
//       final event = await vBaseServiceInstance.mutationQuery(
//         mutationDocument: '''
//         mutation CreateChat(\$name: String!, \$recipient: String!) {
//           createChat(name: \$name, recipient: \$recipient) {
//             chat {
//               id
//             }
//           }
//         }
//       ''',
//         payload: {'name': name, 'recipient': recipient},
//       );

//       final Either<CustomException, Map<String, dynamic>?> chatevent = event;

//       return chatevent.fold(
//         (left) {
//           //print('Error creating chat: ${left.message}');
//           return null;
//         },
//         (right) {
//           final chatId = right?['createChat']?['chat']?['id'] as String?;
//           return chatId;
//         },
//       );
//     } catch (e) {
//       //print('Error creating chat: $e');
//       return null;
//     }
//   }

//   Future<int?> sendMessage(String message, int chatId) async {
//     try {
//       final event = await vBaseServiceInstance.mutationQuery(
//         mutationDocument: '''
//         mutation SendMessage(\$message: String!, \$chatId: Int!) {
//           sendMessage(message: \$message, chatId: \$chatId) {
//             message {
//               id
//             }
//           }
//         }
//       ''',
//         payload: {'message': message, 'chatId': chatId},
//       );

//       final Either<CustomException, Map<String, dynamic>?> sendevent = event;

//       return sendevent.fold(
//         (left) {
//           //print('Error sending message: ${left.message}');
//           return null;
//         },
//         (right) {
//           final messageId = right?['sendMessage']?['message']?['id'];
//           return messageId is int ? messageId : null;
//         },
//       );
//     } catch (e) {
//       //print('Error sending message: $e');
//       return null;
//     }
//   }

//   Future<void> startListeningForMessages() async {
//     _messageSubscription = channel.stream.listen((message) {
//       //print('Received message: $message');
//     });

//     // Send the subscription query to start receiving messages
//     const subscriptionQuery = '''
//     subscription {
//       newMessage(chatroom: "gg500") {
//         message {
//           conversationSet {
//             members {
//               username
//             }
//             messages {
//               text
//             }
//           }
//         }
//       }
//     }
//     ''';
//     channel.sink.add(subscriptionQuery);
//   }

//   void stopListeningForMessages() {
//     _messageSubscription?.cancel();
//     _messageSubscription = null;
//   }
// }

abstract class MessagingRepository {
  Future<String?> createChat(String name, String recipient);

  void sendMessage(String message);

  Stream startListeningForMessages();

  Stream<QueryResult<Object?>> startListeningForNotifications();

  Future<Either<CustomException, List<ConversationModel>>> getConversations();

  Future<Either<CustomException, List<ConversationModel>>> getArchivedConversations();

  Future<Either<CustomException, List<MessageModel>>> getConversation(int id, int pageNumber, int pageCount);

  Future<Either<CustomException, String>> archiveConversation(int id);

  Future<Either<CustomException, String>> unarchiveConversation(int id);

  Future<Either<CustomException, String?>> uploadFile(File files, {OnUploadProgressCallback? onUploadProgress});

  Future<Either<CustomException, void>> readMessages(List<String> messageIds);
}

class MessagesRepository implements MessagingRepository {
  static final WebSocketLink channel = WebSocketLink(
      // 'wss://vmodel-app.herokuapp.com/ws/graphql/',
      // 'wss://uat-api.vmodel.app/ws/graphql/',
      VUrls.webSocketUrl,
      config: const SocketClientConfig(autoReconnect: true, inactivityTimeout: Duration(seconds: 30)));

  static var token = VCredentials.inst.getRestToken() as String;

  final socketClient = GraphQLClient(link: GraphQlConfig.authLink.concat(channel), cache: GraphQLCache());

  @override
  Future<Either<CustomException, String>> archiveConversation(int id) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      mutation archiveConversation(\$conversationId: Int!) {
        archiveConversation(conversationId: \$conversationId){
         message
        }
      }
        ''', payload: {
        'conversationId': id,
      });

      final Either<CustomException, String> response = result.fold((left) {
        //print("archiveConversation ${left.message}");
        return Left(left);
      }, (right) {
        //print("archiveConversation $right");

        final message = right?['archiveConversation'] as String?;

        return Right(message!);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  // void stopListeningForMessages() {
  //   _messageSubscription?.cancel();
  //   _messageSubscription = null;
  // }

  @override
  Future<String?> createChat(String name, String recipient) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final event = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
        mutation CreateChat(\$name: String!, \$recipient: String!) {
          createChat(name: \$name, recipient: \$recipient) {
            chat {
              id
            }
          }
        }
      ''',
        payload: {'name': name, 'recipient': recipient},
      );

      final Either<CustomException, Map<String, dynamic>?> chatevent = event;

      return chatevent.fold(
        (left) {
          //print('Error creating chat: ${left.message}');
          return null;
        },
        (right) {
          final chatId = right?['createChat']?['chat']?['id'] as String?;
          prefs.setInt('id', int.parse(chatId!));
          //print(chatId);
          return chatId;
        },
      );
    } catch (e) {
      //print('Error creating chat: $e');
      return null;
    }
  }

  @override
  Future<Either<CustomException, List<ConversationModel>>> getArchivedConversations() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query archivedConversations {
  archivedConversations{
          id
            name
            unreadMessagesCount
            recipient{
              firstName
              lastName
              username
              profilePictureUrl
              thumbnailUrl
              userType
              profileRing
            }
            messageChunk(pageCount: 50, pageNumber: 1){
              id
              sender {
                firstName
                lastName
                username
                profilePictureUrl
                thumbnailUrl
                userType
              }
              text
              attachment
              attachmentType
              createdAt
              read
              deleted
              isItem
              itemId
              itemType
              receiverProfile
              senderName
            }
            lastMessage{
              id
              sender {
                firstName
                lastName
                username
                profilePictureUrl
                thumbnailUrl
                userType
              }
              text
              attachmentType
              attachment
              createdAt
              read
              deleted
              isItem
              itemId
              itemType
              senderName
              receiverProfile
            }
            createdAt
            lastModified
            disableResponse
            deleted
  }
}
        ''', payload: {});

      return result.fold((left) => Left(left), (right) {
        final conversations = right!['archivedConversations'] as List;

        return Right(conversations.map<ConversationModel>((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList());
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<MessageModel>>> getConversation(int id, int pageCount, int pageNumber) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query conversation(\$id: ID!, \$pageCount: Int, \$pageNumber: Int) {
                conversation(id: \$id, pageCount: \$pageCount, pageNumber: \$pageNumber){
                  id
                  sender {
                    firstName
                    lastName
                    username
                    profilePictureUrl
                    thumbnailUrl
                    userType
                  }
                  text
                  attachment
                  attachmentType
                  createdAt
                  read
                  deleted
                  isItem
                  itemId
                  itemType
                  receiverProfile
                  senderName
                }
              }
        ''', payload: {
        'id': id,
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        final conversationList = (right!['conversation'] as List).map<MessageModel>((e) => MessageModel.fromJson(e)).toList();
        // final conversationTotalNumber = int.parse("${right?['conversationTotalNumber'] ?? 0}");

        return Right(conversationList);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<ConversationModel>>> getConversations() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query conversations {
          conversations{
            id
            name
            unreadMessagesCount
            recipient{
              firstName
              lastName
              username
              profilePictureUrl
              thumbnailUrl
              userType
              profileRing
            }
            messageChunk(pageCount: 50, pageNumber: 1){
              id
              sender {
                firstName
                lastName
                username
                profilePictureUrl
                thumbnailUrl
                userType
              }
              text
              attachment
              attachmentType
              createdAt
              read
              deleted
              isItem
              itemId
              itemType
              receiverProfile
              senderName
            }
            lastMessage{
              id
              sender {
                firstName
                lastName
                username
                profilePictureUrl
                thumbnailUrl
                userType
              }
              text
              attachmentType
              attachment
              createdAt
              read
              deleted
              isItem
              itemId
              itemType
              senderName
              receiverProfile
            }
            createdAt
            lastModified
            disableResponse
            deleted
          }
        }
        ''', payload: {});

      return result.fold((left) => Left(left), (right) {
        final conversations = right!['conversations'] as List;

        return Right(conversations.map<ConversationModel>((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList());
      });

      // return response;
    } catch (e, _) {
      logger.e(_);
      return Left(CustomException(e.toString()));
    }
  }

  @override
  void sendMessage(String message) async {
    // final wsUrl = Uri.parse('wss://vmodel-app.herokuapp.com/ws/chat/67/');
    final wsUrl = Uri.parse('${VUrls.webSocketBaseUrl}/chat/67/');
    // final wsUrl = Uri.parse('wss://uat-api.vmodel.app/ws/chat/67/');

    WebSocketChannel channel = IOWebSocketChannel.connect(wsUrl, headers: {"authorization": "Token db7332bc628836d65a48ed4a872b209fed2ac05e"});
    var text = jsonEncode(<String, String>{"message": message});
    channel.sink.add(text);
  }

  @override
  Stream startListeningForMessages() async* {
    // Send the subscription query to start receiving messages
    // final wsUrl = Uri.parse('wss://vmodel-app.herokuapp.com/ws/chat/68/');

    // final wsUrl = Uri.parse('wss://uat-api.vmodel.app/ws/chat/68/');
    final wsUrl = Uri.parse('${VUrls.webSocketBaseUrl}/chat/68/');
    WebSocketChannel channel = IOWebSocketChannel.connect(wsUrl, headers: {"authorization": "Token db7332bc628836d65a48ed4a872b209fed2ac05e"});
    //print(channel.stream);

    channel.stream.listen((message) {
      //print(message);
      // if (message.hasException) {
      //   //print(message.exception.toString());
      //   return;
      // }

      // if (message.isLoading) {
      //   //print('awaiting events');
      //   return;
      // }

      // //print('New Review: ${message.data}');
    });
    //print('object');
    yield channel.stream;
    yield null;
  }

  @override
  Stream<QueryResult<Object?>> startListeningForNotifications() async* {
    // Send the subscription query to start receiving messages
    String subscriptionQuery = '''
    subscription (\$notificationRoom: String){
  newNotification(notificationRoom: \$notificationRoom){
    notification {
      id
      profilePictureUrl
      message
      model
      modelId
      modelGroup
      read
      post{
        id
        caption
      }
      createdAt
    }
  }
}
    ''';
    Map<String, dynamic> payload = {'notificationRoom': 'olufemi'};
    final SubscriptionOptions options = SubscriptionOptions(document: gql(subscriptionQuery), variables: payload);
    final res = socketClient.subscribe(options);

    //print(channel.url);

    res.listen((event) {
      if (event.hasException) {
        //print(event.exception.toString());
        return;
      }

      if (event.isLoading) {
        //print('awaiting events');
        return;
      }

      //print('New Review: ${event.data}');
    });
    //print('object');

    yield* socketClient.subscribe(options);
  }

  @override
  Future<Either<CustomException, String>> unarchiveConversation(int id) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      mutation unarchiveConversation(\$conversationId: Int!) {
        unarchiveConversation(conversationId: \$conversationId){
         message
        }
      }
        ''', payload: {
        'conversationId': id,
      });

      final Either<CustomException, String> response = result.fold((left) {
        //print("unarchiveConversation ${left.message}");
        return Left(left);
      }, (right) {
        //print("unarchiveConversation $right");

        final message = right?['unarchiveConversation'] as String?;

        return Right(message!);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, String?>> uploadFile(File files, {OnUploadProgressCallback? onUploadProgress}) async {
    try {
      final res = await FileService.fileUploadMultipart(
        // url: VUrls.postMediaUploadUrl,
        url: 'https://uat-api.vmodel.app/upload/resource/',
        files: [files.path],
        onUploadProgress: onUploadProgress,
      );
      // return res;
      //print('%%%MMMMMMMMM REturning right $res');
      return Right(res);
    } catch (e) {
      //print("Here error uploading url: $url \n $e");
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, void>> readMessages(List<String> messageIds) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
          mutation UpdateReadMessages(\$messageIds: [Int]!) {
            updateReadMessages(messageIds: \$messageIds) {
                  success
                  updatedCount
                }
              }
        ''',
        payload: {"messageIds": messageIds},
      );

      return result.fold((left) => Left(left), (right) {
        logger.f(right);
        void v;
        return Right(v);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
