import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as gett;
import 'package:magic_games/data/api/dio_interceptor.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/utils/app_toast.dart';
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

  void _applyRuntimeConfig({String? baseUrl}) {
    _dio.options
      ..baseUrl = baseUrl ?? _remoteConfigService.baseUrl
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
    return _requestWithBaseUrlFallback(
      method: 'GET',
      uri: uri,
      execute: () => _dio.get(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
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
    return _requestWithBaseUrlFallback(
      method: 'POST',
      uri: uri,
      execute: () => _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
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
    return _requestWithBaseUrlFallback(
      method: 'PATCH',
      uri: uri,
      execute: () => _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
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
    return _requestWithBaseUrlFallback(
      method: 'PUT',
      uri: uri,
      execute: () => _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
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
    return _requestWithBaseUrlFallback(
      method: 'DELETE',
      uri: uri,
      execute: () => _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
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
    Options? dioOptions = options;
    dioOptions ??= Options();
    dioOptions.method = 'OPTIONS';

    return _requestWithBaseUrlFallback(
      method: 'OPTIONS',
      uri: uri,
      execute: () => _dio.request(
        uri,
        options: dioOptions,
      ),
    );
  }

  Future<Response<dynamic>> _requestWithBaseUrlFallback({
    required final String method,
    required final String uri,
    required final Future<Response<dynamic>> Function() execute,
  }) async {
    DioException? lastDioException;
    Object? lastError;
    StackTrace? lastStackTrace;

    for (final String baseUrl in _remoteConfigService.requestBaseUrls) {
      _applyRuntimeConfig(baseUrl: baseUrl);

      try {
        final Response<dynamic> response = await execute();
        _remoteConfigService.markWorkingBaseUrl(baseUrl);
        if (kDebugMode) {
            showToast(message: baseUrl);
        }

        return response;
      } on DioException catch (error, stackTrace) {
        lastDioException = error;
        lastStackTrace = stackTrace;

        if (!_shouldRetryWithNextBaseUrl(error)) {
          rethrow;
        }

        debugPrint(
          '$method $uri failed on $baseUrl. Trying the next base URL. Error: ${error.message}',
        );
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        debugPrint(
          '$method $uri failed on $baseUrl with an unexpected error. Trying the next base URL. Error: $error',
        );
      }
    }

    if (lastDioException != null) {
      throw lastDioException;
    }
    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError!, lastStackTrace!);
    }

    throw StateError('No base URL candidates were available for $method $uri.');
  }

  bool _shouldRetryWithNextBaseUrl(final DioException error) {
    return error.type != DioExceptionType.cancel;
  }
}
