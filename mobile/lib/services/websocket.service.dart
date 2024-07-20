import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/main.dart';
import 'package:trgtz/store/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketMessage {
  final String? type;
  final String? channelType;
  final String? documentId;
  final dynamic data;

  const WebSocketMessage(
      {this.type, this.data, this.channelType, this.documentId});

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

  final List<WebSocketChannelSubscription> _channelsSubscribed = [];

  WebSocketService._();

  static WebSocketService getInstance() {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Future init() async {
    if (_channel == null) {
      Completer<void> completer = Completer<void>();

      final uri = Uri.parse(endpoint);
      final hostname = uri.host;
      final url = 'ws://$hostname:8080';
      _channel = WebSocketChannel.connect(Uri.parse(url));

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
          print('Received message: ${message.type}');
        }

        return message;
      }).asBroadcastStream();

      StreamSubscription<WebSocketMessage>? authAux;
      authAux = _broadcastStream!.listen((event) {
        if (event.type == broadcastTypeAuthSuccess) {
          connected = true;
          completer.complete();
          authAux?.cancel();
        }
      });

      await completer.future;
    } else {
      throw StateError('WebSocketService is already initialized');
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
      print('Subscribed to $channelType/$documentId');
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
        .firstOrNull;
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
      print('Unsubscribed from $channelType/$documentId');
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

    _channelsSubscribed.clear();

    if (kDebugMode) {
      print('Unsubscribed from all channels');
    }
  }

  void sendMessage(WebSocketMessage message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message.toJson()));

      if (kDebugMode) {
        print('Sent message: ${message.type}');
      }
    }
  }

  Stream<WebSocketMessage>? get messages => _broadcastStream;

  void dispose() {
    _channel?.sink.close();
    _channel = null;
  }

  void close() {
    _rootSubscription?.cancel();
    unsubscribeToAll();
    _controller?.close();
    _channel?.sink.close();
    _channel = null;
  }

  void restart() {
    BuildContext context = navigator.currentContext!;
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
