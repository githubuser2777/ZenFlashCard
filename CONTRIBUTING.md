# Contributing to ZenFlashCards

Cảm ơn bạn đã quan tâm đến ZenFlashCards! Dưới đây là hướng dẫn đóng góp cho dự án.

---

## 🚀 Bắt Đầu Nhanh

### Yêu Cầu Hệ Thống

| Công cụ        | Phiên bản tối thiểu |
|-----------------|---------------------|
| Flutter SDK     | 3.x                 |
| Dart SDK        | 3.x                 |
| Android SDK     | API 21+ (minSdk)    |
| Android Studio  | Latest stable        |

### Cài Đặt Môi Trường

```bash
# 1. Clone repository
git clone https://github.com/githubuser2777/ZenFlashCard.git
cd ZenFlashCard

# 2. Cài đặt dependencies
flutter pub get

# 3. Kiểm tra môi trường
flutter doctor

# 4. Chạy app trên emulator hoặc thiết bị
flutter run
```

---

## 📐 Quy Tắc Code

### Cấu Trúc Thư Mục

Dự án tuân theo **Clean Architecture + Feature-Driven Structure**:

```
lib/
├── core/         # Database, Models, Algorithms, Utils
├── features/     # Các tính năng (Home, Deck, Study, Stats, Settings)
└── shared/       # Widgets & Theme dùng chung
```

### Quy Ước Đặt Tên

- **Files**: `snake_case.dart` (VD: `deck_dao.dart`, `study_viewmodel.dart`)
- **Classes**: `PascalCase` (VD: `FlashCard`, `DeckViewModel`)
- **Variables/Functions**: `camelCase` (VD: `getCardsDueToday()`)
- **Constants**: `camelCase` với prefix `k` hoặc `const` (VD: `const kMinEasiness = 1.3`)

### Dart Best Practices

- Sử dụng `const` constructors khi có thể
- Dispose `AnimationController` và `StreamController` đúng cách (tránh memory leaks)
- Ưu tiên immutable data classes với `toMap()` / `fromMap()`

---

## 🧪 Testing

### Chạy Tests

```bash
# Unit tests cho SM-2 algorithm
flutter test test/core/algorithms/sm2_test.dart

# Toàn bộ test suite
flutter test

# Kiểm tra tĩnh
flutter analyze
```

### Viết Test Mới

- Đặt test files trong thư mục `test/` phản ánh cấu trúc `lib/`
- Mỗi test file kết thúc bằng `_test.dart`
- Sử dụng `group()` để nhóm các test case liên quan

---

## 🔀 Quy Trình Pull Request

1. **Fork** repository
2. Tạo **feature branch**: `git checkout -b feature/ten-tinh-nang`
3. **Commit** với message rõ ràng: `git commit -m "feat: thêm tính năng XYZ"`
4. **Push** lên fork: `git push origin feature/ten-tinh-nang`
5. Tạo **Pull Request** vào branch `main`

### Commit Message Convention

```
feat: thêm tính năng mới
fix: sửa lỗi
docs: cập nhật tài liệu
style: thay đổi format (không ảnh hưởng logic)
refactor: tái cấu trúc code
test: thêm hoặc sửa tests
chore: cập nhật build scripts, dependencies
```

---

## 🐛 Báo Lỗi

Khi báo lỗi, vui lòng cung cấp:

1. **Mô tả lỗi** rõ ràng
2. **Bước tái hiện** cụ thể
3. **Kết quả mong đợi** vs **Kết quả thực tế**
4. **Thông tin thiết bị**: Model, Android version, Flutter version
5. **Screenshots / Logs** nếu có

---

## 📜 License

Bằng việc đóng góp cho dự án, bạn đồng ý rằng code của bạn sẽ được phân phối theo [MIT License](LICENSE).
