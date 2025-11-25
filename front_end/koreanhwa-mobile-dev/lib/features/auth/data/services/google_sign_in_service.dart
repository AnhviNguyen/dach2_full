import 'package:google_sign_in/google_sign_in.dart';

/// Service để xử lý Google Sign-In
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Đăng nhập bằng Google
  Future<GoogleSignInResult> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        return GoogleSignInResult(
          success: false,
          error: 'Người dùng đã hủy đăng nhập',
        );
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      return GoogleSignInResult(
        success: true,
        idToken: auth.idToken,
        accessToken: auth.accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      return GoogleSignInResult(
        success: false,
        error: 'Đăng nhập Google thất bại: ${e.toString()}',
      );
    }
  }

  /// Đăng xuất Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Kiểm tra đã đăng nhập Google chưa
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Lấy thông tin account hiện tại
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}

/// Kết quả đăng nhập Google
class GoogleSignInResult {
  final bool success;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? error;

  GoogleSignInResult({
    required this.success,
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.error,
  });
}

