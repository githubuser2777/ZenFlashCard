# 🗄️ Tài Liệu Database — ZenFlashCards

> Chi tiết schema, indexes, query patterns và migration strategy cho SQLite database.

---

## 1. Tổng Quan Database

| Thuộc tính | Giá trị |
|-----------|---------|
| Engine | SQLite (via `sqflite` package) |
| Lưu trữ | 100% offline, local device |
| Số bảng | 4 |
| Số indexes | 6 |
| ID Strategy | UUID v4 (text) |
| Timestamp | Unix milliseconds (integer) |

---

## 2. Entity Relationship Diagram

```mermaid
erDiagram
    DECKS ||--o{ FLASHCARDS : "contains"
    DECKS ||--o{ STUDY_LOGS : "tracks sessions"
    DECKS ||--o{ REVIEW_HISTORY : "tracks reviews"
    FLASHCARDS ||--o{ REVIEW_HISTORY : "reviewed in"

    DECKS {
        text id PK "UUID v4"
        text name "NOT NULL"
        text description "nullable"
        text language_front "NOT NULL (e.g. English)"
        text language_back "NOT NULL (e.g. Vietnamese)"
        integer created_at "Unix ms"
    }

    FLASHCARDS {
        text id PK "UUID v4"
        text deck_id FK "→ decks.id, CASCADE"
        text front "NOT NULL"
        text back "NOT NULL"
        integer repetition "DEFAULT 0 (SM-2)"
        real easiness "DEFAULT 2.5 (SM-2 EF)"
        integer interval "DEFAULT 1 (SM-2 days)"
        integer next_review "Unix ms (init = now)"
        integer created_at "Unix ms"
    }

    STUDY_LOGS {
        text id PK "UUID v4"
        text deck_id FK "→ decks.id"
        integer cards_studied "total cards in session"
        integer correct "quality >= 3 count"
        integer studied_at "Unix ms"
    }

    REVIEW_HISTORY {
        text id PK "UUID v4"
        text card_id FK "→ flashcards.id, CASCADE"
        text deck_id FK "→ decks.id"
        integer quality "0=Khó, 3=OK, 5=Dễ"
        integer reviewed_at "Unix ms"
    }
```

---

## 3. Schema DDL

### 3.1. Bảng `decks`

```sql
CREATE TABLE decks (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  language_front TEXT NOT NULL,
  language_back TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
```

> **Ghi chú**: Không có cột `card_count` — tính động bằng `SELECT COUNT(*) FROM flashcards WHERE deck_id = ?` để tránh data inconsistency.

### 3.2. Bảng `flashcards`

```sql
CREATE TABLE flashcards (
  id TEXT PRIMARY KEY,
  deck_id TEXT NOT NULL,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  repetition INTEGER DEFAULT 0,
  easiness REAL DEFAULT 2.5,
  interval INTEGER DEFAULT 1,
  next_review INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (deck_id) REFERENCES decks(id) ON DELETE CASCADE
);

CREATE INDEX idx_flashcards_deck ON flashcards(deck_id);
CREATE INDEX idx_flashcards_next_review ON flashcards(next_review);
```

> **Khởi tạo `next_review`**: Set bằng `DateTime.now().millisecondsSinceEpoch` khi tạo card mới → card xuất hiện ngay trong lượt ôn đầu tiên.

### 3.3. Bảng `study_logs`

```sql
CREATE TABLE study_logs (
  id TEXT PRIMARY KEY,
  deck_id TEXT NOT NULL,
  cards_studied INTEGER NOT NULL,
  correct INTEGER NOT NULL,
  studied_at INTEGER NOT NULL
);

CREATE INDEX idx_study_logs_date ON study_logs(studied_at);
```

> **Quy tắc ghi**: Chỉ insert **1 row khi kết thúc buổi học** (tất cả cards due đã được review). Dùng cho bar chart 7 ngày và tính streak.

### 3.4. Bảng `review_history`

```sql
CREATE TABLE review_history (
  id TEXT PRIMARY KEY,
  card_id TEXT NOT NULL,
  deck_id TEXT NOT NULL,
  quality INTEGER NOT NULL,
  reviewed_at INTEGER NOT NULL,
  FOREIGN KEY (card_id) REFERENCES flashcards(id) ON DELETE CASCADE
);

CREATE INDEX idx_review_history_card ON review_history(card_id);
CREATE INDEX idx_review_history_deck ON review_history(deck_id);
```

> **Quy tắc ghi**: Insert **1 row mỗi lần user bấm Khó/OK/Dễ** cho 1 card. Dùng cho pie chart breakdown quality.

---

## 4. Index Strategy

| Index | Bảng | Cột | Phục vụ query |
|-------|------|-----|---------------|
| `idx_flashcards_deck` | flashcards | deck_id | Load cards theo deck |
| `idx_flashcards_next_review` | flashcards | next_review | Cards due today (`<= now`) |
| `idx_study_logs_date` | study_logs | studied_at | Bar chart 7 ngày, streak |
| `idx_review_history_card` | review_history | card_id | Lịch sử review 1 card |
| `idx_review_history_deck` | review_history | deck_id | Pie chart theo deck |

> **Deferred index**: `idx_review_history_date` trên `reviewed_at` sẽ thêm ở v2 khi cần heatmap/date-range filter.

---

## 5. Query Patterns Thường Dùng

### Cards Due Today (Cho 1 Deck)

```sql
SELECT * FROM flashcards
WHERE deck_id = ? AND next_review <= ?
ORDER BY next_review ASC;
-- ? = deckId, ? = DateTime.now().millisecondsSinceEpoch
```

### Tổng Cards Due Today (Tất Cả Deck — Home Badge)

```sql
SELECT COUNT(*) as count FROM flashcards
WHERE next_review <= ?;
```

### Card Count Trong Deck

```sql
SELECT COUNT(*) as count FROM flashcards
WHERE deck_id = ?;
```

### Cards Due Per Deck (Cho Home Screen)

```sql
SELECT deck_id, COUNT(*) as due_count FROM flashcards
WHERE next_review <= ?
GROUP BY deck_id;
```

### Bar Chart — Cards Học Trong 7 Ngày

```sql
SELECT studied_at, SUM(cards_studied) as total
FROM study_logs
WHERE studied_at >= ?
GROUP BY DATE(studied_at / 1000, 'unixepoch')
ORDER BY studied_at ASC;
-- ? = 7 ngày trước (milliseconds)
```

### Pie Chart — Phân Bố Quality Theo Deck

```sql
SELECT quality, COUNT(*) as count
FROM review_history
WHERE deck_id = ?
GROUP BY quality;
```

### Streak — Chuỗi Ngày Học Liên Tục

```sql
SELECT DISTINCT DATE(studied_at / 1000, 'unixepoch') as study_date
FROM study_logs
ORDER BY study_date DESC;
-- Đếm số ngày liên tục từ hôm nay trở về trước
```

### Check Duplicate Card

```sql
SELECT * FROM flashcards
WHERE deck_id = ? AND LOWER(TRIM(front)) = ? AND LOWER(TRIM(back)) = ?
LIMIT 1;
```

---

## 6. Migration Strategy

### Version 1 (Initial)

Tạo đầy đủ 4 bảng + 6 indexes như mô tả ở trên.

### Version 2 (Planned)

```sql
-- Thêm index cho date-range query trên review_history
CREATE INDEX idx_review_history_date ON review_history(reviewed_at);

-- Nếu thêm tính năng TTS
ALTER TABLE flashcards ADD COLUMN audio_url TEXT;
```

### Migration Code Pattern

```dart
await openDatabase(
  path,
  version: 2,
  onCreate: (db, version) async {
    // Tạo tất cả bảng v2
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 2) {
      await db.execute('CREATE INDEX idx_review_history_date ON review_history(reviewed_at)');
    }
  },
);
```
