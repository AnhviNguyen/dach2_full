# KoreanHwa Backend API

Backend Spring Boot application với JPA, MySQL cho ứng dụng học tiếng Hàn.

## Cấu trúc dự án

```
backend/
├── src/main/java/org/example/backend/
│   ├── entity/          # JPA Entities
│   ├── repository/      # Repository interfaces
│   ├── service/         # Service interfaces
│   │   └── impl/        # Service implementations
│   ├── dto/             # DTOs (Request/Response records)
│   ├── controller/      # REST Controllers
│   └── config/          # Configuration classes
├── src/main/resources/
│   ├── schema.sql       # SQL schema
│   └── application.properties
└── build.gradle
```

## Cài đặt và chạy

### Yêu cầu
- Java 17+
- MySQL 8.0+
- Gradle

### Cấu hình Database

1. Tạo database MySQL:
```sql
CREATE DATABASE koreanhwa_db;
```

2. Cập nhật `application.properties` với thông tin MySQL của bạn:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/koreanhwa_db
spring.datasource.username=your_username
spring.datasource.password=your_password
```

3. Chạy schema.sql để tạo các bảng (hoặc để Hibernate tự động tạo với `spring.jpa.hibernate.ddl-auto=update`)

### Chạy ứng dụng

```bash
cd backend/backend
./gradlew bootRun
```

Ứng dụng sẽ chạy tại: `http://localhost:8080`

## API Endpoints

### Courses
- `GET /api/courses` - Lấy danh sách khóa học (có phân trang)
- `GET /api/courses/{id}` - Lấy chi tiết khóa học
- `POST /api/courses` - Tạo khóa học mới
- `PUT /api/courses/{id}` - Cập nhật khóa học
- `DELETE /api/courses/{id}` - Xóa khóa học
- `GET /api/courses/level/{level}` - Lấy khóa học theo level
- `GET /api/courses/dashboard-stats/{userId}` - Lấy thống kê dashboard
- `POST /api/courses/{courseId}/enroll/{userId}` - Đăng ký khóa học

### Textbooks
- `GET /api/textbooks` - Lấy danh sách giáo trình
- `GET /api/textbooks/{id}` - Lấy chi tiết giáo trình
- `GET /api/textbooks/book-number/{bookNumber}` - Lấy giáo trình theo số quyển
- `POST /api/textbooks` - Tạo giáo trình mới
- `PUT /api/textbooks/{id}` - Cập nhật giáo trình
- `DELETE /api/textbooks/{id}` - Xóa giáo trình
- `GET /api/textbooks/{textbookId}/progress/{userId}` - Lấy tiến độ học

### Lessons
- `GET /api/lessons` - Lấy danh sách bài học
- `GET /api/lessons/{id}` - Lấy chi tiết bài học (bao gồm từ vựng, ngữ pháp, bài tập)
- `GET /api/lessons/textbook/{textbookId}` - Lấy bài học theo giáo trình
- `GET /api/lessons/course/{courseId}` - Lấy bài học theo khóa học

### Rankings
- `GET /api/rankings` - Lấy bảng xếp hạng (có phân trang)
- `GET /api/rankings/all` - Lấy toàn bộ bảng xếp hạng
- `GET /api/rankings/user/{userId}` - Lấy xếp hạng của user

### Achievements
- `GET /api/achievements` - Lấy danh sách thành tựu
- `GET /api/achievements/user/{userId}` - Lấy thành tựu của user
- `GET /api/achievements/user/{userId}/achievement/{achievementId}` - Lấy chi tiết thành tựu

### Blog
- `GET /api/blog/posts` - Lấy danh sách bài viết
- `GET /api/blog/posts/{id}` - Lấy chi tiết bài viết
- `POST /api/blog/posts` - Tạo bài viết mới
- `PUT /api/blog/posts/{id}` - Cập nhật bài viết
- `DELETE /api/blog/posts/{id}` - Xóa bài viết
- `GET /api/blog/posts/author/{authorId}` - Lấy bài viết theo tác giả
- `POST /api/blog/posts/{postId}/like/{userId}` - Like/Unlike bài viết

## Phân trang

Tất cả các endpoint danh sách hỗ trợ phân trang với các tham số:
- `page` (default: 0) - Số trang
- `size` (default: 10) - Số phần tử mỗi trang
- `sortBy` (default: "id") - Trường sắp xếp
- `direction` (default: "ASC") - Hướng sắp xếp (ASC/DESC)

Ví dụ:
```
GET /api/courses?page=0&size=20&sortBy=title&direction=ASC
```

## Response Format

Tất cả response đều trả về JSON format giống với Flutter mock data:

```json
{
  "id": 1,
  "title": "...",
  "instructor": "...",
  ...
}
```

Với danh sách có phân trang:
```json
{
  "content": [...],
  "page": 0,
  "size": 10,
  "totalElements": 100,
  "totalPages": 10,
  "hasNext": true,
  "hasPrevious": false
}
```

## Entities và Relationships

- **User** - Người dùng
- **Course** - Khóa học (OneToMany với CourseEnrollment, Lesson)
- **CourseEnrollment** - Đăng ký khóa học (ManyToOne với User, Course)
- **Textbook** - Giáo trình (OneToMany với TextbookProgress, Lesson)
- **TextbookProgress** - Tiến độ học giáo trình (ManyToOne với User, Textbook)
- **Lesson** - Bài học (ManyToOne với Textbook/Course, OneToMany với Vocabulary, Grammar, Exercise)
- **Vocabulary** - Từ vựng (ManyToOne với Lesson)
- **Grammar** - Ngữ pháp (ManyToOne với Lesson, OneToMany với GrammarExample)
- **Exercise** - Bài tập (ManyToOne với Lesson, OneToMany với ExerciseOption)
- **Ranking** - Xếp hạng (OneToOne với User)
- **Achievement** - Thành tựu (OneToMany với UserAchievement)
- **UserAchievement** - Thành tựu của user (ManyToOne với User, Achievement)
- **BlogPost** - Bài viết blog (ManyToOne với User, OneToMany với BlogTag, BlogLike)
- **DashboardStats** - Thống kê dashboard (OneToOne với User)

## Lưu ý

- Tất cả DTOs sử dụng Java Records
- Foreign keys được định nghĩa rõ ràng với @ManyToOne, @OneToMany
- ID sử dụng BIGINT AUTO_INCREMENT (tương đương BIGSERIAL)
- CORS đã được cấu hình để cho phép tất cả origins
- Security đã được disable tạm thời (cần thêm authentication sau)

