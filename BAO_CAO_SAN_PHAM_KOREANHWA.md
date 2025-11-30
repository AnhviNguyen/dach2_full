# BÁO CÁO SẢN PHẨM - KOREANHWA

## 1. Tổng quan sản phẩm (Product Overview)

**Tên sản phẩm:** KoreanHwa (Korean Studio)

**Loại sản phẩm:** Mobile Application với AI Integration

**Khách hàng mục tiêu:** Người Việt Nam có nhu cầu học tiếng Hàn từ cơ bản đến nâng cao, đặc biệt là:
- Sinh viên đại học học tiếng Hàn
- Người đi làm muốn nâng cao kỹ năng tiếng Hàn
- Người có dự định thi TOPIK
- Người yêu thích văn hóa Hàn Quốc

**Người dùng cuối:** Người học tiếng Hàn ở mọi trình độ (Beginner, Intermediate, Advanced)

**Mô tả ngắn gọn:**

KoreanHwa là một ứng dụng học tiếng Hàn toàn diện, tích hợp công nghệ AI tiên tiến để hỗ trợ người học phát triển các kỹ năng ngôn ngữ một cách hiệu quả. Sản phẩm kết hợp phương pháp học truyền thống với công nghệ hiện đại, đặc biệt là AI đánh giá phát âm dựa trên mô hình Wav2Vec2 và Conformer, cùng với AI Coach (Ivy/Leo) để luyện giao tiếp thực tế. 

Ứng dụng được phát triển theo phương pháp Agile/Scrum, với kiến trúc microservices gồm:
- **Backend Spring Boot** (Java 17): Quản lý dữ liệu người dùng, khóa học, bài học, từ vựng, ngữ pháp, bài tập, bảng xếp hạng, thành tựu
- **AI Backend FastAPI** (Python): Xử lý phát âm, TTS, STT, chat với AI, đánh giá TOPIK
- **Frontend Flutter**: Giao diện mobile app đa nền tảng (Android/iOS)

Sản phẩm nhằm giải quyết các vấn đề chính:
- Thiếu môi trường thực hành phát âm với phản hồi tức thì
- Khó khăn trong việc tự đánh giá trình độ và tiến độ học tập
- Thiếu công cụ luyện giao tiếp thực tế với AI
- Không có hệ thống quản lý học tập toàn diện (từ vựng, ngữ pháp, bài tập, TOPIK)

---

## 2. Tầm nhìn sản phẩm (Product Vision)

> Đối với người Việt học tiếng Hàn, sản phẩm KoreanHwa giúp họ học tiếng Hàn một cách hiệu quả và toàn diện thông qua công nghệ AI tiên tiến, cung cấp phản hồi phát âm chính xác và môi trường luyện giao tiếp thực tế. Không giống như các ứng dụng học ngôn ngữ truyền thống chỉ tập trung vào từ vựng và ngữ pháp, sản phẩm của chúng tôi tích hợp AI đánh giá phát âm dựa trên mô hình deep learning (Wav2Vec2 + Conformer), AI Coach để luyện giao tiếp, và hệ thống quản lý học tập toàn diện với roadmap cá nhân hóa, giúp người học phát triển đầy đủ 4 kỹ năng: Nghe, Nói, Đọc, Viết.

**Tầm nhìn dài hạn:**
- Trở thành ứng dụng học tiếng Hàn hàng đầu tại Việt Nam với công nghệ AI tiên tiến
- Xây dựng cộng đồng người học tiếng Hàn lớn mạnh với tính năng blog và competition
- Mở rộng sang các ngôn ngữ khác (tiếng Nhật, tiếng Trung) với cùng công nghệ AI
- Tích hợp với các nền tảng giáo dục và doanh nghiệp

---

## 3. Giá trị cốt lõi (Core Values)

- **Đơn giản:** Giao diện thân thiện, dễ sử dụng, phù hợp với mọi lứa tuổi. Học tập mọi lúc mọi nơi trên mobile.

- **Hiệu quả:** 
  - AI đánh giá phát âm chính xác với độ chính xác ~75% (PER ~25%)
  - Phản hồi tức thì giúp người học cải thiện nhanh chóng
  - Roadmap cá nhân hóa theo trình độ và mục tiêu
  - Hệ thống điểm thưởng và thành tựu khuyến khích học tập

- **Minh bạch:** 
  - Dashboard thống kê tiến độ học tập rõ ràng
  - Bảng xếp hạng công khai
  - Theo dõi tiến độ từng kỹ năng (Nghe, Nói, Đọc, Viết)
  - Báo cáo chi tiết về phát âm và lỗi thường gặp

- **Hợp tác:** 
  - Tính năng blog để chia sẻ kinh nghiệm học tập
  - Competition để thi đua với cộng đồng
  - Hệ thống comment và like trên blog
  - Chia sẻ thành tựu và tiến độ

- **Công nghệ tiên tiến:**
  - AI Pronunciation Model dựa trên Wav2Vec2 + Conformer
  - AI Coach (GPT-4) cho luyện giao tiếp thực tế
  - TTS (Text-to-Speech) và STT (Speech-to-Speech) tích hợp
  - Kiến trúc microservices hiện đại, dễ mở rộng

---

## 4. Mục tiêu sản phẩm (Product Goals)

| # | Mục tiêu | Tiêu chí thành công | Thời gian dự kiến |
|---|-----------|----------------------|--------------------|
| 1 | Hoàn thiện bản MVP | Có thể demo và test chức năng chính: Đăng nhập, Học bài, Luyện phát âm, TOPIK | Sprint 3 |
| 2 | Đạt 90% user satisfaction | Qua khảo sát nội bộ nhóm và giảng viên | Sprint 4 |
| 3 | Tích hợp AI Pronunciation Model | Model đạt PER < 30%, có thể đánh giá phát âm real-time | Sprint 2 |
| 4 | Hoàn thiện AI Coach (Live Talk) | Có thể trò chuyện tự nhiên với AI, nhận phản hồi về phát âm | Sprint 3 |
| 5 | Tích hợp TOPIK Exam | Có đầy đủ đề thi TOPIK I và TOPIK II, chấm điểm tự động | Sprint 3 |
| 6 | Hoàn thiện Dashboard & Progress Tracking | Hiển thị thống kê tiến độ đầy đủ, roadmap cá nhân hóa | Sprint 4 |
| 7 | Tích hợp Blog & Competition | Người dùng có thể đăng blog, tham gia competition | Sprint 4 |
| 8 | Tối ưu hiệu năng | App load < 3s, API response < 500ms | Sprint 4 |

---

## 5. Personas (Người dùng điển hình)

### Persona 1 – Sinh viên A (Nguyễn Văn A)

- **Tuổi:** 20
- **Nghề nghiệp:** Sinh viên năm 2, chuyên ngành Ngôn ngữ Hàn
- **Mục tiêu:** 
  - Học tiếng Hàn để thi TOPIK I đạt level 3-4
  - Cải thiện kỹ năng phát âm và giao tiếp
  - Quản lý từ vựng và ngữ pháp hiệu quả
- **Nhu cầu:** 
  - Giao diện thân thiện, dễ sử dụng
  - Nhắc nhở deadline và lịch học
  - Phản hồi phát âm tức thì và chính xác
  - Luyện giao tiếp với AI mọi lúc mọi nơi
  - Theo dõi tiến độ học tập rõ ràng
- **Nỗi đau:** 
  - Khó tự đánh giá phát âm
  - Thiếu môi trường thực hành giao tiếp
  - Khó quản lý lượng từ vựng lớn
  - Không biết trình độ hiện tại của mình

### Persona 2 – Người đi làm B (Trần Thị B)

- **Tuổi:** 28
- **Nghề nghiệp:** Nhân viên văn phòng, có dự định làm việc tại Hàn Quốc
- **Mục tiêu:** 
  - Học tiếng Hàn để thi TOPIK II đạt level 5-6
  - Cải thiện kỹ năng giao tiếp trong công việc
  - Học từ vựng chuyên ngành
- **Nhu cầu:** 
  - Học tập linh hoạt, mọi lúc mọi nơi
  - Nội dung học phù hợp với công việc
  - Luyện giao tiếp với AI về các chủ đề công việc
  - Báo cáo tiến độ chi tiết
- **Nỗi đau:** 
  - Không có thời gian đến lớp học
  - Thiếu môi trường thực hành
  - Khó đánh giá trình độ hiện tại

### Persona 3 – Giảng viên C (Lê Văn C)

- **Tuổi:** 35
- **Nghề nghiệp:** Giảng viên tiếng Hàn tại trường đại học
- **Mục tiêu:** 
  - Theo dõi tiến độ học tập của sinh viên
  - Sử dụng ứng dụng như công cụ hỗ trợ giảng dạy
  - Đánh giá hiệu quả của phương pháp học với AI
- **Nhu cầu:** 
  - Dashboard tổng hợp tiến độ sinh viên
  - Báo cáo chi tiết về phát âm và lỗi thường gặp
  - Công cụ tạo bài học và bài tập
  - Phân tích dữ liệu học tập
- **Nỗi đau:** 
  - Khó theo dõi tiến độ từng sinh viên
  - Thiếu công cụ đánh giá phát âm tự động
  - Không có dữ liệu thống kê về hiệu quả học tập

---

## 6. Cấu trúc chức năng chính (Feature Map)

| Mức | Chức năng | Mô tả |
|------|-------------|------|
| **Epic** | **Quản lý người dùng** | Đăng ký, đăng nhập, quản lý profile, xác thực OAuth (Google) |
| Story | Đăng ký/Đăng nhập | Đăng ký tài khoản mới, đăng nhập với email/password hoặc Google |
| Story | Quản lý Profile | Cập nhật thông tin cá nhân, avatar, mục tiêu học tập |
| Story | Onboarding | Hướng dẫn sử dụng app cho người dùng mới, khảo sát trình độ |
| **Epic** | **Học tập cơ bản** | Học từ vựng, ngữ pháp, bài tập theo giáo trình và khóa học |
| Story | Quản lý Giáo trình (Textbook) | Xem danh sách giáo trình, tiến độ học từng quyển, mở khóa bài học |
| Story | Quản lý Khóa học (Course) | Đăng ký khóa học, xem danh sách bài học, theo dõi tiến độ |
| Story | Học Bài (Lesson) | Xem nội dung bài học: từ vựng, ngữ pháp, ví dụ, bài tập |
| Story | Làm Bài tập (Exercise) | Làm bài tập trắc nghiệm, tự luận, kiểm tra kết quả |
| Story | Quản lý Từ vựng | Xem từ vựng theo bài học, tạo folder từ vựng cá nhân, ôn tập |
| **Epic** | **Luyện phát âm với AI** | Đánh giá phát âm tiếng Hàn sử dụng mô hình Wav2Vec2 + Conformer |
| Story | Read Aloud | Đọc theo văn bản, nhận phản hồi phát âm chi tiết (phoneme-level) |
| Story | Free Speak | Nói tự do, AI chuyển đổi sang text và đánh giá phát âm |
| Story | Pronunciation Feedback | Hiển thị điểm số, lỗi phát âm, gợi ý cải thiện |
| Story | Pronunciation History | Lưu lịch sử luyện phát âm, theo dõi tiến độ |
| **Epic** | **AI Coach - Live Talk** | Trò chuyện với AI Coach (Ivy/Leo) để luyện giao tiếp |
| Story | Chọn Coach | Chọn giữa Coach Ivy (ấm áp) hoặc Coach Leo (năng động) |
| Story | Trò chuyện Voice | Trò chuyện bằng giọng nói với AI, nhận phản hồi về phát âm |
| Story | Chọn Chủ đề | Chọn chủ đề trò chuyện: daily_life, travel, work, hobbies |
| Story | Mission-based Practice | Luyện tập theo mission cụ thể với mục tiêu rõ ràng |
| Story | Session Summary | Tổng kết buổi trò chuyện, điểm mạnh/yếu, gợi ý cải thiện |
| **Epic** | **TOPIK Exam** | Luyện thi và làm đề thi TOPIK I, TOPIK II |
| Story | TOPIK Library | Xem danh sách đề thi TOPIK, chọn đề thi theo level |
| Story | Làm Đề thi | Làm đề thi TOPIK với timer, tự động chấm điểm |
| Story | Xem Kết quả | Xem điểm số, đáp án đúng/sai, giải thích chi tiết |
| Story | Lịch sử Thi | Xem lịch sử các lần thi, theo dõi tiến độ |
| **Epic** | **Roadmap & Progress** | Roadmap học tập cá nhân hóa và theo dõi tiến độ |
| Story | Roadmap Cá nhân | Xem roadmap học tập được đề xuất dựa trên trình độ |
| Story | Skill Progress | Theo dõi tiến độ từng kỹ năng: Nghe, Nói, Đọc, Viết |
| Story | Dashboard Stats | Xem thống kê tổng quan: số bài đã học, điểm số, streak |
| Story | Achievement System | Xem thành tựu đã đạt được, mục tiêu tiếp theo |
| **Epic** | **Cộng đồng** | Blog, Competition, Ranking để tương tác với cộng đồng |
| Story | Blog | Đăng bài viết, xem bài viết của người khác, like, comment |
| Story | Competition | Tham gia cuộc thi, xem kết quả, nhận giải thưởng |
| Story | Ranking | Xem bảng xếp hạng, vị trí của mình trong cộng đồng |
| **Epic** | **Tài liệu học tập** | Tải và quản lý tài liệu học tập (PDF, Audio, Video) |
| Story | Material Library | Xem danh sách tài liệu, tải về, quản lý tài liệu đã tải |
| Story | Material Download | Tải tài liệu bằng điểm, xem tài liệu đã tải |
| **Epic** | **Cài đặt & Tùy chỉnh** | Cài đặt app, theme, thông báo, ngôn ngữ |
| Story | Settings | Cài đặt theme (light/dark), thông báo, ngôn ngữ |
| Story | Profile Settings | Cài đặt thông tin cá nhân, mục tiêu học tập |

---

## 7. Lộ trình phát triển (Product Roadmap)

### Giai đoạn 1 – Khởi tạo (Sprint 1)

**Mục tiêu:** Thiết lập dự án, thiết kế kiến trúc, tạo Product Backlog

**Công việc:**
- Hoàn thiện Product Charter, Product Backlog
- Thiết kế kiến trúc hệ thống (Backend Spring Boot + AI Backend FastAPI + Frontend Flutter)
- Thiết lập database schema (MySQL)
- Thiết kế giao diện sơ bộ bằng Figma
- Thiết lập CI/CD pipeline
- Thiết lập Jira Project (nếu có)

**Deliverables:**
- Product Charter
- Product Backlog
- Database Schema
- UI/UX Design (Figma)
- Project Setup

### Giai đoạn 2 – Phát triển cốt lõi (Sprint 2–3)

**Mục tiêu:** Xây dựng các chức năng cốt lõi của ứng dụng

**Sprint 2:**
- Backend: API quản lý User, Course, Textbook, Lesson, Vocabulary
- AI Backend: Tích hợp AI Pronunciation Model (Wav2Vec2 + Conformer)
- Frontend: Màn hình Đăng nhập, Home, Course, Lesson
- Frontend: Màn hình Luyện phát âm cơ bản (Read Aloud)

**Sprint 3:**
- Backend: API quản lý Exercise, Progress, Achievement, Ranking
- AI Backend: Tích hợp AI Coach (Live Talk), TTS, STT
- Frontend: Màn hình TOPIK Exam, Live Talk, Dashboard
- Frontend: Màn hình Blog, Competition (cơ bản)
- Kiểm thử nội bộ và demo MVP

**Deliverables:**
- MVP với các chức năng chính
- AI Pronunciation Model hoạt động
- AI Coach (Live Talk) hoạt động
- TOPIK Exam cơ bản

### Giai đoạn 3 – Hoàn thiện & Tối ưu (Sprint 4)

**Mục tiêu:** Cải thiện UX/UI, thêm tính năng nâng cao, tối ưu hiệu năng

**Công việc:**
- Cải tiến UX/UI dựa trên feedback
- Thêm biểu đồ thống kê chi tiết (Dashboard)
- Hoàn thiện Blog & Competition (comment, like, share)
- Tối ưu hiệu năng: caching, lazy loading, image optimization
- Cải thiện AI Pronunciation Model (nếu cần)
- Thêm tính năng Material Download
- Hoàn thiện Roadmap cá nhân hóa

**Deliverables:**
- App hoàn thiện với UX/UI tốt
- Dashboard với thống kê đầy đủ
- Blog & Competition hoàn chỉnh
- Performance optimization

### Giai đoạn 4 – Trình bày cuối kỳ

**Mục tiêu:** Chuẩn bị báo cáo và trình bày sản phẩm

**Công việc:**
- Chuẩn bị báo cáo Sprint Review và Retrospective
- Tạo video demo sản phẩm
- Chuẩn bị slide trình bày
- Test toàn bộ tính năng
- Fix các bug còn lại
- Deploy lên production (nếu có)

**Deliverables:**
- Báo cáo đầy đủ
- Video demo
- Slide trình bày
- Sản phẩm hoàn chỉnh

---

## 8. Chỉ số thành công (Key Metrics)

| Chỉ số | Mô tả | Mục tiêu |
|---------|-------|-----------|
| **Sprint Velocity** | Story Point hoàn thành mỗi Sprint | ≥ 90% so với cam kết |
| **User Feedback** | Điểm hài lòng từ người dùng thử | ≥ 4/5 |
| **AI Pronunciation Accuracy** | Độ chính xác của mô hình phát âm (PER) | ≤ 30% (70% accuracy) |
| **API Response Time** | Thời gian phản hồi API | ≤ 500ms (p95) |
| **App Load Time** | Thời gian load app lần đầu | ≤ 3s |
| **Task Completion Rate** | % task hoàn thành đúng hạn | ≥ 85% |
| **Code Coverage** | Độ bao phủ code test | ≥ 70% |
| **Bug Rate** | Số bug phát hiện sau release | ≤ 5 bugs/sprint |
| **User Retention** | Tỷ lệ người dùng quay lại sau 7 ngày | ≥ 60% |
| **Daily Active Users (DAU)** | Số người dùng hoạt động mỗi ngày | Tăng 20% mỗi tháng |

---

## 9. Rủi ro sản phẩm & Giải pháp

| Rủi ro | Tác động | Biện pháp |
|--------|-----------|-----------|
| **Thiếu kinh nghiệm về AI Model** | Cao | Tìm tài liệu, tham khảo code mẫu, học từ các dự án open source, thử nghiệm với dataset nhỏ trước |
| **AI Model hiệu năng không đủ** | Cao | Tối ưu model (quantization, pruning), sử dụng GPU nếu có, cache kết quả, fallback về word-level accuracy |
| **Quá tải công việc học kỳ** | Cao | Lập kế hoạch chi tiết, Daily Meeting để sync tiến độ, ưu tiên tính năng core, chia nhỏ task |
| **Thiếu người phụ trách UI/UX** | Trung bình | Sử dụng design system có sẵn (Material Design), tham khảo các app tương tự, test với người dùng thật |
| **Vấn đề tích hợp Backend và AI Backend** | Trung bình | Thiết kế API rõ ràng từ đầu, sử dụng RESTful API, có documentation đầy đủ, test integration sớm |
| **Database performance** | Trung bình | Tối ưu query, sử dụng indexing, caching với Redis (nếu cần), phân trang cho danh sách lớn |
| **Vấn đề deploy và hosting** | Thấp | Sử dụng cloud service (AWS, GCP, Azure), Docker containerization, CI/CD pipeline |
| **Thiếu dữ liệu training cho AI** | Trung bình | Sử dụng dataset công khai (KSS), data augmentation, transfer learning từ pretrained model |
| **Vấn đề bảo mật** | Trung bình | Sử dụng JWT cho authentication, HTTPS, validate input, SQL injection prevention |
| **Thiếu người test** | Thấp | Test nội bộ nhóm, mời bạn bè test, sử dụng beta testing |

---

## 10. Tài nguyên & công cụ sử dụng

### Development Tools

- **IDE:**
  - IntelliJ IDEA / Android Studio - Phát triển Backend Spring Boot và Flutter
  - VS Code - Phát triển AI Backend (Python)
  - PyCharm - Phát triển và train AI Model

- **Version Control:**
  - Git - Quản lý mã nguồn
  - GitHub / GitLab - Lưu trữ repository

- **Project Management:**
  - Jira Software Cloud - Quản lý backlog, sprint, task tracking
  - Notion - Ghi chép ý tưởng, meeting notes, documentation
  - Google Drive - Lưu trữ báo cáo và tài liệu

### Design Tools

- **UI/UX Design:**
  - Figma - Thiết kế giao diện và prototype
  - Canva - Tạo hình ảnh, icon, banner

### Backend Development

- **Backend Spring Boot:**
  - Java 17
  - Spring Boot 4.0.0
  - Spring Data JPA
  - Spring Security
  - MySQL 8.0+
  - Gradle - Build tool

- **AI Backend FastAPI:**
  - Python 3.10+
  - FastAPI
  - PyTorch - Deep learning framework
  - Transformers (Hugging Face) - Wav2Vec2 model
  - OpenAI API - GPT-4 cho AI Coach
  - Whisper - Speech-to-Text
  - TTS (Text-to-Speech) libraries

### Frontend Development

- **Flutter:**
  - Flutter SDK 3.5.0+
  - Dart 3.5.0+
  - Riverpod - State management
  - GoRouter - Navigation
  - Dio - HTTP client
  - Hive / SharedPreferences - Local storage
  - Flutter Secure Storage - Secure storage
  - Google Sign In - OAuth authentication
  - Fl Chart - Charts và graphs
  - Record - Audio recording
  - AudioPlayers - Audio playback

### Database & Storage

- **Database:**
  - MySQL 8.0+ - Main database
  - Hive (Flutter) - Local database cho mobile

- **Storage:**
  - Local file system - Lưu trữ audio files, model files
  - Cloud storage (nếu cần) - AWS S3, Google Cloud Storage

### AI & Machine Learning

- **AI Models:**
  - Wav2Vec2 (facebook/wav2vec2-base) - Feature extraction
  - Conformer - Phoneme recognition
  - GPT-4 (OpenAI) - AI Coach conversation
  - Whisper - Speech-to-Text

- **ML Tools:**
  - PyTorch - Training và inference
  - Transformers - Pretrained models
  - NumPy, Pandas - Data processing
  - Jupyter Notebook - Experiment và analysis

### Testing & Quality Assurance

- **Testing:**
  - JUnit - Unit testing cho Backend
  - Flutter Test - Unit testing cho Flutter
  - Postman - API testing
  - cURL - Command line API testing

### Deployment & DevOps

- **Containerization:**
  - Docker - Containerization
  - Docker Compose - Multi-container orchestration

- **CI/CD:**
  - GitHub Actions / GitLab CI - Continuous Integration
  - Automated testing và deployment

- **Hosting (nếu deploy):**
  - AWS / GCP / Azure - Cloud hosting
  - Heroku - PaaS (nếu cần)
  - VPS - Virtual private server

### Documentation

- **Documentation:**
  - Markdown - Viết documentation
  - Swagger / OpenAPI - API documentation
  - Javadoc - Java documentation
  - Dartdoc - Dart documentation

### Communication & Collaboration

- **Communication:**
  - Slack / Discord - Team communication
  - Zoom / Google Meet - Video meetings
  - Email - Formal communication

---

## 11. Kiến trúc hệ thống (System Architecture)

### 11.1. Tổng quan kiến trúc

Hệ thống KoreanHwa sử dụng kiến trúc **microservices** với 3 thành phần chính:

```
┌─────────────────┐
│  Flutter App    │  (Frontend - Mobile)
│  (Android/iOS)  │
└────────┬────────┘
         │
         │ HTTP/REST API
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼──────┐
│Spring │ │ FastAPI │
│ Boot  │ │  (AI)   │
│Backend│ │         │
└───┬───┘ └──┬──────┘
    │        │
    │        │
┌───▼───┐    │
│ MySQL │    │ (AI Models)
│Database│   │ (Wav2Vec2, GPT-4)
└───────┘    │
```

### 11.2. Backend Spring Boot

**Chức năng:**
- Quản lý User, Authentication, Authorization
- Quản lý Course, Textbook, Lesson, Vocabulary, Grammar, Exercise
- Quản lý Progress, Achievement, Ranking
- Quản lý Blog, Competition
- Quản lý Material Download

**Công nghệ:**
- Java 17, Spring Boot 4.0.0
- Spring Data JPA, MySQL
- Spring Security (JWT)
- RESTful API

### 11.3. AI Backend FastAPI

**Chức năng:**
- AI Pronunciation Evaluation (Wav2Vec2 + Conformer)
- AI Coach - Live Talk (GPT-4)
- TTS (Text-to-Speech)
- STT (Speech-to-Text) - Whisper
- Dictionary Service
- TOPIK Service

**Công nghệ:**
- Python 3.10+, FastAPI
- PyTorch, Transformers
- OpenAI API (GPT-4)
- Whisper (STT)

### 11.4. Frontend Flutter

**Chức năng:**
- Giao diện người dùng
- State management (Riverpod)
- Navigation (GoRouter)
- Local storage (Hive, SharedPreferences)
- Audio recording và playback
- Charts và graphs

**Công nghệ:**
- Flutter 3.5.0+, Dart 3.5.0+
- Riverpod, GoRouter, Dio
- Various Flutter packages

---

## 12. Kết luận

KoreanHwa là một sản phẩm học tiếng Hàn toàn diện, tích hợp công nghệ AI tiên tiến để cung cấp trải nghiệm học tập hiệu quả và thú vị. Với kiến trúc microservices hiện đại, sản phẩm có thể mở rộng và phát triển lâu dài. 

Các điểm mạnh chính:
- **Công nghệ AI tiên tiến:** Mô hình phát âm dựa trên Wav2Vec2 + Conformer, AI Coach với GPT-4
- **Kiến trúc hiện đại:** Microservices, dễ mở rộng và bảo trì
- **Trải nghiệm người dùng tốt:** Giao diện thân thiện, phản hồi tức thì
- **Tính năng toàn diện:** Từ học cơ bản đến luyện thi TOPIK, từ luyện phát âm đến giao tiếp với AI

Với lộ trình phát triển rõ ràng và các mục tiêu cụ thể, sản phẩm sẽ được hoàn thiện qua các Sprint theo phương pháp Agile/Scrum, đảm bảo chất lượng và đáp ứng nhu cầu người dùng.

---

**Ngày tạo báo cáo:** [Ngày hiện tại]  
**Phiên bản:** 1.0  
**Tác giả:** Nhóm phát triển KoreanHwa


