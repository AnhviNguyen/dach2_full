# Script Test API Textbook - Hướng dẫn nhanh

## Bước 1: Khởi động Server

```bash
# Windows
gradlew.bat bootRun

# Linux/Mac
./gradlew bootRun
```

Đợi đến khi thấy: `Started BackendApplication`

## Bước 2: Test với Postman hoặc cURL

### ✅ Test 1: Lấy danh sách giáo trình (GET)

**Postman:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks`

**cURL:**
```bash
curl -X GET http://localhost:8080/api/textbooks
```

**Kết quả mong đợi:** Danh sách các giáo trình bạn đã tạo trong MySQL

---

### ✅ Test 2: Lấy giáo trình theo ID (GET)

**Postman:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/1`
  *(Thay `1` bằng ID thực tế trong database)*

**cURL:**
```bash
curl -X GET http://localhost:8080/api/textbooks/1
```

**Lưu ý:** Kiểm tra ID trong database trước:
```sql
SELECT id, book_number, title FROM textbooks;
```

---

### ✅ Test 3: Lấy giáo trình theo số quyển (GET)

**Postman:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/book-number/1`
  *(Thay `1` bằng bookNumber thực tế)*

**cURL:**
```bash
curl -X GET http://localhost:8080/api/textbooks/book-number/1
```

---

### ✅ Test 4: Tạo giáo trình mới (POST)

**Postman:**
- Method: `POST`
- URL: `http://localhost:8080/api/textbooks`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "bookNumber": 3,
  "title": "Tiếng Hàn Quyển 3",
  "subtitle": "Nâng cao",
  "totalLessons": 30,
  "color": "#3357FF"
}
```

**cURL (Windows PowerShell):**
```powershell
curl -X POST http://localhost:8080/api/textbooks `
  -H "Content-Type: application/json" `
  -d '{\"bookNumber\": 3, \"title\": \"Tiếng Hàn Quyển 3\", \"subtitle\": \"Nâng cao\", \"totalLessons\": 30, \"color\": \"#3357FF\"}'
```

**cURL (Linux/Mac):**
```bash
curl -X POST http://localhost:8080/api/textbooks \
  -H "Content-Type: application/json" \
  -d '{"bookNumber": 3, "title": "Tiếng Hàn Quyển 3", "subtitle": "Nâng cao", "totalLessons": 30, "color": "#3357FF"}'
```

---

### ✅ Test 5: Cập nhật giáo trình (PUT)

**Postman:**
- Method: `PUT`
- URL: `http://localhost:8080/api/textbooks/1`
  *(Thay `1` bằng ID cần cập nhật)*
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "bookNumber": 1,
  "title": "Tiếng Hàn Quyển 1 - Đã cập nhật",
  "subtitle": "Cơ bản",
  "totalLessons": 25,
  "color": "#FF5733"
}
```

**cURL:**
```bash
curl -X PUT http://localhost:8080/api/textbooks/1 \
  -H "Content-Type: application/json" \
  -d '{"bookNumber": 1, "title": "Tiếng Hàn Quyển 1 - Đã cập nhật", "subtitle": "Cơ bản", "totalLessons": 25, "color": "#FF5733"}'
```

---

### ✅ Test 6: Xóa giáo trình (DELETE)

**Postman:**
- Method: `DELETE`
- URL: `http://localhost:8080/api/textbooks/1`
  *(Thay `1` bằng ID cần xóa - CẨN THẬN: sẽ xóa vĩnh viễn)*

**cURL:**
```bash
curl -X DELETE http://localhost:8080/api/textbooks/1
```

**Kết quả mong đợi:** Status 204 (No Content)

---

### ✅ Test 7: Lấy tiến độ học (GET)

**Postman:**
- Method: `GET`
- URL: `http://localhost:8080/api/textbooks/1/progress/1`
  *(Thay `1` đầu tiên là textbookId, `1` thứ hai là userId)*

**cURL:**
```bash
curl -X GET http://localhost:8080/api/textbooks/1/progress/1
```

---

## Checklist Test

- [ ] Server đã khởi động thành công (port 8080)
- [ ] Database đã có data trong bảng `textbooks`
- [ ] Test GET danh sách - trả về data
- [ ] Test GET theo ID - trả về đúng giáo trình
- [ ] Test GET theo bookNumber - trả về đúng giáo trình
- [ ] Test POST - tạo mới thành công
- [ ] Test PUT - cập nhật thành công
- [ ] Test DELETE - xóa thành công (nếu cần)

## Troubleshooting

**Lỗi: Connection refused**
- Kiểm tra server đã chạy chưa
- Kiểm tra port 8080 có bị chiếm không

**Lỗi: 404 Not Found**
- Kiểm tra URL đúng chưa: `http://localhost:8080/api/textbooks`
- Kiểm tra ID có tồn tại trong database không

**Lỗi: 400 Bad Request**
- Kiểm tra JSON format đúng chưa
- Kiểm tra các trường bắt buộc (bookNumber, title)
- Kiểm tra bookNumber có bị trùng không (unique constraint)

**Lỗi: 500 Internal Server Error**
- Xem logs trong console để biết lỗi cụ thể
- Kiểm tra kết nối database
- Kiểm tra cấu hình trong `application.properties`

