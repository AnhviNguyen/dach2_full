import 'package:koreanhwa_flutter/core/storage/secure_storage_service.dart';

class UserUtils {
  static final SecureStorageService _storageService = SecureStorageService();

  /// Get user ID from access token
  /// Token format: "token_userId_timestamp"
  static Future<int?> getUserId() async {
    try {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        final parts = accessToken.split('_');
        if (parts.length >= 2) {
          return int.tryParse(parts[1]);
        }
      }
    } catch (e) {
      // Ignore parse error
    }
    return null;
  }
}

