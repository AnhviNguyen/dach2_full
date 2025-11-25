package org.example.backend.service;

import org.example.backend.dto.AuthRequest;
import org.example.backend.dto.AuthResponse;
import org.example.backend.dto.GoogleSignInRequest;
import org.example.backend.dto.RegisterRequest;
import org.example.backend.dto.RefreshTokenRequest;
import org.example.backend.dto.UserResponse;

public interface AuthService {
    AuthResponse login(AuthRequest request);
    AuthResponse register(RegisterRequest request);
    AuthResponse refreshToken(RefreshTokenRequest request);
    AuthResponse googleSignIn(GoogleSignInRequest request);
    UserResponse getCurrentUser(Long userId);
    void logout(Long userId);
}

