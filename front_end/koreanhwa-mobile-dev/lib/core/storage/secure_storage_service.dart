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
  );

  /// Lưu access token và refresh token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
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
  }

  /// Lấy access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConfig.storageAccessToken);
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: ApiConfig.storageRefreshToken);
  }

  /// Kiểm tra token có hết hạn không
  Future<bool> isTokenExpired() async {
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
  }

  /// Xóa tất cả tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: ApiConfig.storageAccessToken),
      _storage.delete(key: ApiConfig.storageRefreshToken),
      _storage.delete(key: ApiConfig.storageTokenExpiry),
    ]);
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

