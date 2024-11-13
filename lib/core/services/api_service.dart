import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UrlHandler {
  static String transformUrl(String url) {
    if (!Platform.isAndroid) {
      return url;
    }

    // Handle localhost URLs
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    // Handle 127.0.0.1 URLs
    if (url.contains('127.0.0.1')) {
      return url.replaceAll('127.0.0.1', '10.0.2.2');
    }

    return url;
  }

  static String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'https://101.100.162.119:3000';
    }
    return 'https://101.100.162.119:3000';
  }

  static String getRedirectUrl() {
    if (Platform.isAndroid) {
      return 'https://101.100.162.119:3000/auth/redirect';
    }
    return 'https://localhost:3000/auth/redirect';
  }
}



class ApiService {
  final Dio _dio;
  String? _token;

  ApiService() : _dio = Dio() {
    
    _dio.options.baseUrl = UrlHandler.getBaseUrl();
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Accept': 'application/json',
    };

    // Initialize with stored token if available
    const storage = FlutterSecureStorage();
    storage.read(key: 'jwt_token').then((value) {
      if (value != null) {
        _token = value;
      }
    });

    // Configure SSL certificate verification
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
      validateCertificate: (cert, host, port) {
        // Return true to accept all certificates
        return true;
      },
    );

    // Add interceptors for handling tokens, errors, etc.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add Authorization header for mobile clients
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          _token = null;
        }
        return handler.next(e);
      },
    ));
  }

  void updateToken(String? token) {
    _token = token;
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}