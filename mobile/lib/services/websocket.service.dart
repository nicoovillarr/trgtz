import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:trgtz/constants.dart';
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

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamController<dynamic>? _controller;
  Stream<WebSocketMessage>? _broadcastStream;

  WebSocketService._();

  static WebSocketService getInstance() {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Future init() async {
    if (_channel == null) {
      final uri = Uri.parse(endpoint);
      final hostname = uri.host;
      final url = 'ws://$hostname:8080';
      _channel = WebSocketChannel.connect(Uri.parse(url));

      final token = await LocalStorage.getToken();
      sendMessage(WebSocketMessage(type: 'AUTH', data: {'token': token}));

      await Future.delayed(const Duration(seconds: 1));

      _controller = StreamController<dynamic>();

      _channel!.stream.listen(_controller!.add);

      _broadcastStream = _controller!.stream.map((event) {
        final message = WebSocketMessage.fromJson(jsonDecode(event));
        if (kDebugMode) {
          print('Received message: ${message.type}');
        }
        return message;
      }).asBroadcastStream();
    } else {
      throw StateError('WebSocketService is already initialized');
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
}
