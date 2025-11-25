package org.example.backend.service.impl;

import org.example.backend.dto.TaskItemResponse;
import org.example.backend.entity.Task;
import org.example.backend.entity.User;
import org.example.backend.repository.TaskRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.TaskService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class TaskServiceImpl implements TaskService {
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public TaskServiceImpl(TaskRepository taskRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
    }

    @Override
    public List<TaskItemResponse> getUserTasks(Long userId) {
        List<Task> tasks = taskRepository.findByUserId(userId);
        
        // Nếu user chưa có task, tạo task mặc định
        if (tasks.isEmpty()) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
            
            // Tạo task mặc định cho user mới
            tasks = createDefaultTasks(user);
        }
        
        return tasks.stream()
                .map(task -> new TaskItemResponse(
                        task.getTitle(),
                        task.getIconName() != null ? task.getIconName() : "task",
                        task.getColor() != null ? task.getColor() : "#000000",
                        task.getProgressColor() != null ? task.getProgressColor() : "#FFD700",
                        task.getProgressPercent() != null ? task.getProgressPercent() : 0.0
                ))
                .collect(Collectors.toList());
    }

    private List<Task> createDefaultTasks(User user) {
        List<Task> defaultTasks = List.of(
                createTask(user, "Học từ vựng", "book", "#FFD700", "#FFD700", 0.0),
                createTask(user, "Học ngữ pháp", "translate", "#4ECDC4", "#4ECDC4", 0.0),
                createTask(user, "Luyện nghe", "hearing", "#FF6B6B", "#FF6B6B", 0.0),
                createTask(user, "Luyện nói", "mic", "#95E1D3", "#95E1D3", 0.0)
        );
        
        return taskRepository.saveAll(defaultTasks);
    }

    private Task createTask(User user, String title, String iconName, String color, String progressColor, Double progressPercent) {
        Task task = new Task();
        task.setUser(user);
        task.setTitle(title);
        task.setIconName(iconName);
        task.setColor(color);
        task.setProgressColor(progressColor);
        task.setProgressPercent(progressPercent);
        return task;
    }
}

