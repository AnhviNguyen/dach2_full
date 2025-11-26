package org.example.backend.service;

import org.example.backend.dto.TaskItemResponse;

import java.util.List;

public interface TaskService {
    List<TaskItemResponse> getUserTasks(Long userId);
    void generateDailyTasks(Long userId);
}

