import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:trgtz/services/index.dart';
import 'dart:convert';

import 'package:trgtz/store/local_storage.dart';

typedef ApiCall = Future<http.Response> Function(Uri endpoint, dynamic params);

class ApiBaseService {
  late String controller = '';

  ApiBaseService();

  @protected
  Future<ApiResponse> get(String action, {Map<String, String?>? params}) async {
    return _call('GET', action, params);
  }

  @protected
  Future<ApiResponse> post(String action, dynamic params) async {
    return _call('POST', action, params);
  }

  @protected
  Future<ApiResponse> put(String action, dynamic params) async {
    return _call('PUT', action, params);
  }

  @protected
  Future<ApiResponse> patch(String action, dynamic params) async {
    return _call('PATCH', action, params);
  }

  @protected
  Future<ApiResponse> delete(String action, dynamic params) async {
    return _call('DELETE', action, params);
  }

  @protected
  Future<ApiResponse> uploadImage(String action, File image) async {
    var request = http.MultipartRequest('POST', _buildUri(action, ''));
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: 'image.jpg',
      ),
    );
    request.headers.addAll(await _buildHeaders());
    final response = await request.send();
    return ApiResponse(content: 'asd', statusCode: response.statusCode);
  }

  Future<ApiResponse> _call(
      String method, String action, dynamic params) async {
    assert(controller != '');
    String query = '';

    ApiCall callMethod;
    switch (method) {
      case 'GET':
        callMethod = _getApiCallImpl;
        if (params != null && params is Map<String, String?>) {
          query =
              '?${params.keys.where((key) => params[key] != null).map((key) => '$key=${params[key]}').join('&')}';
        }
        break;
      case 'POST':
        callMethod = _postApiCallImpl;
        break;
      case 'PUT':
        callMethod = _putApiCallImpl;
        break;
      case 'PATCH':
        callMethod = _patchApiCallImpl;
        break;
      case 'DELETE':
        callMethod = _deleteApiCallImpl;
        break;
      default:
        throw UnimplementedError();
    }

    dynamic content;
    int? statusCode;
    try {
      final response = await callMethod(_buildUri(action, query), params)
          .timeout(const Duration(seconds: 50));
      statusCode = response.statusCode;
      try {
        content = jsonDecode(response.body);
      } catch (_) {
        content = response.body;
      }
      if (statusCode < 200 || statusCode > 299) {
        content = content != null &&
                content is Map<String, dynamic> &&
                content.containsKey('message')
            ? content['message']
            : 'Unknown error';
        if (kDebugMode) {
          print(content);
        }
      }
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }

    return ApiResponse(statusCode: statusCode, content: content);
  }

  Future<http.Response> _getApiCallImpl(Uri endpoint, dynamic params) async =>
      http.get(endpoint, headers: await _buildHeaders());

  Future<http.Response> _postApiCallImpl(Uri endpoint, dynamic params) async =>
      http.post(
        endpoint,
        body: jsonEncode(params),
        headers: await _buildHeaders(),
      );

  Future<http.Response> _putApiCallImpl(Uri endpoint, dynamic params) async =>
      http.put(
        endpoint,
        body: jsonEncode(params),
        headers: await _buildHeaders(),
      );

  Future<http.Response> _patchApiCallImpl(Uri endpoint, dynamic params) async =>
      http.patch(
        endpoint,
        body: jsonEncode(params),
        headers: await _buildHeaders(),
      );

  Future<http.Response> _deleteApiCallImpl(
          Uri endpoint, dynamic params) async =>
      http.delete(
        endpoint,
        headers: await _buildHeaders(),
      );

  Future<Map<String, String>> _buildHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? token = await LocalStorage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    String? firebaseToken = await FirebaseHelperService.token;
    if (firebaseToken != null) {
      headers['Firebase-Token'] = firebaseToken;
    }
    String? broadcastToken = await LocalStorage.getBroadcastToken();
    if (broadcastToken != null) {
      headers['Broadcast-Token'] = broadcastToken;
    }
    return headers;
  }

  Uri _buildUri(String action, String query) => Uri.parse(
      '${dotenv.env["ENDPOINT"]}/${'$controller/$action$query'.replaceAll(RegExp(r'/+'), '/')}');
}

class ApiResponse {
  final int? statusCode;
  final dynamic content;

  ApiResponse({required this.content, required this.statusCode});

  bool get status =>
      statusCode != null ? statusCode! >= 200 && statusCode! <= 299 : false;

  @override
  String toString() {
    return jsonEncode(this);
  }
}
