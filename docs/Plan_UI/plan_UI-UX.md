# 🎨 ZenFlashCards — UI/UX Design Brief

> Document describing the design concept to be used as a prompt for Stitch.

---

## Design Vision

**Zen** — minimalist, quiet, distraction-free. Users open the app to study, not to enjoy animations. Everything must be fast, clear, and easy to touch. Overall feel: *dark, calm, focused* — like sitting in a dark room with a book and a small lamp.

**Premium Feel (Pro Max)**: Uses Spring animations, subtle Haptic Feedback, high contrast text for accessibility, and modern minimalist vector icons (e.g., Lucide, Phosphor, SF Symbols) instead of emojis to maintain a mature, high-end aesthetic.

---

## Design System

### Colors

| Role | Color | Hex |
|---------|-----|-----|
| Main Background | Very dark Navy | `#0F172A` |
| Surface (card, bottom bar) | Slightly darker Navy | `#1E293B` |
| Accent / Primary | Indigo | `#4F46E5` |
| Light Accent (dark mode) | Light Indigo | `#818CF8` |
| Main Text | White | `#F8FAFC` |
| Secondary Text | Blue-gray | `#CBD5E1` (Increased contrast for a11y) |
| Caption Text | Brighter gray | `#A0AEC0` (Comfortably passes WCAG AA at 11sp) |
| Lines / dividers | `#2D3748` | |
| **Hard / Incorrect** | Red | `#EF4444` |
| **OK** | Yellow-orange | `#F59E0B` |
| **Easy / Correct** | Green | `#22C55E` |
| Streak / Focus | Orange | `#F97316` |

> Light mode: background `#F8FAFC`, surface `#FFFFFF`, text `#0F172A`, accent remains Indigo `#4F46E5`.

### Typography — Inter

| Style | Size | Weight | Usage |
|-------|------|--------|----------|
| Display | 32sp | 700 Bold | Vocabulary on the front of the flashcard |
| Headline | 20sp | 600 SemiBold | Deck name, screen title |
| Title | 16sp | 600 SemiBold | Card name in the list |
| Body | 14sp | 400 Regular | Descriptions, subtitles |
| Label | 12sp | 500 Medium | Language tags, badges |
| Caption | 11sp | 400 Regular | Small metadata (card count) |

### Shapes, Spacing & Accessibility (A11y)

- Border radius: **16dp** for deck cards, **12dp** for buttons, **8dp** for list items
- Horizontal screen padding: **20dp**
- Item spacing: **12dp**
- Card elevation: slight shadow `0 2px 8px rgba(0,0,0,0.3)`
- **Touch Targets**: All interactive elements (buttons, back icons, menu items, quiz options) MUST have a minimum touch area of **48x48dp** to comply with mobile accessibility standards.
- **Screen Reader Support**: Ensure `contentDescription` / `accessibilityLabel` / `aria-label` are applied to all non-text UI elements (e.g., Progress bars, Back buttons, Charts).

### Micro-animations & Haptics

- **Animations**: Use **Spring Physics** (lò xo) instead of standard `easeInOut` for a natural, high-end feel.
- **Haptic Feedback**:
  - **Light Impact**: Flipping a card, tapping standard buttons.
  - **Success / Medium Impact**: Completing a deck, answering a quiz correctly.
  - **Error / Heavy Impact**: Answering a quiz incorrectly, error states.
- **Flip card**: 3D Y-axis rotation with Spring physics.
- **Button tap**: slight scale down to `0.95` with Spring physics.
- **Screen transition**: slide from right, spring duration ~300ms.

---

## Screen 1 — Home (Deck List)

**Layout**: Scaffold with TopAppBar + list of decks + FAB

**TopAppBar**:
- Title: "ZenFlashCards" — Inter SemiBold 20sp, white color
- Right side: Search/Filter (Vector Icon) (optional v2)
- Background: transparent, no dividing lines

**Body** — list of DeckCards:
- Each DeckCard is a `Card` with `borderRadius: 16dp`, background `#1E293B`
- **Left**: deck name (Headline, white), below is "ENG → VIE" (Label, gray), and "39 cards" (Caption, gray)
- **Right**: indigo circular badge, number of **cards due today** in the middle — only displayed if > 0; if = 0, **display a small green tick (Vector Icon)** (do not hide the badge — hiding it completely makes a "completed" deck look exactly like an untouched deck, losing positive feedback)
- Long-press deck → context menu: Edit / Delete + Light haptic feedback

**Empty state** (no decks yet):
- Large Library/Book Vector Icon
- Text: "No decks available\nTap + to create your first deck"
- Gray color, centered

**FAB**: round indigo `+`, bottom-right position, low elevation

**Bottom Navigation Bar**:
- 3 tabs: Home / Stats / Settings (Use clean Vector Icons)
- Active icon: indigo, filled variant
- Inactive icon: gray, outline variant
- No text label (icons are clear enough)

---

## Screen 2 — Deck Detail

**Layout**: Scaffold with hide-on-scroll TopAppBar + sticky action row + card list + FAB

**TopAppBar**:
- Back button (Vector Icon)
- Title: deck name, Inter SemiBold
- Subtitle: "English → Vietnamese · 39 cards"
- 3-dot menu: **Import CSV**, Edit deck name, Delete deck (Import CSV is moved here to keep the action row clean).

**Action Row** (sticky, non-scrolling):
- 2 horizontal buttons:
  - `Study Now` (Primary) — filled indigo, large, takes up dominant space. Book Vector Icon.
  - `Quiz` (Secondary) — outlined indigo, slightly smaller width. Target Vector Icon.
- If 0 cards due today: "Study Now" button is disabled with the text "Reviewed today (Check Icon)"

**Card List** (scrollable):
- Each item: row with front (bold) — `→` sign — back (gray)
- Swipe right → edit, swipe left → delete (with confirmation)
- Tap → view card details (optional)
- Thin divider between items

**FAB**: `+` to manually add a card, indigo

---

## Screen 3 — Study / Flashcard Flip

**Layout**: Full screen, no bottom nav. Minimalist TopAppBar: X (exit) button on the left, "3 / 12" progress text on the right.

Thin (4dp) indigo **Progress bar** right below AppBar, fills according to progress (must have `accessibilityLabel` with progress %).

**Card Area** (occupies 60% of screen height):
- Card uses dark surface `#1E293B`, `borderRadius: 24dp`, shadow `0 4px 16px rgba(0,0,0,0.4)`
- Text on card is white `#F8FAFC` — consistent with the rest of the app (do not use white cards to avoid breaking the dark/calm vibe)
- Before flipping: only shows **front word** — 32sp Display font, centered. Small "ENGLISH" tag above the word, `#CBD5E1` color
- Tap card → 3D flip animation (Spring) + **Light Haptic** → back shows: 28sp Display **meaning** + optional smaller example sentence below, `#CBD5E1` color
- Small corner hint "Tap to flip (Finger Icon)" the first time (then hidden)

**Rating Area**:
- **Before flipping card**: The area below the card is completely empty (Zen approach).
- **After flipping card**: 3 horizontal buttons **Fade in and Slide up** smoothly. Container has fixed height to prevent layout jump.
- 3 buttons (White text for A11y contrast, color applied to border/background tint):
  - `Hard` — tinted `#EF4444` background/border, **white text**
  - `OK` — tinted `#F59E0B` background/border, **white text**
  - `Easy` — tinted `#22C55E` background/border, **white text**
- Tap any of the 3 → card disappears (slight swipe up), next card appears

---

## Screen 4 — Quiz (Multiple Choice)

**Layout**: No bottom nav. AppBar: "Quiz", "4/10" progress on the right

Thin indigo **Progress bar** right below AppBar.

**Question card**: dark surface `#1E293B`, `borderRadius: 20dp`
- Word to guess: 24sp bold Headline, white color `#F8FAFC`, centered
- Small "Select the correct meaning" tag above, `#CBD5E1` color

**4 choices** — vertical stack, each button:
- `borderRadius: 12dp`, background `#1E293B`, thin border `#2D3748`, min-height `48dp`
- 16sp Body text, left-aligned, 16dp padding, white color `#F8FAFC`
- When **correct**: tinted green `#22C55E` background flash, **✓** (Check Icon) on the right, **white text** + **Success Haptic**
  - Auto-transitions to the next question after **1.2 seconds**.
- When **incorrect**: that button flashes tinted red `#EF4444` background, **✗** (X Icon) on the right, **white text** + **Error Haptic**. Simultaneously the correct answer auto-highlights green + ✓ icon.
  - Auto-transitions to the next question after **2.5 seconds** (to allow reading the correct answer), OR user can tap anywhere to continue immediately.

---

## Screen 5 — Session Result

**Layout**: Full screen, centered content

**Score ring**: large circle (~200dp diameter)
- Thin track `#1E293B` color
- Indigo fill, animates (Spring) to fill according to correct % upon entering the screen
- Inside ring: `8/10` text — large Bold number + smaller /10

**Motivational message** based on %:
- ≥ 80%: "Excellent! (Party Vector Icon)"
- 50–79%: "Good job! (Muscle Vector Icon)"
- < 50%: "Keep it up! (Sprout Vector Icon)"

**Stats row**: `(Check Icon) Correct: 8` green text — `(X Icon) Incorrect: 2` red text (horizontally spaced)

**2 buttons** aligned horizontally:
- `Review Again` — outlined, indigo — resets queue with incorrectly answered cards
- `Done` — filled indigo — returns to Deck Detail

---

## Screen 6 — Stats

**Layout**: Scaffold + ScrollView, with bottom nav

**Header**: "Stats" title

**Streak Card** (first card, prominent):
- **Very subtle** gradient background: 2 close shades of indigo (`#3730A3` → `#4F46E5`), avoids high-contrast gradients
- Large Flame Vector Icon + number of days "7 day streak"
- Subtext: "Study today to keep your streak!"

**Bar Chart** (last 7 days):
- Title: "Cards studied in 7 days"
- Indigo bars, height proportional to the number of cards
- X-axis: Mon Tue Wed Thu Fri Sat Sun (or short dates)
- Today's bar: brighter / with border

**Donut Chart** (Rating distribution):
- Title: "Rating distribution"
- 3 segments: Easy (green) / OK (yellow) / Hard (red)
- Legend below: color + % + label
- Total reviews displayed large in the center of the donut

**Summary Row**:
- 2 horizontal tiles: "Total decks: 5" | "Total cards: 180"

---

## Screen 7 — Settings

**Layout**: Simple settings list, no complex bottom padding. Min height `48dp` for all items.

**Sections**:

**Appearance**:
- `Theme` — trailing: chip selector for Light / Dark / System (small segment control with Vector Icons)

**Information**:
- `Version` — trailing: "1.0.0"
- `Feedback / Report a bug` — trailing: arrow icon →
- `About ZenFlashCards` — trailing: arrow icon →

> Section header: small gray Label text, uppercase, no distinct background

---

## Empty States & Edge Cases

| Scenario | UI |
|-----------|-----|
| Deck has no cards | Illustration (Vector) + "No cards yet. Add manually or import CSV" |
| No cards due today | Deck Detail: "(Party Icon) You've finished reviewing for today!" + "Review all" button |
| Quiz needs at least 4 cards | Alert: "Need at least 4 cards to start a quiz" |
| CSV import error | Red snackbar: "Invalid file format — needs 2 columns for front, back" + **Error Haptic** |
| File picker bytes null | (internal handling, user doesn't see — fallback to reading bytes) |
