import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor để logging cho development
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ REQUEST');
      print('├─────────────────────────────────────────────────────────────');
      print('│ ${options.method} ${options.uri}');
      print('│ Headers: ${options.headers}');
      if (options.data != null) {
        print('│ Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('│ Query Parameters: ${options.queryParameters}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ RESPONSE');
      print('├─────────────────────────────────────────────────────────────');
      print('│ ${response.requestOptions.method} ${response.requestOptions.uri}');
      print('│ Status Code: ${response.statusCode}');
      print('│ Status Message: ${response.statusMessage}');
      if (response.data != null) {
        print('│ Data: ${response.data}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ ERROR');
      print('├─────────────────────────────────────────────────────────────');
      print('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Error: ${err.error}');
      print('│ Message: ${err.message}');
      if (err.response?.data != null) {
        print('│ Response Data: ${err.response?.data}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}

