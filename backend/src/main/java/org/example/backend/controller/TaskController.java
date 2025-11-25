package org.example.backend.controller;

import org.example.backend.dto.TaskItemResponse;
import org.example.backend.service.TaskService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@CrossOrigin(origins = "*")
public class TaskController {
    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<TaskItemResponse>> getUserTasks(@PathVariable(value = "userId") Long userId) {
        List<TaskItemResponse> response = taskService.getUserTasks(userId);
        return ResponseEntity.ok(response);
    }
}

