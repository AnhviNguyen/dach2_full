# Refactor Pattern Guide

## Cấu trúc Feature-Based Architecture

Mỗi feature được tổ chức theo cấu trúc sau:

```
lib/features/[feature_name]/
├── data/
│   ├── models/          # Data classes (mỗi class một file)
│   └── [feature]_mock_data.dart  # Mock data
├── presentation/
│   ├── screens/         # Screen chính
│   └── widgets/         # Widgets con (mỗi widget một file)
```

## Quy tắc Refactor

### 1. Tách Data Models
- Mỗi data class thành file riêng trong `data/models/`
- Đặt tên file theo snake_case: `task_item.dart`, `ranking_entry.dart`
- Class name theo PascalCase: `TaskItem`, `RankingEntry`
- Loại bỏ prefix `_` (private) vì đã tách ra file riêng

### 2. Tách Widgets
- Mỗi widget thành file riêng trong `presentation/widgets/`
- Đặt tên file theo snake_case: `daily_task_tile.dart`, `section_header.dart`
- Widget name theo PascalCase: `DailyTaskTile`, `SectionHeader`
- Loại bỏ prefix `_` (private)

### 3. Mock Data
- Tạo file `[feature]_mock_data.dart` trong `data/`
- Chứa tất cả mock data constants
- Export các models cần thiết

### 4. Screen chính
- Giữ trong `presentation/screens/`
- Import các models, widgets, và mock data
- Code ngắn gọn, dễ đọc

### 5. Imports
- Mỗi file PHẢI có đầy đủ imports
- Sử dụng relative imports cho cùng feature
- Absolute imports cho shared code

## Ví dụ: Home Feature

### Models
- `lib/features/home/data/models/task_item.dart`
- `lib/features/home/data/models/stat_chip_data.dart`
- `lib/features/home/data/models/lesson_card_data.dart`
- ... (mỗi model một file)

### Widgets
- `lib/features/home/presentation/widgets/daily_task_tile.dart`
- `lib/features/home/presentation/widgets/section_header.dart`
- `lib/features/home/presentation/widgets/today_mission_card.dart`
- ... (mỗi widget một file)

### Mock Data
- `lib/features/home/data/home_mock_data.dart`

### Screen
- `lib/features/home/presentation/screens/home_screen.dart`

## Checklist cho mỗi Feature

- [ ] Tạo thư mục `lib/features/[feature_name]/`
- [ ] Tách tất cả data classes vào `data/models/`
- [ ] Tách tất cả widgets vào `presentation/widgets/`
- [ ] Tạo file mock data trong `data/`
- [ ] Refactor screen chính trong `presentation/screens/`
- [ ] Cập nhật imports trong tất cả files
- [ ] Kiểm tra linter errors
- [ ] Test navigation và functionality

## Lưu ý

1. **Giữ nguyên logic**: Chỉ refactor cấu trúc, không thay đổi logic
2. **Update imports**: Đảm bảo tất cả imports đúng sau khi refactor
3. **Router updates**: Cập nhật router nếu cần thay đổi đường dẫn
4. **Shared code**: Giữ nguyên shared widgets trong `lib/shared/`

## Features cần refactor

1. ✅ home
2. ✅ achievements
3. ✅ ranking
4. ⏳ auth (login, register)
5. ⏳ textbook
6. ⏳ learning_curriculum
7. ⏳ blog
8. ⏳ competition
9. ⏳ courses
10. ⏳ material
11. ⏳ my_vocabulary
12. ⏳ roadmap
13. ⏳ settings
14. ⏳ speak_practice
15. ⏳ topik
16. ⏳ vocabulary

