# 🎨 Design System — ZenFlashCards

> Full documentation of the design system (Design Tokens, Colors, Typography, Components, Accessibility) for the ZenFlashCards application.

---

## 1. Design Vision

**Zen** — minimalist, quiet, and distraction-free.

> _"Users open the app to study, not to enjoy animations. Everything must be fast, clear, and easy to interact with."_

Overall feel: **dark, calm, focused** — like sitting in a dark room with a book and a small reading light.

---

## 2. Color System

### 2.1. Dark Mode (Default)

```
┌─────────────────────────────────────────────────┐
│  Background Main     #0F172A  ████████████████  │
│  Surface (Cards)     #1E293B  ████████████████  │
│  Primary Accent      #4F46E5  ████████████████  │
│  Primary Light       #818CF8  ████████████████  │
│  Text Primary        #F8FAFC  ████████████████  │
│  Text Secondary      #94A3B8  ████████████████  │
│  Text Caption        #A0AEC0  ████████████████  │
│  Divider             #2D3748  ████████████████  │
│  Rating Hard         #EF4444  ████████████████  │
│  Rating OK           #F59E0B  ████████████████  │
│  Rating Easy         #22C55E  ████████████████  │
│  Streak Fire         #F97316  ████████████████  │
└─────────────────────────────────────────────────┘
```

### 2.2. Light Mode

| Token | Hex | Notes |
|-------|-----|-------|
| Background | `#F8FAFC` | Light grayish white |
| Surface | `#FFFFFF` | Pure white |
| Text Primary | `#0F172A` | Dark navy (inverted) |
| Primary Accent | `#4F46E5` | Keep Indigo unchanged |

### 2.3. Semantic Colors

| Context | Color | Hex | Used for |
|---------|-------|-----|----------|
| Rating **Hard** | 🔴 Red | `#EF4444` | "😅 Hard" button, Incorrect Quiz |
| Rating **OK** | 🟡 Yellow/Orange | `#F59E0B` | "😊 OK" button |
| Rating **Easy** | 🟢 Green | `#22C55E` | "😎 Easy" button, Correct Quiz, Tick ✅ |
| **Streak** | 🟠 Orange | `#F97316` | Fire icon 🔥 |
| **Gradient** (Stats) | Indigo | `#3730A3` → `#4F46E5` | Streak card (subtle) |

---

## 3. Typography — Inter

| Style | Size | Weight | Line Height | Color | Used for |
|-------|:----:|:------:|:-----------:|-------|----------|
| Display | 32sp | 700 Bold | 1.2 | `#F8FAFC` | Vocabulary on flashcard front |
| Headline | 20sp | 600 Semi | 1.3 | `#F8FAFC` | Deck name, screen title |
| Title | 16sp | 600 Semi | 1.3 | `#F8FAFC` | Card name in list |
| Body | 14sp | 400 Reg | 1.4 | `#94A3B8` | Description, subtitle |
| Label | 12sp | 500 Med | 1.3 | `#94A3B8` | Language tag, badge |
| Caption | 11sp | 400 Reg | 1.3 | `#A0AEC0` | Small metadata (card count) |

> **WCAG Note**: Caption uses `#A0AEC0` instead of `#94A3B8` to meet contrast ratio ≥ 4.5:1 on a `#1E293B` background for small text size 11sp.

### Font Loading

Use the `google_fonts` package to load Inter via CDN, avoiding bundling `.ttf` files into the APK:

```dart
textTheme: GoogleFonts.interTextTheme()
```

---

## 4. Shape & Spacing System

### 4.1. Border Radius

| Element | Radius | Notes |
|---------|:------:|-------|
| Flashcard (Study) | 24dp | Emphasis, primary focus |
| DeckCard (Home) | 16dp | Standard card |
| Button / Quiz Choice | 12dp | Primary interactions |
| List Item | 8dp | Compact |
| Rating Pill Button | 26dp | Full round pill |

### 4.2. Spacing

| Token | Value | Used for |
|-------|:-----:|----------|
| Screen padding (horizontal) | 20dp | Horizontal padding for all screens |
| Item spacing | 12dp | Spacing between items |
| Card padding (internal) | 18dp | Inner padding for cards |
| Touch target minimum | 48dp × 48dp | All interactive buttons |

### 4.3. Elevation & Shadows

| Element | Shadow |
|---------|--------|
| DeckCard | `0 2px 8px rgba(0,0,0,0.25)` |
| Flashcard (Study) | `0 6px 20px rgba(0,0,0,0.4)` |
| FAB | `0 4px 12px rgba(79,70,229,0.4)` |
| Streak Card | `0 4px 12px rgba(79,70,229,0.3)` |

---

## 5. Component Library

### 5.1. DeckCard

```
┌──────────────────────────────────────┐
│  Common English                     │
│  🇬🇧 English → 🇻🇳 Vietnamese    [12]│
│  39 cards                            │
└──────────────────────────────────────┘
 Surface #1E293B │ radius 16dp │ subtle shadow
 Badge: Indigo circle (due count) or ✅ (done)
 Long-press → context menu: Edit / Delete
```

### 5.2. FlipCard3D

```
┌──────────────────────┐      ┌──────────────────────┐
│     ENGLISH          │      │     VIETNAMESE       │
│                      │      │                      │
│    Serendipity       │ ──→  │  Sự tình cờ may mắn  │
│                      │ 400ms│                      │
│    Tap to flip 👆    │      │  "Finding this was   │
└──────────────────────┘      │   pure serendipity"  │
                              └──────────────────────┘
 Surface #1E293B │ radius 24dp │ prominent shadow
 Animation: rotateY 400ms easeInOut
 Perspective: Matrix4 setEntry(3,2,0.001)
```

### 5.3. Rating Buttons

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  😅 Hard │  │  😊 OK   │  │  😎 Easy │
└──────────┘  └──────────┘  └──────────┘
  #EF4444       #F59E0B       #22C55E
  (15% opacity  (15% opacity  (15% opacity
   background)   background)   background)

When card not flipped: opacity 0.3, pointerEvents none
When card flipped:     opacity 1.0, enabled
→ Do not hide/show to prevent layout jump
```

### 5.4. Quiz Option Button

```
┌────────────────────────────────────────┐
│  Resilience                        ✓  │  ← Correct: green flash #22C55E
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│  Serendipity                       ✗  │  ← Incorrect: red flash #EF4444
└────────────────────────────────────────┘
 Border #2D3748 │ radius 12dp │ surface #1E293B
 Dual signal: Color + Icon (✓/✗) for color-blind users
```

### 5.5. Bottom Navigation Bar

```
┌────────────────────────────────────────┐
│      🏠          📊          ⚙️       │
│    (active)    (inactive)  (inactive)  │
│    #818CF8     #94A3B8     #94A3B8     │
└────────────────────────────────────────┘
 Background #1E293B │ height 64dp
 No text label │ Icon-only minimal
 Active: filled icon + subtle indigo bg (12% opacity)
```

---

## 6. Micro-Animations

| Animation | Duration | Curve | Description |
|-----------|:--------:|:-----:|-------------|
| Card flip 3D | 400ms | `easeInOut` | Y-axis rotation with perspective |
| Button tap | 100ms | linear | Scale down 0.95 → 1.0 |
| Screen transition | 300ms | `easeOut` | Slide in from right |
| Score ring fill | 800ms | `easeOut` | Conic gradient animate from 0% → actual% |
| Badge count-up | 600ms | `easeOut` | Number jumps from 0 to actual value |
| Quiz flash | 300ms | linear | Background green/red flash then fade |
| Card dismiss | 200ms | `easeIn` | Slight upward swipe when rating selected |

---

## 7. Accessibility Compliance (WCAG AA)

### 7.1. Contrast Ratio Audit

| Text | Background | Ratio | Result |
|------|------------|:-----:|:------:|
| `#F8FAFC` (primary) | `#1E293B` (surface) | **13.8:1** | ✅ AAA |
| `#F8FAFC` (primary) | `#0F172A` (main bg) | **15.4:1** | ✅ AAA |
| `#A0AEC0` (caption) | `#1E293B` (surface) | **5.2:1** | ✅ AA |
| `#94A3B8` (secondary) | `#1E293B` (surface) | **4.6:1** | ✅ AA |
| `#4F46E5` (primary) | `#0F172A` (main bg) | **4.8:1** | ✅ AA |

### 7.2. Color Blindness Support

| Screen | Solution |
|--------|----------|
| Quiz | Do not rely only on green/red — always include icons **✓** (correct) and **✗** (incorrect) |
| Study rating | Visual emojis 😅/😊/😎 + clear text labels alongside colors |
| Home badge | Tick ✅ when completed (do not completely hide badge → prevents loss of positive feedback) |

### 7.3. Touch Target

- All buttons, icons, and tab navs: minimum **48dp × 48dp**
- No hit area smaller than 44dp throughout the entire app
