import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../cache/credentials.dart';
import '../cache/local_storage.dart';

IOWebSocketChannel? _channel;
final newNotificationProvider = StateProvider<bool>((ref) {
  return false;
});

WidgetRef? reff;

class WSFeed {
  final VModelSecureStorage stroage = VModelSecureStorage();
  IOWebSocketChannel? channel;

  Future<void> _initSocket() async {
    try {
      final user = await reff!.read(appUserProvider.future);
      final uri =
          Uri.parse('wss://uat-api.vmodel.app/ws/postfeed/${user!.username}/');
      String token =
          await stroage.getSecuredKeyStoreData(VSecureKeys.restTokenKey);

      channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Token ${token.toString().trim()}',
        },
      );

      // await channel!.ready;
      log('Feed Websocket Ready: ${user.username}');

      channel!.stream.listen(
        (event) {
          final postEvent = event is String ? jsonDecode(event) : event;
          if (reff!.read(newFeedAvaialble).isNotEmpty &&
              !reff!.read(newFeedAvaialble).any((element) =>
                  element['user']['username'] !=
                  postEvent['user']['username'])) {
            reff!.read(newFeedAvaialble).add(postEvent);
          }
        },
      );
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
    }
  }

  WSFeed() {
    _initSocket();
  }

  Stream<dynamic> listen() {
    if (channel != null) {
      return channel!.stream;
    } else {
      throw "Channel hasn't been created yet";
    }
  }
}

class VWebsocket {
  void connectToWebSocket(username, token, ref) async {
    reff = ref;
    final user = await reff!.read(appUserProvider.future);
    var _token = await token;

    final String url =
        "wss://uat-api.vmodel.app/ws/notification/${user!.username}/";
    var _url = Uri.parse(url);

    if (_channel == null) {
      try {
        _channel = IOWebSocketChannel.connect(
          _url,
          headers: {
            'authorization': 'Token ${_token.toString()}',
          },
        );

        // await _channel!.ready;

        _channel!.stream.listen(
          (message) {
            reff?.read(newNotificationProvider.notifier).state = true;
          },
          onDone: () {},
          onError: (error) {
            _channel = null;
          },
          cancelOnError: true,
        );
      } catch (e) {
        _channel = null;
      }
    } else {}
  }
}

class WSMessage {
  String? _url;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  static final VModelSecureStorage stroage = VModelSecureStorage();

  Future<bool> connect(wsUrl) async {
    try {
      _channel?.sink.close();
    } catch (e) {}
    try {
      _url = wsUrl;
      String token =
          await stroage.getSecuredKeyStoreData(VSecureKeys.restTokenKey);
      _channel = IOWebSocketChannel.connect(wsUrl, headers: {
        "authorization": "Token ${token.toString().trim()}",
      });
      _isConnected = true;
      return true;
    } catch (error) {
      _isConnected = false;
      return false;
    }
  }

  Future<void> close() async {
    _isConnected = false;
    logger.i('Closing Websocket');
    await _channel!.sink.close();
    logger.f('Closed Websocket');
  }

  bool add(data) {
    try {
      _channel?.sink.add(data);
      return true;
    } catch (e) {
      logger.e(e.toString());
      return false;
    }
  }

  WebSocketChannel? get channel {
    return _channel;
  }

  bool get isConnected {
    return _isConnected;
  }
}

class WSIsTyping {
  String? _url;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  static final VModelSecureStorage stroage = VModelSecureStorage();

  Future<bool> connect(wsUrl) async {
    try {
      _channel?.sink.close();
    } catch (e) {}
    try {
      _url = wsUrl;
      String token =
          await stroage.getSecuredKeyStoreData(VSecureKeys.restTokenKey);
      _channel = IOWebSocketChannel.connect(wsUrl,
          headers: {"authorization": "Token ${token.toString().trim()}"});
      _isConnected = true;
      return true;
    } catch (error) {
      _isConnected = false;
      return false;
    }
  }

  void close() {
    _isConnected = false;
    try {
      _channel?.sink.close();
    } catch (e) {}
  }

  Future<bool> add(data) async {
    try {
      if (_isConnected) {
        _channel?.sink.add(data);
      } else {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  WebSocketChannel? get channel {
    return _channel;
  }

  bool get isConnected {
    return _isConnected;
  }
}

class WSMarketplaceFeed {
  String? _url;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  static final VModelSecureStorage stroage = VModelSecureStorage();

  Future<bool> connect() async {
    try {
      _channel?.sink.close();
    } catch (e) {}
    try {
      final user = reff!.read(appUserProvider).valueOrNull;
      String token =
          await stroage.getSecuredKeyStoreData(VSecureKeys.restTokenKey);
      _channel = IOWebSocketChannel.connect(
          'wss://uat-api.vmodel.app/ws/marketplace_feed/${user?.username}/',
          headers: {
            "authorization": "Token ${token.toString().trim()}",
          });
      _isConnected = true;
      return true;
    } catch (error) {
      logger.e(error);
      _isConnected = false;
      return false;
    }
  }

  Future<void> close() async {
    _isConnected = false;
    logger.i('Closing Websocket');
    await _channel!.sink.close();
    logger.f('Closed Websocket');
  }

  WebSocketChannel? get channel {
    return _channel;
  }

  bool get isConnected {
    return _isConnected;
  }
}

/// [SocketChannel] that handles all websocket interactions by defualt the websocket is initiialized
/// in the class constructor
/// and exposes the [stream] to listen for events sent to the channel
///
/// Also a [close] to dispose all resources and a [sendMessage] function to send events
///
class SocketChannel {
  /// Constructor that takes a function that returns a [IOWebSocketChannel]
  /// and initializes the websocket connection
  SocketChannel(this.url) {
    _startConnection();
  }

  /// [url] for websocket channel
  final String url;

  // /// Function that returns a [IOWebSocketChannel]
  // final IOWebSocketChannel Function() _getIOWebSocketChannel;

  /// The underlying [IOWebSocketChannel]
  late IOWebSocketChannel _ioWebSocketChannel;

  /// The sink of the [IOWebSocketChannel]
  WebSocketSink get _sink => _ioWebSocketChannel.sink;

  /// The inner stream of the [IOWebSocketChannel]
  late Stream<dynamic> _innerStream;

  /// The outer stream subject that exposes the stream of the [IOWebSocketChannel]
  final _outerStreamSubject = BehaviorSubject<dynamic>();

  /// The stream of the [IOWebSocketChannel]
  Stream<dynamic> get stream => _outerStreamSubject.stream;

  /// Flag to indicate if it's the first time the connection is lost
  bool _isFirstRestart = false;

  /// Flag to indicate if the connection is being restarted
  bool _isFollowingRestart = false;

  /// Flag to indicate if the connection is manually closed
  bool _isManuallyClosed = false;

  /// Handles the lost connection event
  void _handleLostConnection() {
    if (_isFirstRestart && !_isFollowingRestart) {
      Future.delayed(const Duration(seconds: 3), () {
        _isFollowingRestart = false;
        _startConnection();
      });
      _isFollowingRestart = true;
    } else {
      _isFirstRestart = true;
      _startConnection();
    }
  }

  /// Starts the websocket connection
  void _startConnection() async {
    final token = await VModelSecureStorage()
        .getSecuredKeyStoreData(VSecureKeys.restTokenKey);
    _ioWebSocketChannel = IOWebSocketChannel.connect(url, headers: {
      "authorization": "Token ${token.toString().trim()}",
    });
    logger.i('Websocket connection in progress...');
    await _ioWebSocketChannel.ready;
    logger.f('Websocket connection established!!');
    _innerStream = _ioWebSocketChannel.stream;
    _innerStream.listen(
      (event) {
        _isFirstRestart = false;
        _outerStreamSubject.add(event);
      },
      onError: (error) {
        _handleLostConnection();
      },
      onDone: () {
        if (!_isManuallyClosed) {
          _handleLostConnection();
        }
      },
    );
  }

  /// Sends a message to the websocket
  void sendMessage(String message) => _sink.add(message);

  /// Closes the websocket connection
  void close() {
    _isManuallyClosed = true;
    _sink.close();
  }
}
