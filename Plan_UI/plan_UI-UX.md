# 🎨 ZenFlashCards — UI/UX Design Brief

> Document describing the design concept to be used as a prompt for Stitch.

---

## Design Vision

**Zen** — minimalist, quiet, distraction-free. Users open the app to study, not to enjoy animations. Everything must be fast, clear, and easy to touch. Overall feel: *dark, calm, focused* — like sitting in a dark room with a book and a small lamp.

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
| Secondary Text | Blue-gray | `#94A3B8` |
| Caption Text | Brighter gray (comfortably passes WCAG AA at 11sp) | `#A0AEC0` |
| Lines / dividers | `#2D3748` | |
| **Hard** (rating) | Red | `#EF4444` |
| **OK** (rating) | Yellow-orange | `#F59E0B` |
| **Easy** (rating) | Green | `#22C55E` |
| Streak / fire | Orange | `#F97316` |

> Light mode: background `#F8FAFC`, surface `#FFFFFF`, text `#0F172A`, accent remains Indigo `#4F46E5`.

### Typography — Inter

| Style | Size | Weight | Usage |
|-------|------|--------|----------|
| Display | 32sp | 700 Bold | Vocabulary on the front of the flashcard |
| Headline | 20sp | 600 SemiBold | Deck name, screen title |
| Title | 16sp | 600 SemiBold | Card name in the list |
| Body | 14sp | 400 Regular | Descriptions, subtitles |
| Label | 12sp | 500 Medium | Language tags, badges |
| Caption | 11sp | 400 Regular | Small metadata (card count) — uses `#A0AEC0` instead of `#94A3B8` to ensure contrast at small font sizes |

### Shapes & Spacing

- Border radius: **16dp** for deck cards, **12dp** for buttons, **8dp** for list items
- Horizontal screen padding: **20dp**
- Item spacing: **12dp**
- Card elevation: slight shadow `0 2px 8px rgba(0,0,0,0.3)`

### Micro-animations

- **Flip card**: 3D Y-axis rotation, 400ms duration, `easeInOut` curve
- **Button tap**: slight scale down to `0.95` over 100ms
- **Screen transition**: slide from right, 300ms duration
- **Badge/score**: count-up animation when Stats load
- **Quiz answer**: flash green (correct) or red (incorrect) for 300ms, does not transition screens immediately

---

## Screen 1 — Home (Deck List)

**Layout**: Scaffold with TopAppBar + list of decks + FAB

**TopAppBar**:
- Title: "ZenFlashCards" — Inter SemiBold 20sp, white color
- Right side: filter or search icon (optional v2)
- Background: transparent, no dividing lines

**Body** — list of DeckCards:
- Each DeckCard is a `Card` with `borderRadius: 16dp`, background `#1E293B`
- **Left**: deck name (Headline, white), below is "🇬🇧 English → 🇻🇳 Vietnamese" (Label, gray), and "39 cards" (Caption, gray)
- **Right**: indigo circular badge, number of **cards due today** in the middle — only displayed if > 0; if = 0, **display a small green tick ✅** (do not hide the badge — hiding it completely makes a "completed" deck look exactly like an untouched deck, losing positive feedback)
- Long-press deck → context menu: Edit / Delete

**Empty state** (no decks yet):
- Large 📚 icon or simple illustration
- Text: "No decks available\nTap + to create your first deck"
- Gray color, centered

**FAB**: round indigo `+`, bottom-right position, low elevation

**Bottom Navigation Bar**:
- 3 tabs: 🏠 Home / 📊 Stats / ⚙️ Settings
- Active icon: indigo, filled
- Inactive icon: gray
- No text label (icons are clear enough)

---

## Screen 2 — Deck Detail

**Layout**: Scaffold with hide-on-scroll TopAppBar + sticky action row + card list + FAB

**TopAppBar**:
- Back button ←
- Title: deck name, Inter SemiBold
- Subtitle: "English → Vietnamese · 39 cards"
- 3-dot menu: Edit deck name / Delete deck

**Action Row** (sticky, non-scrolling):
- 3 horizontal buttons, equal height:
  - `Study Now` — filled indigo, 📚 icon
  - `Quiz` — outlined indigo, 🎯 icon
  - `Import CSV` — text button, 📥 icon, gray color
- If 0 cards due today: "Study Now" button is disabled with the text "Reviewed today ✓"

**Card List** (scrollable):
- Each item: row with front (bold) — `→` sign — back (gray)
- Swipe right → edit, swipe left → delete (with confirmation)
- Tap → view card details (optional)
- Thin divider between items

**FAB**: `+` to manually add a card, indigo

---

## Screen 3 — Study / Flashcard Flip

**Layout**: Full screen, no bottom nav. Minimalist TopAppBar: X (exit) button on the left, "3 / 12" progress text on the right.

Thin (4dp) indigo **Progress bar** right below AppBar, fills according to progress.

**Card Area** (occupies 60% of screen height):
- Card uses dark surface `#1E293B`, `borderRadius: 24dp`, shadow `0 4px 16px rgba(0,0,0,0.4)`
- Text on card is white `#F8FAFC` — consistent with the rest of the app (do not use white cards to avoid breaking the dark/calm vibe)
- Before flipping: only shows **front word** — 32sp Display font, centered. Small "ENGLISH" tag above the word, `#94A3B8` color
- Tap card → 3D flip animation → back shows: 28sp Display **meaning** + optional smaller example sentence below, `#CBD5E1` color
- Small corner hint "Tap to flip 👆" the first time (then hidden)

**Rating Area** (3 buttons always visible, but dimmed before flipping):
- 3 horizontal pill buttons, equal width:
  - `😅 Hard` — dim `#EF4444` background, red text
  - `😊 OK` — dim `#F59E0B` background, yellow text
  - `😎 Easy` — dim `#22C55E` background, green text
- Tap any of the 3 → card disappears (slight swipe up), next card appears
- **Before flipping card**: 3 buttons have `opacity: 0.3`, `pointerEvents: none` — **dimmed + disabled, not completely hidden** (hiding them causes the layout to jump when the card flips)

---

## Screen 4 — Quiz (Multiple Choice)

**Layout**: No bottom nav. AppBar: "Quiz", "4/10" progress on the right

Thin indigo **Progress bar** right below AppBar

**Question card**: dark surface `#1E293B`, `borderRadius: 20dp` — consistent with DeckCard and flashcards (do not use white cards)
- Word to guess: 24sp bold Headline, white color `#F8FAFC`, centered
- Small "Select the correct meaning" tag above, `#94A3B8` color

**4 choices** — vertical stack, each button:
- `borderRadius: 12dp`, background `#1E293B`, thin border `#2D3748`
- 16sp Body text, left-aligned, 16dp padding, white color
- When **correct**: dim green `#22C55E` background flash, **✓** icon on the right, green text
- When **incorrect**: that button flashes dim red `#EF4444`, **✗** icon on the right, red text — simultaneously the correct answer auto-highlights green + ✓ icon (color blindness support: ✓/✗ icons serve as secondary signals alongside color, consistent with the 😅/😊/😎 emojis on the Study screen)
- Auto-transitions to the next question after 1.2 seconds

---

## Screen 5 — Session Result

**Layout**: Full screen, centered content

**Score ring**: large circle (~200dp diameter)
- Thin track `#1E293B` color
- Indigo fill, animates to fill according to correct % upon entering the screen
- Inside ring: `8/10` text — large Bold number + smaller /10

**Motivational message** based on %:
- ≥ 80%: "Excellent! 🎉"
- 50–79%: "Good job! 💪"
- < 50%: "Keep it up! 🌱"

**Stats row**: `✅ Correct: 8` green — `❌ Incorrect: 2` red (horizontally spaced)

**2 buttons** aligned horizontally:
- `Review Again` — outlined, indigo — resets queue with incorrectly answered cards
- `Done` — filled indigo — returns to Deck Detail

---

## Screen 6 — Stats

**Layout**: Scaffold + ScrollView, with bottom nav

**Header**: "Stats" title

**Streak Card** (first card, prominent):
- **Very subtle** gradient background: 2 close shades of indigo (`#3730A3` → `#4F46E5`), avoids high-contrast gradients — this is the only highlight in the app, acceptable but must be kept subtle so as not to break the flat/minimal vibe
- Large 🔥 icon + number of days "7 day streak"
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

**Layout**: Simple settings list, no complex bottom padding

**Sections**:

**Appearance**:
- `Theme` — trailing: chip selector for ☀️ Light / 🌙 Dark / 🤖 System (small segment control)

**Information**:
- `Version` — trailing: "1.0.0"
- `Feedback / Report a bug` — trailing: arrow icon →
- `About ZenFlashCards` — trailing: arrow icon →

> Section header: small gray Label text, uppercase, no distinct background

---

## Empty States & Edge Cases

| Scenario | UI |
|-----------|-----|
| Deck has no cards | Illustration + "No cards yet. Add manually or import CSV" |
| No cards due today | Deck Detail: "🎉 You've finished reviewing for today!" + "Review all" button |
| Quiz needs at least 4 cards | Alert: "Need at least 4 cards to start a quiz" |
| CSV import error | Red snackbar: "Invalid file format — needs 2 columns for front, back" |
| File picker bytes null | (internal handling, user doesn't see — fallback to reading bytes) |
