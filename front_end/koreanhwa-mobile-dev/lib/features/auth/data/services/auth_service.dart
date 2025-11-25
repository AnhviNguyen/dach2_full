import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/config/api_config.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/core/storage/secure_storage_service.dart';
import 'package:koreanhwa_flutter/features/auth/data/models/auth_models.dart';

/// Authentication Service với đầy đủ các chức năng
class AuthService {
  final DioClient _dioClient = DioClient();
  final SecureStorageService _storageService = SecureStorageService();

  /// Login bằng email/password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dioClient.post(
        ApiConfig.authLogin,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Lưu tokens vào secure storage
      await _storageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiresIn: authResponse.expiresIn,
      );

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'Đăng nhập thất bại: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Register user mới
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        username: username,
      );

      final response = await _dioClient.post(
        ApiConfig.authRegister,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Lưu tokens vào secure storage
      await _storageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiresIn: authResponse.expiresIn,
      );

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'Đăng ký thất bại: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Gọi API logout (nếu có)
      try {
        await _dioClient.post(ApiConfig.authLogout);
      } catch (e) {
        // Ignore nếu API không tồn tại hoặc lỗi
      }

      // Xóa tokens từ storage
      await _storageService.clearTokens();
    } catch (e) {
      // Vẫn xóa tokens ngay cả khi API call thất bại
      await _storageService.clearTokens();
      throw ApiException(
        message: 'Đăng xuất thất bại: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Google Sign-In integration
  Future<AuthResponse> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final request = GoogleSignInRequest(
        idToken: idToken,
        accessToken: accessToken,
      );

      final response = await _dioClient.post(
        ApiConfig.authGoogle,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Lưu tokens vào secure storage
      await _storageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiresIn: authResponse.expiresIn,
      );

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'Đăng nhập Google thất bại: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Refresh token tự động
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dioClient.post(
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

  /// Check authentication status
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }

  /// Lấy thông tin user hiện tại
  Future<UserModel> getCurrentUser() async {
    try {
      // Extract userId từ token để gửi lên server
      final accessToken = await _storageService.getAccessToken();
      int? userId;
      
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          // Parse userId từ token format "token_userId_timestamp"
          final parts = accessToken.split('_');
          if (parts.length >= 2) {
            userId = int.tryParse(parts[1]);
          }
        } catch (e) {
          // Ignore parse error
        }
      }

      final queryParams = userId != null ? {'userId': userId} : null;
      final response = await _dioClient.get(
        ApiConfig.authMe,
        queryParameters: queryParams,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'Không thể lấy thông tin user: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Lấy access token hiện tại
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }
}

