# 🏗️ System Architecture Documentation — ZenFlashCards

> Technical documentation describing the software architecture, design decisions, and data flow of the ZenFlashCards application in detail.

---

## 1. Architectural Overview

ZenFlashCards adopts **Clean Architecture** combined with a **Feature-Driven Structure**, divided into 3 main layers:

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        direction LR
        Screens["Screens<br/>(7 screens)"]
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

### Design Principles

| Principle | Application |
|------------|-------------|
| **Separation of Concerns** | UI does not contain business logic; ViewModel is unaware of widgets |
| **Dependency Injection** | MultiProvider at the root, inject ViewModel into Screens |
| **Single Source of Truth** | SQLite is the sole source of truth; UI only reflects the state |
| **Offline-First** | 100% of data is stored locally, no network dependency |
| **Feature Cohesion** | Each feature (home, deck, study...) is self-contained with screen + viewmodel |

---

## 2. Detailed Data Flow

### 2.1. Study Session Flow

```mermaid
sequenceDiagram
    participant U as User
    participant S as StudyScreen
    participant VM as StudyViewModel
    participant SM as SM-2 Engine
    participant CD as CardDAO
    participant RH as ReviewHistoryDAO
    participant SL as StudyLogDAO

    U->>S: Clicks "Study Now"
    S->>VM: loadDueCards(deckId)
    VM->>CD: getCardsDueToday(deckId)
    CD-->>VM: List<Flashcard>
    VM-->>S: Displays the first card

    U->>S: Taps card (flips)
    S->>S: 3D flip animation (400ms)
    S->>S: Enables 3 rating buttons

    U->>S: Clicks "😎 Easy" (quality=5)
    S->>VM: submitReview(card, quality=5)
    VM->>SM: calculateNextReview(rep, EF, interval, 5)
    SM-->>VM: SM2Result (new interval, EF, next_review)
    VM->>CD: updateSM2(cardId, SM2Result)
    VM->>RH: insert(cardId, deckId, quality=5)
    VM->>VM: sessionStudied++, sessionCorrect++

    Note over VM: Repeats for each card...

    VM->>VM: Queue is empty
    VM->>SL: insert(StudyLog: studied, correct, timestamp)
    VM-->>S: Navigate → ResultScreen
```

### 2.2. CSV Import Flow

```mermaid
sequenceDiagram
    participant U as User
    participant D as DeckDetailScreen
    participant VM as CardViewModel
    participant FP as FilePicker (SAF)
    participant CSV as CSV Parser
    participant CD as CardDAO

    U->>D: Clicks "Import CSV"
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

    loop For each row
        alt Duplicate front+back
            VM->>VM: skipped++
        else No duplicate
            VM->>CD: insertCard(deckId, front, back)
            VM->>VM: imported++
        end
    end

    VM-->>D: ImportResult(imported, skipped)
    D->>D: Snackbar "Imported X, skipped Y duplicates"
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

| ViewModel | Responsibility |
|-----------|----------------|
| `DeckViewModel` | Deck CRUD, dynamic card count calculation, query cards due today |
| `CardViewModel` | Card CRUD, soft duplicate check, import CSV + deduplicate |
| `StudyViewModel` | Queue management, SM-2 calculation, review logging, session finalization |
| `StatsViewModel` | Streak calculation, bar chart data (7 days), pie chart data (quality breakdown) |
| `SettingsViewModel` | ThemeMode persist/restore via SharedPreferences |

---

## 4. Architecture Decisions (ADRs)

### ADR-001: Drop denormalized `card_count` in `decks` table

- **Decision**: Calculate `COUNT(*)` dynamically from the `flashcards` table instead of storing a `card_count` column.
- **Reason**: Prevents data inconsistency when importing or deleting cards.
- **Trade-off**: Requires an additional query, but SQLite with an index on `deck_id` is very fast (< 1ms).

### ADR-002: Separate `study_logs` and `review_history`

- **Decision**: `study_logs` = 1 row per session (aggregate), `review_history` = 1 row per card flip (granular).
- **Reason**: Bar charts and streaks only need aggregates; pie charts require granular quality data.
- **Trade-off**: Results in more rows in `review_history`, but offline SQLite handles this effortlessly.

### ADR-003: SAF (Storage Access Framework) for file picker

- **Decision**: Use `Intent.ACTION_OPEN_DOCUMENT` via `file_picker`, do not declare storage permissions.
- **Reason**: Android 13+ scoped storage does not allow direct filesystem access; declaring unnecessary permissions will cause rejection by the Play Store.
- **Fallback**: Always request `withData: true` to get `PlatformFile.bytes` when `path == null`.

### ADR-004: Provider instead of Riverpod/Bloc

- **Decision**: Use Provider (ChangeNotifier) for state management.
- **Reason**: Simple, less boilerplate, suitable for the scope of a small-to-medium offline app.
- **When to upgrade**: If reactive streams or multi-platform sync are needed (v2).

---

## 5. Security & Performance

### Security

- **No sensitive data stored**: The app only stores vocabulary, no personal information.
- **No permissions required**: Does not declare storage/camera/location permissions.
- **Local SQLite**: Data never leaves the device.

### Performance

- **Index optimization**: 6 indexes on frequently queried columns.
- **Animation**: 3D flip card runs on the GPU via a `Transform` matrix, smooth 60fps.
- **Memory**: `AnimationController` is disposed properly based on the lifecycle, no leaks.
- **Lazy loading**: Cards are only loaded when the user enters a deck; they are not loaded upfront.
