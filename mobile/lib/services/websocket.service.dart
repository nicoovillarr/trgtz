import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trgtz/app.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/store/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketMessage {
  final String? type;
  final String? channelType;
  final String? documentId;
  final dynamic data;

  WebSocketMessage({
    this.type,
    this.data,
    this.channelType,
    this.documentId,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'],
      channelType: json['channelType'],
      documentId: json['documentId'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'channelType': channelType,
      'documentId': documentId,
      'data': data,
    };
  }
}

class WebSocketChannelSubscription {
  final String channelType;
  final String documentId;
  final Stream<WebSocketMessage> messages;
  final Function(WebSocketMessage) callback;

  StreamSubscription<dynamic>? _subscription;

  WebSocketChannelSubscription({
    required this.channelType,
    required this.documentId,
    required this.messages,
    required this.callback,
  });

  void init() {
    WebSocketService.getInstance().sendMessage(
      WebSocketMessage(
        type: broadcastTypeSubscribeChannel,
        data: {
          'channelType': channelType,
          'documentId': documentId,
        },
      ),
    );

    _subscription = messages.listen((message) {
      callback(message);
    });
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamController<dynamic>? _controller;
  Stream<WebSocketMessage>? _broadcastStream;
  StreamSubscription<dynamic>? _rootSubscription;
  bool connected = false;
  Timer? _pingTimer;
  bool _waitingForPong = false;

  final List<WebSocketChannelSubscription> _channelsSubscribed = [];

  WebSocketService._();

  static WebSocketService getInstance() {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Future init() async {
    if (_channel == null) {
      Completer<void> completer = Completer<void>();

      final endpoint = Uri.parse(dotenv.env["WS_ENDPOINT"].toString());
      _channel = WebSocketChannel.connect(endpoint);

      final token = await LocalStorage.getToken();
      sendMessage(WebSocketMessage(type: 'AUTH', data: {'token': token}));

      _controller = StreamController<dynamic>();

      _rootSubscription = _channel!.stream.listen(
        _controller!.add,
        onDone: restart,
        onError: (error) => restart(),
      );

      _broadcastStream = _controller!.stream.map((event) {
        final message = WebSocketMessage.fromJson(jsonDecode(event));
        if (kDebugMode) {
          print('[WebSocket] Received message: ${message.type}');
        }

        if (message.type == 'PONG') {
          _waitingForPong = false;
        }

        return message;
      }).asBroadcastStream();

      StreamSubscription<WebSocketMessage>? authAux;
      authAux = _broadcastStream!.listen((event) async {
        if (event.type == broadcastTypeAuthSuccess) {
          await LocalStorage.saveBroadcastToken(event.data);

          connected = true;
          completer.complete();
          authAux?.cancel();

          if (_pingTimer != null && !_pingTimer!.isActive) {
            _pingTimer!.cancel();
            _pingTimer = null;
          }

          _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
            if (_channel != null) {
              if (_waitingForPong) {
                restart();
                return;
              }

              sendMessage(WebSocketMessage(type: 'PING', data: {}));
              _waitingForPong = true;
            }
          });
        }
      });

      await completer.future;

      if (_channelsSubscribed.isNotEmpty) {
        for (var sub in _channelsSubscribed) {
          sub.init();
        }
      }
    } else if (kDebugMode) {
      print('WebSocketService is already initialized');
    }
  }

  void subscribe(String channelType, String documentId,
      Function(WebSocketMessage) callback) {
    if (_channelsSubscribed.any((element) =>
        element.channelType == channelType &&
        element.documentId == documentId)) {
      throw StateError('Already subscribed to $channelType/$documentId');
    }

    if (kDebugMode) {
      print('[WebSocket] Subscribed to $channelType/$documentId');
    }

    WebSocketChannelSubscription sub = WebSocketChannelSubscription(
      channelType: channelType,
      documentId: documentId,
      messages: messages!.where((event) =>
          event.channelType == channelType && event.documentId == documentId),
      callback: callback,
    );

    sub.init();

    _channelsSubscribed.add(sub);
  }

  void unsubscribe(String channelType, String documentId) {
    final sub = _channelsSubscribed
        .where((element) =>
            element.channelType == channelType &&
            element.documentId == documentId)
        .lastOrNull;
    if (sub == null) {
      return;
    }

    sub.cancel();

    sendMessage(WebSocketMessage(
      type: broadcastTypeUnsubscribeChannel,
      data: {
        'channelType': channelType,
        'documentId': documentId,
      },
    ));

    _channelsSubscribed.remove(sub);

    if (kDebugMode) {
      print('[WebSocket] Unsubscribed from $channelType/$documentId');
    }
  }

  void unsubscribeToAll() {
    for (var element in _channelsSubscribed) {
      element.cancel();

      sendMessage(WebSocketMessage(
        type: broadcastTypeUnsubscribeChannel,
        data: {
          'channelType': element.channelType,
          'documentId': element.documentId,
        },
      ));
    }

    if (kDebugMode) {
      print('[WebSocket] Unsubscribed from all channels');
    }
  }

  void sendMessage(WebSocketMessage message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message.toJson()));

      if (kDebugMode) {
        print('[WebSocket] Sent message: ${message.type}');
      }
    }
  }

  Stream<WebSocketMessage>? get messages => _broadcastStream;

  void dispose() {
    _channel?.sink.close();
    _channel = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void close() {
    _rootSubscription?.cancel();
    unsubscribeToAll();
    _controller?.close();
    _channel?.sink.close();
    _channel = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void restart() {
    if (!connected) {
      return;
    }

    if (_pingTimer != null && _pingTimer!.isActive) {
      _pingTimer!.cancel();
      _pingTimer = null;
    }

    BuildContext context = navigatorKey.currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection lost. Reconnecting...'),
        duration: Duration(seconds: 2),
      ),
    );

    List<WebSocketChannelSubscription> backup = List.from(_channelsSubscribed);
    close();
    Future.delayed(const Duration(seconds: 5), () {
      init().then((value) {
        for (var element in backup) {
          subscribe(element.channelType, element.documentId, element.callback);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reconnected.'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }
}
