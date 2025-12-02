import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Base URL có thể config
  // 
  // CÁCH SỬ DỤNG:
  // 1. Thiết bị thật (mặc định): http://192.168.1.8:8000/api
  // 2. Android Emulator: Set API_BASE_URL=http://10.0.2.2:8000/api khi chạy
  // 3. iOS Simulator: http://localhost:8000/api (tự động)
  // 4. Web: http://localhost:8000/api (tự động)
  //
  // LƯU Ý: Sau khi sửa IP, cần REBUILD app (không phải hot reload):
  //   flutter clean
  //   flutter run
  static String get baseUrl {
    // Ưu tiên: Nếu có set API_BASE_URL từ command line, dùng nó
    final envUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Auto-detect platform
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.242:8080/api';
    } else if (Platform.isIOS) {
      // iOS simulator có thể dùng localhost
      // Nếu chạy trên thiết bị thật, set API_BASE_URL với IP máy host
      return 'http://localhost:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  // Timeout settings - Tăng timeout để tránh lỗi khi mạng chậm
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authGoogle = '/auth/google';
  static const String authMe = '/auth/me';



  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String bearerPrefix = 'Bearer ';

  // Storage keys
  static const String storageAccessToken = 'access_token';
  static const String storageRefreshToken = 'refresh_token';
  static const String storageTokenExpiry = 'token_expiry';

  /// Lấy base URL cho images (không có /api suffix)
  /// Ví dụ: http://192.168.1.242:8080
  static String get imageBaseUrl {
    final url = baseUrl;
    // Remove /api suffix nếu có
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
  }

  /// Ghép baseUrl với avatar path tương đối
  /// 
  /// [relativePath] - Path tương đối từ backend (e.g., "uploads/avatars/filename.jpg")
  /// Nếu [relativePath] đã là URL đầy đủ (http:// hoặc https://), trả về nguyên vẹn
  /// Nếu [relativePath] null hoặc empty, trả về null
  static String? getAvatarUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return null;
    }
    
    // Nếu đã là URL đầy đủ, trả về nguyên vẹn
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    
    // Remove leading slash nếu có
    final cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    
    // Ghép với imageBaseUrl
    return '$imageBaseUrl/$cleanPath';
  }
}

