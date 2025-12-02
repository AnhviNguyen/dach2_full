package org.example.backend.controller;

import org.example.backend.dto.UserResponse;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {
    private final UserRepository userRepository;
    private static final String UPLOAD_DIR = "uploads/avatars/";

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
        // Tạo thư mục uploads nếu chưa tồn tại
        try {
            Files.createDirectories(Paths.get(UPLOAD_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable(value = "id") Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        UserResponse response = new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getUsername(),
                user.getAvatar(),
                user.getLevel(),
                user.getPoints(),
                user.getStreakDays()
        );
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable(value = "id") Long id,
            @RequestBody UserUpdateRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (request.name() != null) {
            user.setName(request.name());
        }
        if (request.avatar() != null) {
            user.setAvatar(request.avatar());
        }
        if (request.level() != null) {
            user.setLevel(request.level());
        }
        
        User updated = userRepository.save(user);
        
        UserResponse response = new UserResponse(
                updated.getId(),
                updated.getName(),
                updated.getEmail(),
                updated.getUsername(),
                updated.getAvatar(),
                updated.getLevel(),
                updated.getPoints(),
                updated.getStreakDays()
        );
        
        return ResponseEntity.ok(response);
    }

    @PostMapping(value = "/{id}/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<UserResponse> uploadAvatar(
            @PathVariable(value = "id") Long id,
            @RequestParam("file") MultipartFile file) {
        try {
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Validate file
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            // Validate image type
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().build();
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String filename = "avatar_" + id + "_" + UUID.randomUUID().toString() + extension;

            // Save file
            Path uploadPath = Paths.get(UPLOAD_DIR + filename);
            Files.copy(file.getInputStream(), uploadPath, StandardCopyOption.REPLACE_EXISTING);

            // Update user avatar URL - chỉ lưu path tương đối
            String avatarUrl = "uploads/avatars/" + filename;
            user.setAvatar(avatarUrl);
            User updated = userRepository.save(user);

            UserResponse response = new UserResponse(
                    updated.getId(),
                    updated.getName(),
                    updated.getEmail(),
                    updated.getUsername(),
                    updated.getAvatar(),
                    updated.getLevel(),
                    updated.getPoints(),
                    updated.getStreakDays()
            );

            return ResponseEntity.ok(response);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}

record UserUpdateRequest(
    String name,
    String avatar,
    String level
) {}

