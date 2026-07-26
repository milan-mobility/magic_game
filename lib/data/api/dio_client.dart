import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' as gett;
import 'package:magic_games/data/api/dio_interceptor.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient extends gett.GetxController implements gett.GetxService {
  // injecting dio instance
  DioClient(this._dio, this._remoteConfigService, {final String? deviceToken}) {
    _dio
      ..interceptors.add(DioInterceptor())
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          request: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          (final X509Certificate cert, final String host, final int port) =>
              true;
      return client;
    };
    _applyRuntimeConfig();
  }

  // dio instance
  final Dio _dio;
  final RemoteConfigService _remoteConfigService;

  void _applyRuntimeConfig() {
    _dio.options
      ..baseUrl = _remoteConfigService.baseUrl
      ..connectTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 60)
      ..responseType = ResponseType.json
      ..contentType = Headers.jsonContentType;
  }

  // Get:-----------------------------------------------------------------------
  Future<Response<dynamic>> get(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      final Response<dynamic> response = await _dio.get(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post:----------------------------------------------------------------------
  Future<Response<dynamic>> post(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      final Response<dynamic> response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Patch:-----------------------------------------------------------------------
  Future<Response<dynamic>> patch(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      final Response<dynamic> response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Put:-----------------------------------------------------------------------
  Future<Response<dynamic>> put(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      final Response<dynamic> response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete:--------------------------------------------------------------------
  Future<Response<dynamic>> delete(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      final Response<dynamic> response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Option:----------------------------------------------------------------------
  Future<Response<dynamic>> option(
    final String uri, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
  }) async {
    _applyRuntimeConfig();
    try {
      Options? dioOptions = options;
      dioOptions ??= Options();
      dioOptions.method = 'OPTIONS';
      final Response<dynamic> response = await _dio.request(
        uri,
        options: dioOptions,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
