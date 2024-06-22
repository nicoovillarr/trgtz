import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trgtz/constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trgtz/store/local_storage.dart';

typedef ApiCall = Future<http.Response> Function(Uri endpoint, dynamic params);

class ApiBaseService {
  late String controller = '';

  ApiBaseService();

  @protected
  Future<ApiResponse> get(String action, {Map<String, String>? params}) async {
    return _call('GET', action, params);
  }

  @protected
  Future<ApiResponse> post(String action, dynamic params) async {
    return _call('POST', action, params);
  }

  Future<ApiResponse> _call(
      String method, String action, dynamic params) async {
    assert(controller != '');
    String query = '';

    ApiCall callMethod;
    switch (method) {
      case 'GET':
        callMethod = _getApiCallImpl;
        if (params != null && params is Map<String, String>) {
          query =
              '?${params.keys.map((key) => '$key=${params[key]}').join('&')}';
        }
        break;
      case 'POST':
        callMethod = _postApiCallImpl;
        break;
      default:
        throw UnimplementedError();
    }

    dynamic content;
    bool status = false;
    try {
      final response = await callMethod(
              Uri.parse('$endpoint/$controller/$action$query'), params)
          .timeout(const Duration(seconds: 50));
      status = response.statusCode >= 200 && response.statusCode <= 299;
      if (response.statusCode != 204 && response.body != '') {
        try {
          content = jsonDecode(response.body);
        } catch (_) {
          content = response.body;
        }
      }
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }

    return ApiResponse(status: status, content: content);
  }

  Future<http.Response> _getApiCallImpl(Uri endpoint, dynamic params) async =>
      http.get(endpoint, headers: await _buildHeaders());

  Future<http.Response> _postApiCallImpl(Uri endpoint, dynamic params) async =>
      http.post(
        endpoint,
        body: jsonEncode(params),
        headers: await _buildHeaders(),
      );

  Future<Map<String, String>> _buildHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? token = await LocalStorage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

class ApiResponse {
  final bool status;
  final dynamic content;

  ApiResponse({required this.content, this.status = true});

  @override
  String toString() {
    return jsonEncode(this);
  }
}
