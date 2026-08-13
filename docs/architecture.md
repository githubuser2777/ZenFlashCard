# 🏗️ Tài Liệu Kiến Trúc Hệ Thống — ZenFlashCards

> Tài liệu kỹ thuật mô tả chi tiết kiến trúc phần mềm, các quyết định thiết kế và luồng dữ liệu của ứng dụng ZenFlashCards.

---

## 1. Tổng Quan Kiến Trúc

ZenFlashCards áp dụng mô hình **Clean Architecture** kết hợp **Feature-Driven Structure**, chia thành 3 lớp chính:

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        direction LR
        Screens["Screens<br/>(7 màn hình)"]
        Widgets["Shared Widgets<br/>(FlipCard3D, ProgressBar)"]
        Theme["Theme System<br/>(AppColors, AppTheme)"]
    end

    subgraph Domain["Domain / Business Logic Layer"]
        direction LR
        ViewModels["ViewModels<br/>(ChangeNotifier)"]
        SM2["SM-2 Algorithm<br/>Engine"]
        CSVParser["CSV Parser<br/>(SAF Fallback)"]
    end

    subgraph Data["Data Layer"]
        direction LR
        DAOs["Data Access Objects<br/>(4 DAOs)"]
        DBHelper["Database Helper<br/>(SQLite init + migrations)"]
        Prefs["SharedPreferences<br/>(Theme settings)"]
    end

    subgraph Storage["Storage"]
        SQLite[(SQLite Database<br/>4 tables, 6 indexes)]
        SPDisk[(SharedPreferences<br/>key-value disk)]
    end

    Screens --> ViewModels
    Widgets --> ViewModels
    ViewModels --> SM2
    ViewModels --> CSVParser
    ViewModels --> DAOs
    ViewModels --> Prefs
    DAOs --> DBHelper
    DBHelper --> SQLite
    Prefs --> SPDisk
```

### Nguyên Tắc Thiết Kế

| Nguyên tắc | Áp dụng |
|------------|---------|
| **Separation of Concerns** | UI không chứa logic nghiệp vụ; ViewModel không biết về widget |
| **Dependency Injection** | MultiProvider ở root, inject ViewModel vào Screens |
| **Single Source of Truth** | SQLite là nguồn dữ liệu duy nhất; UI chỉ phản ánh state |
| **Offline-First** | 100% dữ liệu lưu local, không phụ thuộc network |
| **Feature Cohesion** | Mỗi feature (home, deck, study...) tự chứa screen + viewmodel |

---

## 2. Luồng Dữ Liệu Chi Tiết

### 2.1. Luồng Study Session (Buổi Học Flashcard)

```mermaid
sequenceDiagram
    participant U as User
    participant S as StudyScreen
    participant VM as StudyViewModel
    participant SM as SM-2 Engine
    participant CD as CardDAO
    participant RH as ReviewHistoryDAO
    participant SL as StudyLogDAO

    U->>S: Bấm "Học ngay"
    S->>VM: loadDueCards(deckId)
    VM->>CD: getCardsDueToday(deckId)
    CD-->>VM: List<Flashcard>
    VM-->>S: Hiện card đầu tiên

    U->>S: Tap card (lật)
    S->>S: Animation flip 3D (400ms)
    S->>S: Enable 3 nút đánh giá

    U->>S: Bấm "😎 Dễ" (quality=5)
    S->>VM: submitReview(card, quality=5)
    VM->>SM: calculateNextReview(rep, EF, interval, 5)
    SM-->>VM: SM2Result (new interval, EF, next_review)
    VM->>CD: updateSM2(cardId, SM2Result)
    VM->>RH: insert(cardId, deckId, quality=5)
    VM->>VM: sessionStudied++, sessionCorrect++

    Note over VM: Lặp lại cho từng card...

    VM->>VM: Queue hết card
    VM->>SL: insert(StudyLog: studied, correct, timestamp)
    VM-->>S: Navigate → ResultScreen
```

### 2.2. Luồng Import CSV

```mermaid
sequenceDiagram
    participant U as User
    participant D as DeckDetailScreen
    participant VM as CardViewModel
    participant FP as FilePicker (SAF)
    participant CSV as CSV Parser
    participant CD as CardDAO

    U->>D: Bấm "Import CSV"
    D->>FP: pickFiles(withData: true)
    FP-->>D: PlatformFile

    D->>VM: importCsv(deckId, file)
    VM->>CSV: readCsvContent(file)

    alt file.path != null
        CSV->>CSV: File(path).readAsString()
    else file.bytes != null (Android 13+ SAF)
        CSV->>CSV: utf8.decode(bytes)
    else both null
        CSV-->>VM: throw Exception
    end

    CSV-->>VM: parsed rows
    VM->>CD: getAllCards(deckId)
    CD-->>VM: existing cards

    loop Mỗi row
        alt Trùng front+back
            VM->>VM: skipped++
        else Không trùng
            VM->>CD: insertCard(deckId, front, back)
            VM->>VM: imported++
        end
    end

    VM-->>D: ImportResult(imported, skipped)
    D->>D: Snackbar "Đã import X, bỏ qua Y trùng"
```

---

## 3. State Management

### Provider Architecture

```mermaid
graph TD
    MA[MaterialApp] --> MP[MultiProvider]
    MP --> DVM[DeckViewModel<br/>ChangeNotifier]
    MP --> CVM[CardViewModel<br/>ChangeNotifier]
    MP --> SVM[StudyViewModel<br/>ChangeNotifier]
    MP --> StVM[StatsViewModel<br/>ChangeNotifier]
    MP --> SeVM[SettingsViewModel<br/>ChangeNotifier]

    DVM --> DD[DeckDAO]
    DVM --> CD[CardDAO]
    CVM --> CD
    SVM --> CD
    SVM --> RHDA[ReviewHistoryDAO]
    SVM --> SLDA[StudyLogDAO]
    SVM --> SM2[SM-2 Engine]
    StVM --> SLDA
    StVM --> RHDA
    SeVM --> SP[SharedPreferences]
```

### ViewModel Responsibilities

| ViewModel | Trách nhiệm |
|-----------|-------------|
| `DeckViewModel` | CRUD deck, tính card count động, query cards due today |
| `CardViewModel` | CRUD card, check duplicate mềm, import CSV + dedup |
| `StudyViewModel` | Queue management, SM-2 calculation, review logging, session finalization |
| `StatsViewModel` | Streak calculation, bar chart data (7 ngày), pie chart data (quality breakdown) |
| `SettingsViewModel` | ThemeMode persist/restore qua SharedPreferences |

---

## 4. Quyết Định Kiến Trúc (ADRs)

### ADR-001: Bỏ `card_count` denormalized trong bảng `decks`

- **Quyết định**: Tính `COUNT(*)` động từ bảng `flashcards` thay vì lưu cột `card_count`
- **Lý do**: Tránh dữ liệu lệch (data inconsistency) khi import/delete card
- **Trade-off**: Thêm 1 query nhưng SQLite với index trên `deck_id` rất nhanh (< 1ms)

### ADR-002: Tách `study_logs` và `review_history`

- **Quyết định**: `study_logs` = 1 row/buổi (aggregate), `review_history` = 1 row/lần lật (granular)
- **Lý do**: Bar chart và streak chỉ cần aggregate; Pie chart cần granular quality data
- **Trade-off**: Nhiều row hơn trong `review_history` nhưng SQLite offline xử lý thoải mái

### ADR-003: SAF (Storage Access Framework) cho file picker

- **Quyết định**: Dùng `Intent.ACTION_OPEN_DOCUMENT` qua `file_picker`, không khai báo storage permission
- **Lý do**: Android 13+ scoped storage không cho phép truy cập trực tiếp filesystem; khai báo thừa bị Play Store reject
- **Fallback**: Luôn request `withData: true` để có `PlatformFile.bytes` khi `path == null`

### ADR-004: Provider thay vì Riverpod/Bloc

- **Quyết định**: Dùng Provider (ChangeNotifier) cho state management
- **Lý do**: Đơn giản, ít boilerplate, phù hợp với scope ứng dụng offline nhỏ-vừa
- **Khi nào nâng cấp**: Nếu cần reactive streams hoặc multi-platform sync (v2)

---

## 5. Security & Performance

### Bảo Mật

- **Không lưu dữ liệu nhạy cảm**: App chỉ lưu từ vựng, không có thông tin cá nhân
- **Không cần permission**: Không khai báo storage/camera/location permission
- **SQLite local**: Dữ liệu không rời khỏi thiết bị

### Hiệu Năng

- **Index optimization**: 6 indexes trên các cột query thường xuyên
- **Animation**: 3D flip card chạy trên GPU qua `Transform` matrix, mượt 60fps
- **Memory**: `AnimationController` được dispose đúng lifecycle, không leak
- **Lazy loading**: Cards chỉ load khi user vào deck, không load tất cả upfront
