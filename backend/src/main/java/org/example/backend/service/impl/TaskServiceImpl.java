package org.example.backend.service.impl;

import org.example.backend.dto.TaskItemResponse;
import org.example.backend.entity.Task;
import org.example.backend.entity.User;
import org.example.backend.repository.TaskRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.TaskService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
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
        List<Task> allTasks = taskRepository.findByUserId(userId);
        
        // Check if tasks exist for today
        LocalDate today = LocalDate.now();
        List<Task> todayTasks = allTasks.stream()
                .filter(task -> task.getCreatedAt() != null && 
                        task.getCreatedAt().toLocalDate().equals(today))
                .collect(Collectors.toList());
        
        // If no tasks for today, generate daily tasks
        if (todayTasks == null || todayTasks.isEmpty()) {
            generateDailyTasks(userId);
            allTasks = taskRepository.findByUserId(userId);
            todayTasks = allTasks.stream()
                    .filter(task -> task.getCreatedAt() != null && 
                            task.getCreatedAt().toLocalDate().equals(today))
                    .collect(Collectors.toList());
        }
        
        // Only return today's tasks (max 4)
        return todayTasks.stream()
                .limit(4)
                .map(task -> new TaskItemResponse(
                        task.getTitle(),
                        task.getIconName() != null ? task.getIconName() : "task",
                        task.getColor() != null ? task.getColor() : "#000000",
                        task.getProgressColor() != null ? task.getProgressColor() : "#FFD700",
                        task.getProgressPercent() != null ? task.getProgressPercent() / 100.0 : 0.0
                ))
                .collect(Collectors.toList());
    }

    @Override
    public void generateDailyTasks(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Delete old tasks for this user (optional: keep last 7 days)
        LocalDate sevenDaysAgo = LocalDate.now().minusDays(7);
        List<Task> oldTasks = taskRepository.findByUserId(userId).stream()
                .filter(task -> task.getCreatedAt() != null && 
                        task.getCreatedAt().toLocalDate().isBefore(sevenDaysAgo))
                .collect(Collectors.toList());
        if (!oldTasks.isEmpty()) {
            taskRepository.deleteAll(oldTasks);
        }

        // Define task templates
        List<TaskTemplate> taskTemplates = Arrays.asList(
            new TaskTemplate("Học 20 từ vựng mới", "BookOpen", "#FF6B6B", "#FFB6B6"),
            new TaskTemplate("Luyện tập từ vựng", "FileText", "#4ECDC4", "#9EDDD8"),
            new TaskTemplate("Xem video bài giảng mới", "Play", "#95E1D3", "#C5F1E8"),
            new TaskTemplate("Làm bài tập ngữ pháp", "Edit", "#F38181", "#F9B1B1"),
            new TaskTemplate("Luyện nghe 15 phút", "Hearing", "#AA96DA", "#CABDEA"),
            new TaskTemplate("Luyện nói 10 câu", "Mic", "#FCBAD3", "#FDD5E7"),
            new TaskTemplate("Ôn tập từ vựng cũ", "Book", "#FFD93D", "#FFE66D"),
            new TaskTemplate("Hoàn thành bài kiểm tra", "CheckSquare", "#6BCB77", "#9DD9A3")
        );

        // Randomly select 4 tasks
        Collections.shuffle(taskTemplates);
        List<TaskTemplate> selectedTasks = taskTemplates.subList(0, Math.min(4, taskTemplates.size()));

        // Create tasks
        List<Task> newTasks = new ArrayList<>();
        for (TaskTemplate template : selectedTasks) {
            Task task = new Task();
            task.setUser(user);
            task.setTitle(template.title);
            task.setIconName(template.iconName);
            task.setColor(template.color);
            task.setProgressColor(template.progressColor);
            task.setProgressPercent(0.0);
            task.setCreatedAt(LocalDateTime.now());
            newTasks.add(task);
        }

        taskRepository.saveAll(newTasks);
    }

    private static class TaskTemplate {
        final String title;
        final String iconName;
        final String color;
        final String progressColor;

        TaskTemplate(String title, String iconName, String color, String progressColor) {
            this.title = title;
            this.iconName = iconName;
            this.color = color;
            this.progressColor = progressColor;
        }
    }
}

