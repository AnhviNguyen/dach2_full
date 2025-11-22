package org.example.backend.service.impl;

import org.example.backend.dto.CourseInfoResponse;
import org.example.backend.dto.CourseRequest;
import org.example.backend.dto.DashboardStatsResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.entity.Course;
import org.example.backend.entity.CourseEnrollment;
import org.example.backend.entity.DashboardStats;
import org.example.backend.entity.User;
import org.example.backend.repository.CourseEnrollmentRepository;
import org.example.backend.repository.CourseRepository;
import org.example.backend.repository.DashboardStatsRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.CourseService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CourseServiceImpl implements CourseService {
    private final CourseRepository courseRepository;
    private final CourseEnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final DashboardStatsRepository dashboardStatsRepository;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public CourseServiceImpl(CourseRepository courseRepository,
                            CourseEnrollmentRepository enrollmentRepository,
                            UserRepository userRepository,
                            DashboardStatsRepository dashboardStatsRepository) {
        this.courseRepository = courseRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.userRepository = userRepository;
        this.dashboardStatsRepository = dashboardStatsRepository;
    }

    @Override
    public PageResponse<CourseInfoResponse> getAllCourses(Pageable pageable) {
        Page<Course> courses = courseRepository.findAll(pageable);
        List<CourseInfoResponse> content = courses.getContent().stream()
                .map(this::toCourseInfoResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            courses.getNumber(),
            courses.getSize(),
            courses.getTotalElements(),
            courses.getTotalPages(),
            courses.hasNext(),
            courses.hasPrevious()
        );
    }

    @Override
    public CourseInfoResponse getCourseById(Long id) {
        Course course = courseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Course not found with id: " + id));
        return toCourseInfoResponse(course);
    }

    @Override
    public CourseInfoResponse createCourse(CourseRequest request) {
        Course course = new Course();
        updateCourseFromRequest(course, request);
        Course saved = courseRepository.save(course);
        return toCourseInfoResponse(saved);
    }

    @Override
    public CourseInfoResponse updateCourse(Long id, CourseRequest request) {
        Course course = courseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Course not found with id: " + id));
        updateCourseFromRequest(course, request);
        Course updated = courseRepository.save(course);
        return toCourseInfoResponse(updated);
    }

    @Override
    public void deleteCourse(Long id) {
        if (!courseRepository.existsById(id)) {
            throw new RuntimeException("Course not found with id: " + id);
        }
        courseRepository.deleteById(id);
    }

    @Override
    public PageResponse<CourseInfoResponse> getCoursesByLevel(String level, Pageable pageable) {
        Page<Course> courses = courseRepository.findByLevel(level, pageable);
        List<CourseInfoResponse> content = courses.getContent().stream()
                .map(this::toCourseInfoResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            courses.getNumber(),
            courses.getSize(),
            courses.getTotalElements(),
            courses.getTotalPages(),
            courses.hasNext(),
            courses.hasPrevious()
        );
    }

    @Override
    public DashboardStatsResponse getDashboardStats(Long userId) {
        DashboardStats stats = dashboardStatsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    DashboardStats newStats = new DashboardStats();
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("User not found"));
                    newStats.setUser(user);
                    return dashboardStatsRepository.save(newStats);
                });
        
        return new DashboardStatsResponse(
            stats.getTotalCourses(),
            stats.getCompletedCourses(),
            stats.getTotalVideos(),
            stats.getWatchedVideos(),
            stats.getTotalExams(),
            stats.getCompletedExams(),
            stats.getTotalWatchTime(),
            stats.getCompletedWatchTime(),
            stats.getLastAccess() != null ? stats.getLastAccess().toString() : null,
            stats.getEndDate() != null ? stats.getEndDate().format(DATE_FORMATTER) : null
        );
    }

    @Override
    public CourseInfoResponse enrollUser(Long courseId, Long userId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        CourseEnrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(userId, courseId)
                .orElseGet(() -> {
                    CourseEnrollment newEnrollment = new CourseEnrollment();
                    newEnrollment.setUser(user);
                    newEnrollment.setCourse(course);
                    newEnrollment.setIsEnrolled(true);
                    newEnrollment.setProgress(0.0);
                    return enrollmentRepository.save(newEnrollment);
                });
        
        enrollment.setIsEnrolled(true);
        enrollmentRepository.save(enrollment);
        
        return toCourseInfoResponseWithEnrollment(course, enrollment);
    }

    private CourseInfoResponse toCourseInfoResponse(Course course) {
        String duration = formatDuration(course.getDurationStart(), course.getDurationEnd());
        return new CourseInfoResponse(
            course.getId(),
            course.getTitle(),
            course.getInstructor(),
            course.getLevel(),
            course.getRating(),
            course.getStudents(),
            course.getLessons(),
            duration,
            course.getPrice(),
            course.getImage(),
            0.0,
            false,
            course.getAccentColor()
        );
    }

    private CourseInfoResponse toCourseInfoResponseWithEnrollment(Course course, CourseEnrollment enrollment) {
        String duration = formatDuration(course.getDurationStart(), course.getDurationEnd());
        return new CourseInfoResponse(
            course.getId(),
            course.getTitle(),
            course.getInstructor(),
            course.getLevel(),
            course.getRating(),
            course.getStudents(),
            course.getLessons(),
            duration,
            course.getPrice(),
            course.getImage(),
            enrollment.getProgress(),
            enrollment.getIsEnrolled(),
            course.getAccentColor()
        );
    }

    private String formatDuration(java.time.LocalDate start, java.time.LocalDate end) {
        if (start == null || end == null) {
            return "";
        }
        return start.format(DATE_FORMATTER) + " ~ " + end.format(DATE_FORMATTER);
    }

    private void updateCourseFromRequest(Course course, CourseRequest request) {
        course.setTitle(request.title());
        course.setInstructor(request.instructor());
        course.setLevel(request.level());
        course.setRating(request.rating());
        course.setStudents(request.students());
        course.setLessons(request.lessons());
        course.setDurationStart(request.durationStart());
        course.setDurationEnd(request.durationEnd());
        course.setPrice(request.price());
        course.setImage(request.image());
        course.setAccentColor(request.accentColor());
    }
}

