import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/config/api_config.dart';
import 'package:koreanhwa_flutter/core/storage/secure_storage_service.dart';

/// Interceptor để tự động thêm JWT token vào header và xử lý refresh token
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService = SecureStorageService();
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy access token từ storage
    final accessToken = await _storageService.getAccessToken();

    // Thêm token vào header nếu có
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[ApiConfig.headerAuthorization] =
          '${ApiConfig.bearerPrefix}$accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Xử lý khi token hết hạn (401 Unauthorized)
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        // Thử refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Lấy lại access token mới
          final newAccessToken = await _storageService.getAccessToken();
          if (newAccessToken != null) {
            // Retry request với token mới
            final opts = err.requestOptions;
            opts.headers[ApiConfig.headerAuthorization] =
                '${ApiConfig.bearerPrefix}$newAccessToken';

            final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
            final response = await dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );

            _isRefreshing = false;
            return handler.resolve(response);
          }
        }
      } catch (e) {
        // Refresh token thất bại, có thể cần logout
        await _storageService.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Refresh token khi hết hạn
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final response = await dio.post(
        ApiConfig.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int?;

        if (newAccessToken != null) {
          await _storageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            expiresIn: expiresIn,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

