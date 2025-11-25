package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.AuthService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public AuthResponse login(AuthRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new RuntimeException("Email hoặc mật khẩu không đúng"));

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new RuntimeException("Email hoặc mật khẩu không đúng");
        }

        String accessToken = generateToken(user.getId());
        String refreshToken = generateRefreshToken(user.getId());

        return new AuthResponse(
                accessToken,
                refreshToken,
                3600, // 1 hour
                toUserResponse(user)
        );
    }

    @Override
    public AuthResponse register(RegisterRequest request) {
        // Kiểm tra email đã tồn tại
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new RuntimeException("Email đã được sử dụng");
        }

        // Kiểm tra username đã tồn tại (nếu có)
        if (request.username() != null && !request.username().isEmpty()) {
            if (userRepository.findByUsername(request.username()).isPresent()) {
                throw new RuntimeException("Username đã được sử dụng");
            }
        }

        // Tạo user mới
        User user = new User();
        user.setName(request.name());
        user.setEmail(request.email());
        user.setPassword(passwordEncoder.encode(request.password()));
        
        // Tạo username từ email nếu không có
        if (request.username() != null && !request.username().isEmpty()) {
            user.setUsername(request.username());
        } else {
            user.setUsername(request.email().split("@")[0] + "_" + System.currentTimeMillis());
        }
        
        user.setLevel("Sơ cấp 1");
        user.setPoints(0);
        user.setStreakDays(0);

        User savedUser = userRepository.save(user);

        String accessToken = generateToken(savedUser.getId());
        String refreshToken = generateRefreshToken(savedUser.getId());

        return new AuthResponse(
                accessToken,
                refreshToken,
                3600, // 1 hour
                toUserResponse(savedUser)
        );
    }

    @Override
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        // TODO: Validate refresh token và generate new access token
        // Tạm thời return token mới
        Long userId = extractUserIdFromToken(request.refreshToken());
        String newAccessToken = generateToken(userId);
        String newRefreshToken = generateRefreshToken(userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new AuthResponse(
                newAccessToken,
                newRefreshToken,
                3600,
                toUserResponse(user)
        );
    }

    @Override
    public AuthResponse googleSignIn(GoogleSignInRequest request) {
        // TODO: Verify Google ID token
        // Tạm thời tạo user mới hoặc tìm user theo email từ Google token
        // Giả sử email được extract từ idToken (trong thực tế cần verify với Google)
        
        // Tạm thời: tạo user mới hoặc tìm user theo email
        // Trong production, cần verify Google token
        String email = extractEmailFromGoogleToken(request.idToken());
        
        User user = userRepository.findByEmail(email)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    newUser.setName(extractNameFromGoogleToken(request.idToken()));
                    newUser.setUsername(email.split("@")[0] + "_" + System.currentTimeMillis());
                    newUser.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
                    newUser.setLevel("Sơ cấp 1");
                    newUser.setPoints(0);
                    newUser.setStreakDays(0);
                    return userRepository.save(newUser);
                });

        String accessToken = generateToken(user.getId());
        String refreshToken = generateRefreshToken(user.getId());

        return new AuthResponse(
                accessToken,
                refreshToken,
                3600,
                toUserResponse(user)
        );
    }

    @Override
    public UserResponse getCurrentUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return toUserResponse(user);
    }

    @Override
    public void logout(Long userId) {
        // TODO: Invalidate tokens
        // Tạm thời không làm gì, chỉ cần client xóa tokens
    }

    private String generateToken(Long userId) {
        // TODO: Implement JWT token generation
        // Tạm thời dùng simple token
        return "token_" + userId + "_" + System.currentTimeMillis();
    }

    private String generateRefreshToken(Long userId) {
        // TODO: Implement refresh token generation
        return "refresh_" + userId + "_" + System.currentTimeMillis();
    }

    private Long extractUserIdFromToken(String token) {
        // TODO: Extract user ID from token
        // Tạm thời parse từ token format
        try {
            String[] parts = token.split("_");
            return Long.parseLong(parts[1]);
        } catch (Exception e) {
            throw new RuntimeException("Invalid token");
        }
    }

    private String extractEmailFromGoogleToken(String idToken) {
        // TODO: Decode và verify Google ID token
        // Tạm thời return dummy email
        return "google_user_" + System.currentTimeMillis() + "@gmail.com";
    }

    private String extractNameFromGoogleToken(String idToken) {
        // TODO: Extract name from Google token
        return "Google User";
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getUsername(),
                user.getAvatar(),
                user.getLevel(),
                user.getPoints(),
                user.getStreakDays()
        );
    }
}

