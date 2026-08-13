# 📚 API Reference — ZenFlashCards

> Detailed reference documentation for DAOs, ViewModels, SM-2 Engine, and Utility classes.

---

## 1. SM-2 Algorithm Engine

### File: `lib/core/algorithms/sm2.dart`

#### `SM2Result` Class

The result object returned after SM-2 calculation.

| Property | Type | Description |
|----------|------|-------------|
| `repetition` | `int` | Consecutive correct review count (reset to 0 when quality < 3) |
| `easiness` | `double` | Easiness Factor (EF), min = 1.3, default = 2.5 |
| `intervalDays` | `int` | Number of days until the next review |
| `nextReviewMs` | `int` | Unix timestamp (ms) of the next review |

#### `calculateNextReview()`

```dart
SM2Result calculateNextReview({
  required int repetition,    // Current correct review count
  required double easiness,   // Current EF (>= 1.3)
  required int intervalDays,  // Current interval (days)
  required int quality,       // 0=Hard, 3=OK, 5=Easy
})
```

**Logic:**

| Condition | Result |
|-----------|---------|
| `quality < 3` | `repetition = 0`, `interval = 1` |
| `quality >= 3`, rep 0→1 | `interval = 1` |
| `quality >= 3`, rep 1→2 | `interval = 6` |
| `quality >= 3`, rep > 2 | `interval = round(interval × EF)` |

**New EF Formula:**
```
EF' = EF + (0.1 - (5 - q) × (0.08 + (5 - q) × 0.02))
EF' = max(EF', 1.3)
```

---

## 2. Data Models

### `Deck`

**File:** `lib/core/models/deck.dart`

| Field | Type | SQLite Column | Description |
|-------|------|:-------------:|-------------|
| `id` | `String` | `id TEXT PK` | UUID v4 |
| `name` | `String` | `name TEXT NOT NULL` | Deck name |
| `description` | `String?` | `description TEXT` | Description (optional) |
| `languageFront` | `String` | `language_front TEXT` | Front language |
| `languageBack` | `String` | `language_back TEXT` | Back language |
| `createdAt` | `int` | `created_at INTEGER` | Unix ms |

**Methods:** `toMap()`, `Deck.fromMap(Map<String, dynamic>)`

### `Flashcard`

**File:** `lib/core/models/flashcard.dart`

| Field | Type | Default | Description |
|-------|------|:-------:|-------------|
| `id` | `String` | — | UUID v4 |
| `deckId` | `String` | — | FK → decks.id |
| `front` | `String` | — | Front content |
| `back` | `String` | — | Back content |
| `repetition` | `int` | `0` | SM-2: correct review count |
| `easiness` | `double` | `2.5` | SM-2: easiness factor |
| `interval` | `int` | `1` | SM-2: interval (days) |
| `nextReview` | `int` | `now()` | Unix ms, next review |
| `createdAt` | `int` | — | Unix ms |

### `StudyLog`

**File:** `lib/core/models/study_log.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID v4 |
| `deckId` | `String` | FK → decks.id |
| `cardsStudied` | `int` | Total cards reviewed in session |
| `correct` | `int` | Number of cards with quality ≥ 3 |
| `studiedAt` | `int` | Unix ms |

> Logs only **1 row per session**.

### `ReviewHistory`

**File:** `lib/core/models/review_history.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID v4 |
| `cardId` | `String` | FK → flashcards.id |
| `deckId` | `String` | FK → decks.id |
| `quality` | `int` | 0 = Hard, 3 = OK, 5 = Easy |
| `reviewedAt` | `int` | Unix ms |

> Logs **every single card flip** (granular log).

---

## 3. Data Access Objects (DAOs)

### `DeckDAO`

**File:** `lib/core/database/dao/deck_dao.dart`

| Method | Return | Description |
|--------|--------|-------------|
| `getAllDecks()` | `Future<List<Deck>>` | Retrieve all decks |
| `getDeckById(String id)` | `Future<Deck?>` | Retrieve deck by ID |
| `insertDeck(Deck deck)` | `Future<void>` | Insert new deck |
| `updateDeck(Deck deck)` | `Future<void>` | Update deck |
| `deleteDeck(String id)` | `Future<void>` | Delete deck (CASCADE deletes cards) |

### `CardDAO`

**File:** `lib/core/database/dao/card_dao.dart`

| Method | Return | Description |
|--------|--------|-------------|
| `getAllCards(String deckId)` | `Future<List<Flashcard>>` | All cards in a deck |
| `getCardsDueToday(String deckId)` | `Future<List<Flashcard>>` | Cards with `next_review <= now` |
| `getTotalCardsDueToday()` | `Future<int>` | Total cards due across ALL decks |
| `getCardCount(String deckId)` | `Future<int>` | Count cards in a deck |
| `getCardsDuePerDeck()` | `Future<Map<String, int>>` | Due count per deck (for Home) |
| `insertCard(...)` | `Future<void>` | Insert new card (`next_review = now`) |
| `updateSM2(String id, SM2Result)` | `Future<void>` | Update SM-2 fields |
| `findByFrontBack(deckId, front, back)` | `Future<Flashcard?>` | Check for duplicates |
| `deleteCard(String id)` | `Future<void>` | Delete card |

### `StudyLogDAO`

**File:** `lib/core/database/dao/study_log_dao.dart`

| Method | Return | Description |
|--------|--------|-------------|
| `insert(StudyLog log)` | `Future<void>` | Log a study session |
| `getLogsLast7Days()` | `Future<List<StudyLog>>` | Logs for the last 7 days (bar chart) |
| `getStudyDates()` | `Future<List<DateTime>>` | List of dates with study activity (streak) |

### `ReviewHistoryDAO`

**File:** `lib/core/database/dao/review_history_dao.dart`

| Method | Return | Description |
|--------|--------|-------------|
| `insert(...)` | `Future<void>` | Log a single review |
| `getQualityBreakdown(String deckId)` | `Future<Map<int, int>>` | {0: count, 3: count, 5: count} |
| `getHistoryForCard(String cardId)` | `Future<List<ReviewHistory>>` | Review history of a single card |

---

## 4. ViewModels

### `DeckViewModel`

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `decks` | `List<Deck>` | Current list of decks |
| `loadDecks()` | `Future<void>` | Load all decks + card count + due count |
| `createDeck(name, langFront, langBack)` | `Future<void>` | Create a new deck |
| `updateDeck(deck)` | `Future<void>` | Update a deck |
| `deleteDeck(id)` | `Future<void>` | Delete a deck |

### `CardViewModel`

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `cards` | `List<Flashcard>` | List of cards in a deck |
| `loadCards(deckId)` | `Future<void>` | Load cards for a deck |
| `saveCard(deckId, front, back)` | `Future<void>` | Insert a new card |
| `isDuplicate(deckId, front, back)` | `Future<bool>` | Check for duplicates (soft warning) |
| `importCsv(deckId, file)` | `Future<ImportResult>` | Import CSV + deduplicate |
| `deleteCard(id)` | `Future<void>` | Delete a card |

### `StudyViewModel`

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `currentCard` | `Flashcard?` | Currently displayed card |
| `progress` | `double` | Session progress (0.0 - 1.0) |
| `state` | `StudyState` | `loading / studying / completed` |
| `sessionResult` | `SessionResult?` | Session result (studied, correct) |
| `loadDueCards(deckId)` | `Future<void>` | Load queue of due cards |
| `submitReview(card, quality)` | `Future<void>` | SM-2 calculation + log + next card |

### `StatsViewModel`

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `streak` | `int` | Consecutive study days streak |
| `barChartData` | `List<BarChartEntry>` | Data for the last 7 days |
| `qualityBreakdown` | `Map<int, int>` | {0: X, 3: Y, 5: Z} |
| `totalDecks` | `int` | Total number of decks |
| `totalCards` | `int` | Total number of cards |
| `loadStats()` | `Future<void>` | Load all stats |

### `SettingsViewModel`

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `themeMode` | `ThemeMode` | light / dark / system |
| `setThemeMode(ThemeMode)` | `Future<void>` | Save and apply theme |

---

## 5. Utility Classes

### `CsvParser`

**File:** `lib/core/utils/csv_parser.dart`

| Method | Return | Description |
|--------|--------|-------------|
| `readCsvContent(PlatformFile)` | `Future<String>` | Safe file reading (path or bytes fallback) |
| `parse(String content)` | `List<CsvRow>` | Parse CSV (auto-detect: `,` `;` `\t`) |
| `importCsv(deckId, file)` | `Future<ImportResult>` | Full import pipeline + deduplicate |

### `ImportResult`

| Field | Type | Description |
|-------|------|-------------|
| `imported` | `int` | Number of successfully imported cards |
| `skipped` | `int` | Number of cards skipped due to duplication |
