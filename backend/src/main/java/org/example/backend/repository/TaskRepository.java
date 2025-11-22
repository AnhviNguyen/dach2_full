package org.example.backend.repository;

import org.example.backend.entity.Task;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    Page<Task> findAll(Pageable pageable);
    List<Task> findByUserId(Long userId);
    Page<Task> findByUserId(Long userId, Pageable pageable);
}

