# 📚 API Reference — ZenFlashCards

> Tài liệu tham chiếu chi tiết cho các DAOs, ViewModels, SM-2 Engine và Utility classes.

---

## 1. SM-2 Algorithm Engine

### File: `lib/core/algorithms/sm2.dart`

#### `SM2Result` Class

Đối tượng kết quả trả về sau khi tính toán SM-2.

| Property | Type | Mô tả |
|----------|------|-------|
| `repetition` | `int` | Số lần ôn đúng liên tục (reset về 0 khi quality < 3) |
| `easiness` | `double` | Hệ số dễ (EF), min = 1.3, default = 2.5 |
| `intervalDays` | `int` | Số ngày đến lần ôn tiếp theo |
| `nextReviewMs` | `int` | Unix timestamp (ms) của lần ôn tiếp theo |

#### `calculateNextReview()`

```dart
SM2Result calculateNextReview({
  required int repetition,    // Lần ôn đúng hiện tại
  required double easiness,   // EF hiện tại (>= 1.3)
  required int intervalDays,  // Interval hiện tại (ngày)
  required int quality,       // 0=Khó, 3=OK, 5=Dễ
})
```

**Logic:**

| Điều kiện | Kết quả |
|-----------|---------|
| `quality < 3` | `repetition = 0`, `interval = 1` |
| `quality >= 3`, rep 0→1 | `interval = 1` |
| `quality >= 3`, rep 1→2 | `interval = 6` |
| `quality >= 3`, rep > 2 | `interval = round(interval × EF)` |

**Công thức EF mới:**
```
EF' = EF + (0.1 - (5 - q) × (0.08 + (5 - q) × 0.02))
EF' = max(EF', 1.3)
```

---

## 2. Data Models

### `Deck`

**File:** `lib/core/models/deck.dart`

| Field | Type | SQLite Column | Mô tả |
|-------|------|:-------------:|-------|
| `id` | `String` | `id TEXT PK` | UUID v4 |
| `name` | `String` | `name TEXT NOT NULL` | Tên bộ thẻ |
| `description` | `String?` | `description TEXT` | Mô tả (optional) |
| `languageFront` | `String` | `language_front TEXT` | Ngôn ngữ mặt trước |
| `languageBack` | `String` | `language_back TEXT` | Ngôn ngữ mặt sau |
| `createdAt` | `int` | `created_at INTEGER` | Unix ms |

**Methods:** `toMap()`, `Deck.fromMap(Map<String, dynamic>)`

### `Flashcard`

**File:** `lib/core/models/flashcard.dart`

| Field | Type | Default | Mô tả |
|-------|------|:-------:|-------|
| `id` | `String` | — | UUID v4 |
| `deckId` | `String` | — | FK → decks.id |
| `front` | `String` | — | Nội dung mặt trước |
| `back` | `String` | — | Nội dung mặt sau |
| `repetition` | `int` | `0` | SM-2: lần ôn đúng |
| `easiness` | `double` | `2.5` | SM-2: hệ số dễ |
| `interval` | `int` | `1` | SM-2: interval (ngày) |
| `nextReview` | `int` | `now()` | Unix ms, lần ôn tiếp theo |
| `createdAt` | `int` | — | Unix ms |

### `StudyLog`

**File:** `lib/core/models/study_log.dart`

| Field | Type | Mô tả |
|-------|------|-------|
| `id` | `String` | UUID v4 |
| `deckId` | `String` | FK → decks.id |
| `cardsStudied` | `int` | Tổng card đã ôn trong buổi |
| `correct` | `int` | Số card quality ≥ 3 |
| `studiedAt` | `int` | Unix ms |

> Chỉ ghi **1 row mỗi buổi học**.

### `ReviewHistory`

**File:** `lib/core/models/review_history.dart`

| Field | Type | Mô tả |
|-------|------|-------|
| `id` | `String` | UUID v4 |
| `cardId` | `String` | FK → flashcards.id |
| `deckId` | `String` | FK → decks.id |
| `quality` | `int` | 0 = Khó, 3 = OK, 5 = Dễ |
| `reviewedAt` | `int` | Unix ms |

> Ghi **mỗi lần lật card** (granular log).

---

## 3. Data Access Objects (DAOs)

### `DeckDAO`

**File:** `lib/core/database/dao/deck_dao.dart`

| Method | Return | Mô tả |
|--------|--------|-------|
| `getAllDecks()` | `Future<List<Deck>>` | Lấy tất cả deck |
| `getDeckById(String id)` | `Future<Deck?>` | Lấy deck theo ID |
| `insertDeck(Deck deck)` | `Future<void>` | Thêm deck mới |
| `updateDeck(Deck deck)` | `Future<void>` | Cập nhật deck |
| `deleteDeck(String id)` | `Future<void>` | Xóa deck (CASCADE xóa cards) |

### `CardDAO`

**File:** `lib/core/database/dao/card_dao.dart`

| Method | Return | Mô tả |
|--------|--------|-------|
| `getAllCards(String deckId)` | `Future<List<Flashcard>>` | Tất cả card trong deck |
| `getCardsDueToday(String deckId)` | `Future<List<Flashcard>>` | Cards có `next_review <= now` |
| `getTotalCardsDueToday()` | `Future<int>` | Tổng cards due across ALL decks |
| `getCardCount(String deckId)` | `Future<int>` | Đếm cards trong deck |
| `getCardsDuePerDeck()` | `Future<Map<String, int>>` | Due count per deck (cho Home) |
| `insertCard(...)` | `Future<void>` | Thêm card mới (`next_review = now`) |
| `updateSM2(String id, SM2Result)` | `Future<void>` | Cập nhật SM-2 fields |
| `findByFrontBack(deckId, front, back)` | `Future<Flashcard?>` | Check trùng lặp |
| `deleteCard(String id)` | `Future<void>` | Xóa card |

### `StudyLogDAO`

**File:** `lib/core/database/dao/study_log_dao.dart`

| Method | Return | Mô tả |
|--------|--------|-------|
| `insert(StudyLog log)` | `Future<void>` | Ghi log buổi học |
| `getLogsLast7Days()` | `Future<List<StudyLog>>` | Logs 7 ngày (bar chart) |
| `getStudyDates()` | `Future<List<DateTime>>` | Danh sách ngày có học (streak) |

### `ReviewHistoryDAO`

**File:** `lib/core/database/dao/review_history_dao.dart`

| Method | Return | Mô tả |
|--------|--------|-------|
| `insert(...)` | `Future<void>` | Ghi log 1 lần review |
| `getQualityBreakdown(String deckId)` | `Future<Map<int, int>>` | {0: count, 3: count, 5: count} |
| `getHistoryForCard(String cardId)` | `Future<List<ReviewHistory>>` | Lịch sử review 1 card |

---

## 4. ViewModels

### `DeckViewModel`

| Property / Method | Type | Mô tả |
|-------------------|------|-------|
| `decks` | `List<Deck>` | Danh sách deck hiện tại |
| `loadDecks()` | `Future<void>` | Load tất cả deck + card count + due count |
| `createDeck(name, langFront, langBack)` | `Future<void>` | Tạo deck mới |
| `updateDeck(deck)` | `Future<void>` | Cập nhật deck |
| `deleteDeck(id)` | `Future<void>` | Xóa deck |

### `CardViewModel`

| Property / Method | Type | Mô tả |
|-------------------|------|-------|
| `cards` | `List<Flashcard>` | Danh sách card trong deck |
| `loadCards(deckId)` | `Future<void>` | Load cards cho deck |
| `saveCard(deckId, front, back)` | `Future<void>` | Thêm card mới |
| `isDuplicate(deckId, front, back)` | `Future<bool>` | Check trùng (soft warning) |
| `importCsv(deckId, file)` | `Future<ImportResult>` | Import CSV + dedup |
| `deleteCard(id)` | `Future<void>` | Xóa card |

### `StudyViewModel`

| Property / Method | Type | Mô tả |
|-------------------|------|-------|
| `currentCard` | `Flashcard?` | Card đang hiển thị |
| `progress` | `double` | Tiến độ buổi học (0.0 - 1.0) |
| `state` | `StudyState` | `loading / studying / completed` |
| `sessionResult` | `SessionResult?` | Kết quả buổi (studied, correct) |
| `loadDueCards(deckId)` | `Future<void>` | Nạp queue cards due |
| `submitReview(card, quality)` | `Future<void>` | SM-2 + log + next card |

### `StatsViewModel`

| Property / Method | Type | Mô tả |
|-------------------|------|-------|
| `streak` | `int` | Chuỗi ngày học liên tiếp |
| `barChartData` | `List<BarChartEntry>` | Dữ liệu 7 ngày |
| `qualityBreakdown` | `Map<int, int>` | {0: X, 3: Y, 5: Z} |
| `totalDecks` | `int` | Tổng số deck |
| `totalCards` | `int` | Tổng số card |
| `loadStats()` | `Future<void>` | Load toàn bộ stats |

### `SettingsViewModel`

| Property / Method | Type | Mô tả |
|-------------------|------|-------|
| `themeMode` | `ThemeMode` | light / dark / system |
| `setThemeMode(ThemeMode)` | `Future<void>` | Lưu và áp dụng theme |

---

## 5. Utility Classes

### `CsvParser`

**File:** `lib/core/utils/csv_parser.dart`

| Method | Return | Mô tả |
|--------|--------|-------|
| `readCsvContent(PlatformFile)` | `Future<String>` | Đọc file an toàn (path hoặc bytes fallback) |
| `parse(String content)` | `List<CsvRow>` | Parse CSV (auto-detect: `,` `;` `\t`) |
| `importCsv(deckId, file)` | `Future<ImportResult>` | Full import pipeline + dedup |

### `ImportResult`

| Field | Type | Mô tả |
|-------|------|-------|
| `imported` | `int` | Số card đã import thành công |
| `skipped` | `int` | Số card bỏ qua do trùng |
