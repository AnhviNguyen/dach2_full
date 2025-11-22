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

## Hướng dẫn Test API

### Bước 1: Khởi động Server

1. Đảm bảo MySQL đang chạy và database `koreanhwa_db` đã được tạo
2. Kiểm tra cấu hình trong `application.properties` (username, password MySQL)
3. Chạy ứng dụng:
   ```bash
   ./gradlew bootRun
   ```
   Hoặc trên Windows:
   ```bash
   gradlew.bat bootRun
   ```
4. Đợi đến khi thấy log: `Started BackendApplication in X.XXX seconds`
5. Server sẽ chạy tại: `http://localhost:8080`

### Bước 2: Test API Textbook

Sau khi đã tạo data trong bảng `textbooks` của MySQL, bạn có thể test các API sau:

#### Cách 1: Sử dụng Postman (Khuyến nghị)

**1. Test GET - Lấy danh sách tất cả giáo trình:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks`
- Headers: Không cần
- Response mong đợi:
  ```json
  {
    "content": [
      {
        "bookNumber": 1,
        "title": "Tiếng Hàn Quyển 1",
        "subtitle": "Cơ bản",
        "totalLessons": 20,
        "completedLessons": 0,
        "isCompleted": false,
        "isLocked": false,
        "color": "#FF5733"
      }
    ],
    "page": 0,
    "size": 10,
    "totalElements": 1,
    "totalPages": 1,
    "hasNext": false,
    "hasPrevious": false
  }
  ```

**2. Test GET với phân trang:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks?page=0&size=5&sortBy=bookNumber&direction=ASC`

**3. Test GET - Lấy giáo trình theo ID:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/1`
  (Thay `1` bằng ID thực tế trong database của bạn)

**4. Test GET - Lấy giáo trình theo số quyển:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/book-number/1`
  (Thay `1` bằng bookNumber thực tế)

**5. Test POST - Tạo giáo trình mới:**
- Method: `POST`
- URL: `http://localhost:8080/api/textbooks`
- Headers: 
  ```
  Content-Type: application/json
  ```
- Body (raw JSON):
  ```json
  {
    "bookNumber": 2,
    "title": "Tiếng Hàn Quyển 2",
    "subtitle": "Trung cấp",
    "totalLessons": 25,
    "color": "#33FF57"
  }
  ```

**6. Test PUT - Cập nhật giáo trình:**
- Method: `PUT`
- URL: `http://localhost:8080/api/textbooks/1`
  (Thay `1` bằng ID cần cập nhật)
- Headers: 
  ```
  Content-Type: application/json
  ```
- Body (raw JSON):
  ```json
  {
    "bookNumber": 1,
    "title": "Tiếng Hàn Quyển 1 - Đã cập nhật",
    "subtitle": "Cơ bản nâng cao",
    "totalLessons": 22,
    "color": "#FF5733"
  }
  ```

**7. Test DELETE - Xóa giáo trình:**
- Method: `DELETE`
- URL: `http://localhost:8080/api/textbooks/1`
  (Thay `1` bằng ID cần xóa)
- Response: Status 204 (No Content)

**8. Test GET - Lấy tiến độ học:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/1/progress/1`
  (Thay `1` đầu tiên là textbookId, `1` thứ hai là userId)

#### Cách 2: Sử dụng cURL (Command Line)

Mở Terminal/PowerShell và chạy các lệnh sau:

**1. Lấy danh sách giáo trình:**
```bash
curl -X GET http://localhost:8080/api/textbooks
```

**2. Lấy giáo trình theo ID:**
```bash
curl -X GET http://localhost:8080/api/textbooks/1
```

**3. Tạo giáo trình mới:**
```bash
curl -X POST http://localhost:8080/api/textbooks ^
  -H "Content-Type: application/json" ^
  -d "{\"bookNumber\": 2, \"title\": \"Tiếng Hàn Quyển 2\", \"subtitle\": \"Trung cấp\", \"totalLessons\": 25, \"color\": \"#33FF57\"}"
```

**4. Cập nhật giáo trình:**
```bash
curl -X PUT http://localhost:8080/api/textbooks/1 ^
  -H "Content-Type: application/json" ^
  -d "{\"bookNumber\": 1, \"title\": \"Tiếng Hàn Quyển 1 - Đã cập nhật\", \"subtitle\": \"Cơ bản\", \"totalLessons\": 22, \"color\": \"#FF5733\"}"
```

**5. Xóa giáo trình:**
```bash
curl -X DELETE http://localhost:8080/api/textbooks/1
```

#### Cách 3: Sử dụng Browser (Chỉ cho GET requests)

Chỉ có thể test các endpoint GET bằng cách mở trình duyệt:

1. Lấy danh sách: `http://localhost:8080/api/textbooks`
2. Lấy theo ID: `http://localhost:8080/api/textbooks/1`
3. Lấy theo số quyển: `http://localhost:8080/api/textbooks/book-number/1`

### Bước 3: Kiểm tra kết quả

- **Status 200 (OK)**: Request thành công
- **Status 201 (Created)**: Tạo mới thành công (POST)
- **Status 204 (No Content)**: Xóa thành công (DELETE)
- **Status 404 (Not Found)**: Không tìm thấy resource
- **Status 400 (Bad Request)**: Dữ liệu request không hợp lệ
- **Status 500 (Internal Server Error)**: Lỗi server

### Lưu ý khi test

1. **Kiểm tra ID thực tế**: Trước khi test GET/PUT/DELETE theo ID, hãy kiểm tra ID thực tế trong database:
   ```sql
   SELECT * FROM textbooks;
   ```

2. **Kiểm tra bookNumber unique**: Khi tạo mới, đảm bảo `bookNumber` chưa tồn tại (trường này là unique)

3. **Xem logs**: Kiểm tra console log để xem SQL queries và lỗi (nếu có)

4. **Test theo thứ tự**: 
   - Đầu tiên test GET để xem data đã có
   - Sau đó test POST để tạo mới
   - Tiếp theo test PUT để cập nhật
   - Cuối cùng test DELETE (cẩn thận, sẽ xóa data)

## Lưu ý

- Tất cả DTOs sử dụng Java Records
- Foreign keys được định nghĩa rõ ràng với @ManyToOne, @OneToMany
- ID sử dụng BIGINT AUTO_INCREMENT (tương đương BIGSERIAL)
- CORS đã được cấu hình để cho phép tất cả origins
- Security đã được disable tạm thời (cần thêm authentication sau)

