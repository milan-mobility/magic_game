// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';

class DioExceptions implements Exception {
  DioExceptions.fromDioError(final DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled'.tr;
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout with API server'.tr;
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in connection with API server'.tr;
        break;
      case DioExceptionType.badResponse:
        error = error;
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with API server'.tr;
        break;
      case DioExceptionType.connectionError:
        message = 'Connection Error'.tr;
        break;
      case DioExceptionType.unknown:
        if ((dioError.message ?? '').contains('SocketException')) {
          message = 'No Internet'.tr;
          break;
        } else if ((dioError.message ?? '').contains('HandshakeException')) {
          message = 'Response data not found'.tr;
          break;
        }
        message = 'Unexpected error occurred'.tr;
        break;
      default:
        message = 'Something went wrong'.tr;
        break;
    }
  }
  late String message;
  String? error;

  String _handleError(final int? statusCode, final dynamic error) {
    switch (statusCode) {
      case 400:
        return error['message'] ?? 'Bad request'.tr;
      case 401:
        return error['message'] ?? 'Unauthorized'.tr;
      case 403:
        return error['message'] ?? 'Forbidden'.tr;
      case 404:
        return error['message'];
      case 420:
        return 'Session Expired. Please LogIn again'.tr;
      case 500:
        return error['message'] ?? 'Internal server error'.tr;
      case 502:
        return error['message'] ?? 'Server unavailable'.tr;
      default:
        return 'Oops something went wrong'.tr;
    }
  }

  @override
  String toString() => message;
}
