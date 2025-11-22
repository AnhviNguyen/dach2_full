package org.example.backend.dto;

import java.time.LocalDate;

public record CourseRequest(
    String title,
    String instructor,
    String level,
    Double rating,
    Integer students,
    Integer lessons,
    LocalDate durationStart,
    LocalDate durationEnd,
    String price,
    String image,
    String accentColor
) {}

