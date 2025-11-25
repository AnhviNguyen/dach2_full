package org.example.backend.controller;

import org.example.backend.dto.UserResponse;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {
    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
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
}

record UserUpdateRequest(
    String name,
    String avatar,
    String level
) {}

