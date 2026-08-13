# 📊 System Diagrams — ZenFlashCards

> A comprehensive collection of technical diagrams detailing the system architecture, state machines, user journeys, and data flows.

---

## 1. System Context Diagram (C4 Model - Level 1)

This diagram shows how the user interacts with the ZenFlashCards system and how the system interacts with the local storage.

```mermaid
C4Context
    title System Context diagram for ZenFlashCards

    Person(user, "User", "A student or language learner")
    System(app, "ZenFlashCards App", "Allows users to create, import, and study flashcards using SM-2 algorithm")
    
    SystemDb(sqlite, "Local SQLite Database", "Stores decks, flashcards, study logs, and review history")
    System_Ext(saf, "Android Storage Access Framework (SAF)", "Provides access to local CSV files for import")

    Rel(user, app, "Uses", "Touch")
    Rel(app, sqlite, "Reads/Writes data", "sqflite")
    Rel(app, saf, "Reads CSV files", "Intent.ACTION_OPEN_DOCUMENT")
    Rel(user, saf, "Selects file", "UI")
```

---

## 2. Flashcard State Machine Diagram

This state machine illustrates the lifecycle of a single flashcard during a study session.

```mermaid
stateDiagram-v2
    [*] --> LoadingQueue
    LoadingQueue --> FrontShowing : Queue loaded, get first card
    
    state FrontShowing {
        [*] --> Idle
        Idle --> Idle : Wait for user tap
    }
    
    FrontShowing --> BackShowing : User taps card (RotateY 400ms)
    
    state BackShowing {
        [*] --> AwaitingRating
        AwaitingRating --> HardRated : User taps 'Hard'
        AwaitingRating --> OKRated : User taps 'OK'
        AwaitingRating --> EasyRated : User taps 'Easy'
    }
    
    BackShowing --> UpdatingSM2 : Rating selected
    UpdatingSM2 --> LoggingHistory : SM-2 Calculated
    
    LoggingHistory --> NextCard : Queue has more cards
    LoggingHistory --> SessionComplete : Queue empty
    
    NextCard --> FrontShowing : Load next card
    SessionComplete --> [*]
```

---

## 3. Class Diagram (Domain Models)

```mermaid
classDiagram
    class Deck {
        +String id
        +String name
        +String description
        +String languageFront
        +String languageBack
        +int createdAt
        +toMap()
        +fromMap()
    }

    class Flashcard {
        +String id
        +String deckId
        +String front
        +String back
        +int repetition
        +double easiness
        +int interval
        +int nextReview
        +int createdAt
        +toMap()
        +fromMap()
    }

    class StudyLog {
        +String id
        +String deckId
        +int cardsStudied
        +int correct
        +int studiedAt
    }

    class ReviewHistory {
        +String id
        +String cardId
        +String deckId
        +int quality
        +int reviewedAt
    }
    
    class SM2Result {
        +int repetition
        +double easiness
        +int intervalDays
        +int nextReviewMs
    }

    Deck "1" *-- "many" Flashcard : contains
    Deck "1" *-- "many" StudyLog : tracks sessions for
    Flashcard "1" *-- "many" ReviewHistory : has history
```

---

## 4. Activity Diagram: CSV Import Process

Detailed flow of the CSV Import mechanism, including SAF fallback for Android 13+ and duplicate handling.

```mermaid
actdiag
    actdiag {
      User -> DeckDetail [label = "Tap Import CSV"];
      DeckDetail -> FilePicker [label = "pickFiles(withData: true)"];
      FilePicker -> DeckDetail [label = "Returns PlatformFile"];
      DeckDetail -> CardViewModel [label = "importCsv(file)"];
      
      CardViewModel -> CsvParser [label = "readCsvContent(file)"];
      
      CsvParser -> CsvParser [label = "Check file.path != null"];
      CsvParser -> CsvParser [label = "Check file.bytes != null"];
      
      CsvParser -> CardViewModel [label = "Returns parsed List<CsvRow>"];
      
      CardViewModel -> CardDAO [label = "Fetch existing cards"];
      CardDAO -> CardViewModel [label = "Returns cards"];
      
      CardViewModel -> CardViewModel [label = "Loop through CsvRow"];
      CardViewModel -> CardViewModel [label = "Check if front+back matches"];
      
      CardViewModel -> CardDAO [label = "Insert new cards"];
      
      CardViewModel -> DeckDetail [label = "Returns ImportResult(imported, skipped)"];
      DeckDetail -> User [label = "Show Snackbar"];
    }
```
*(Note: standard activity diagram format for mermaid using flowchart below for better rendering compatibility)*

```mermaid
flowchart TD
    Start([User taps Import CSV]) --> PickFile[FilePicker: pickFiles]
    PickFile --> CheckPath{file.path != null?}
    CheckPath -- Yes --> ReadPath[File(path).readAsString]
    CheckPath -- No --> CheckBytes{file.bytes != null?}
    CheckBytes -- Yes --> ReadBytes[utf8.decode(bytes)]
    CheckBytes -- No --> ThrowErr[Throw Exception]
    
    ReadPath --> ParseCSV[Parse CSV into Rows]
    ReadBytes --> ParseCSV
    
    ParseCSV --> FetchDB[Fetch existing cards from DB]
    FetchDB --> LoopRow[Loop through each CSV Row]
    
    LoopRow --> CheckDup{Is front+back exact match?}
    CheckDup -- Yes --> Skip[skipped++]
    CheckDup -- No --> InsertDB[CardDAO.insertCard] --> Added[imported++]
    
    Skip --> MoreRows{More rows?}
    Added --> MoreRows
    
    MoreRows -- Yes --> LoopRow
    MoreRows -- No --> Finish([Show Snackbar: Imported X, Skipped Y])
```

---

## 5. UI Navigation Map

```mermaid
mindmap
  root((ZenFlashCards))
    Home Screen
      List of Decks
      Due Today Badge
      FAB: Create Deck
    Deck Detail Screen
      Flashcard List
      Study Now Button
      FAB: Add Card
      Menu: Import CSV
    Study Screen
      FlipCard3D
      Rating Buttons
      ProgressBar
      Result Dialog
    Stats Screen
      7-Day Bar Chart
      Quality Pie Chart
      Fire Streak
    Settings Screen
      Theme Switcher
      App Info
```
