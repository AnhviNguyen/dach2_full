import 'package:dio/dio.dart';

/// Interceptor để xử lý lỗi tập trung
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý các loại lỗi khác nhau
    DioException error = err;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        error = DioException(
          requestOptions: err.requestOptions,
          error: 'Timeout: Kết nối quá lâu, vui lòng thử lại',
          type: err.type,
          response: err.response,
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        String message = 'Đã xảy ra lỗi';
        dynamic responseData = err.response?.data;

        // Extract message from backend response
        if (responseData != null) {
          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] as String? ?? 
                     responseData['error'] as String? ?? 
                     message;
          } else if (responseData is String) {
            message = responseData;
          }
        }

        switch (statusCode) {
          case 400:
            message = message != 'Đã xảy ra lỗi' ? message : 'Yêu cầu không hợp lệ';
            break;
          case 401:
            message = message != 'Đã xảy ra lỗi' ? message : 'Không có quyền truy cập';
            break;
          case 403:
            message = message != 'Đã xảy ra lỗi' ? message : 'Bị từ chối truy cập';
            break;
          case 404:
            message = message != 'Đã xảy ra lỗi' ? message : 'Không tìm thấy tài nguyên';
            break;
          case 500:
            // Log chi tiết lỗi 500 để debug
            print('❌ Server Error 500:');
            print('   URL: ${err.requestOptions.uri}');
            print('   Method: ${err.requestOptions.method}');
            print('   Response: $responseData');
            message = message != 'Đã xảy ra lỗi' ? message : 'Lỗi máy chủ, vui lòng thử lại sau';
            break;
          case 502:
            message = message != 'Đã xảy ra lỗi' ? message : 'Lỗi gateway';
            break;
          case 503:
            message = message != 'Đã xảy ra lỗi' ? message : 'Dịch vụ không khả dụng';
            break;
          default:
            // Giữ nguyên message đã extract từ response
            break;
        }

        error = DioException(
          requestOptions: err.requestOptions,
          error: message,
          type: err.type,
          response: err.response,
        );
        break;

      case DioExceptionType.cancel:
        error = DioException(
          requestOptions: err.requestOptions,
          error: 'Request đã bị hủy',
          type: err.type,
        );
        break;

      case DioExceptionType.unknown:
        if (err.error?.toString().contains('SocketException') == true) {
          error = DioException(
            requestOptions: err.requestOptions,
            error: 'Không có kết nối internet',
            type: err.type,
          );
        } else {
          error = DioException(
            requestOptions: err.requestOptions,
            error: 'Lỗi kết nối: ${err.error}',
            type: err.type,
          );
        }
        break;

      default:
        break;
    }

    handler.next(error);
  }
}

