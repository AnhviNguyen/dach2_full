import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:koreanhwa_flutter/core/config/api_config.dart';

/// Service để lưu trữ token an toàn bằng flutter_secure_storage
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    webOptions: WebOptions(
      dbName: 'koreanhwa_secure_storage',
      publicKey: 'koreanhwa_public_key',
    ),
  );

  /// Lưu access token và refresh token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    try {
      await Future.wait([
        _storage.write(
          key: ApiConfig.storageAccessToken,
          value: accessToken,
        ),
        _storage.write(
          key: ApiConfig.storageRefreshToken,
          value: refreshToken,
        ),
      ]);

      if (expiresIn != null) {
        final expiryTime = DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch
            .toString();
        await _storage.write(
          key: ApiConfig.storageTokenExpiry,
          value: expiryTime,
        );
      }
    } catch (e) {
      // Log error nhưng không throw để app vẫn chạy được
      if (kDebugMode) {
        print('Warning: Failed to save tokens to secure storage: $e');
      }
      // Trên web, có thể fallback sang localStorage nếu cần
      rethrow;
    }
  }

  /// Lấy access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: ApiConfig.storageAccessToken);
    } catch (e) {
      // Trên web, nếu secure storage fail, trả về null thay vì throw error
      if (kDebugMode) {
        print('Warning: Failed to read access token from secure storage: $e');
      }
      return null;
    }
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: ApiConfig.storageRefreshToken);
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Failed to read refresh token from secure storage: $e');
      }
      return null;
    }
  }

  /// Kiểm tra token có hết hạn không
  Future<bool> isTokenExpired() async {
    try {
      final expiryTimeStr = await _storage.read(
        key: ApiConfig.storageTokenExpiry,
      );

      if (expiryTimeStr == null) {
        return true;
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(expiryTimeStr),
      );

      // Kiểm tra nếu token hết hạn trong vòng 5 phút tới
      return DateTime.now().isAfter(expiryTime.subtract(const Duration(minutes: 5)));
    } catch (e) {
      // Nếu không đọc được expiry time, coi như token đã hết hạn
      if (kDebugMode) {
        print('Warning: Failed to read token expiry: $e');
      }
      return true;
    }
  }

  /// Xóa tất cả tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: ApiConfig.storageAccessToken),
        _storage.delete(key: ApiConfig.storageRefreshToken),
        _storage.delete(key: ApiConfig.storageTokenExpiry),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Failed to clear tokens: $e');
      }
    }
  }

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    // Kiểm tra token chưa hết hạn
    return !(await isTokenExpired());
  }
}

