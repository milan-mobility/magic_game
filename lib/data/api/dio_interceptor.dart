import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioInterceptor extends InterceptorsWrapper {
  DioInterceptor({super.onRequest, super.onResponse, super.onError});

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    final Map<String, dynamic> header = <String, dynamic>{
      'Content-Type': 'application/json',
    };
    options.headers = header;
    super.onRequest(options, handler);
  }

  @override
  void onError(final DioException err, final ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    debugPrint("ERROR=>${err.message}");
  }
}
