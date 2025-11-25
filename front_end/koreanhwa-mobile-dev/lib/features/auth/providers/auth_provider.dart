import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/storage/secure_storage_service.dart';
import 'package:koreanhwa_flutter/features/auth/data/models/auth_models.dart';
import 'package:koreanhwa_flutter/features/auth/data/services/auth_service.dart';

/// Auth State
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth Notifier với Stream để listen auth state changes
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Stream để listen auth state changes
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// Check authentication status khi khởi động app
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
      _authStateController.add(state);
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
      _authStateController.add(state);
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    _authStateController.add(state);

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: authResponse.user,
        isLoading: false,
      );
      _authStateController.add(state);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      _authStateController.add(state);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đăng nhập thất bại: ${e.toString()}',
      );
      _authStateController.add(state);
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    _authStateController.add(state);

    try {
      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        username: username,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: authResponse.user,
        isLoading: false,
      );
      _authStateController.add(state);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      _authStateController.add(state);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đăng ký thất bại: ${e.toString()}',
      );
      _authStateController.add(state);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    _authStateController.add(state);

    try {
      await _authService.logout();
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
      );
      _authStateController.add(state);
    } catch (e) {
      // Vẫn logout ngay cả khi API call thất bại
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: e.toString(),
      );
      _authStateController.add(state);
    }
  }

  /// Google Sign-In
  Future<bool> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    _authStateController.add(state);

    try {
      final authResponse = await _authService.signInWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: authResponse.user,
        isLoading: false,
      );
      _authStateController.add(state);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      _authStateController.add(state);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đăng nhập Google thất bại: ${e.toString()}',
      );
      _authStateController.add(state);
      return false;
    }
  }

  /// Refresh token
  Future<void> refreshToken() async {
    try {
      await _authService.refreshToken();
      // Cập nhật user nếu cần
      if (state.isAuthenticated) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(user: user);
        _authStateController.add(state);
      }
    } catch (e) {
      // Nếu refresh thất bại, logout
      await logout();
    }
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}

/// Provider cho AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

