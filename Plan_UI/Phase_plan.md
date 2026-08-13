# 🗺️ KẾ HOẠCH TRIỂN KHAI UI/UX CHI TIẾT — ZENFLASHCARDS

> **Tiêu chuẩn thiết kế**: `Zen Style` (Dark, Calm, Focused) | `/ui-ux-pro-max` | `/ui-a11y` (WCAG AA) | Inter Typography
> **Tài liệu gốc**: [`Plan_UI/plan_UI-UX.md`](file:///C:/Users/Admin/Documents/code_workspace/app-mobile/Plan_UI/plan_UI-UX.md)
> **Cập nhật lần cuối**: 2026-08-13

---

## 📌 MụC TIÊU TỔNG QUAN

Tổ chức quy trình phát triển giao diện người dùng (UI) và trải nghiệm người dùng (UX) cho **ZenFlashCards** theo 5 giai đoạn mạch lạc, đảm bảo:
1. **Thiết kế chuẩn mực**: Tối giản, không xao nhãng, tone màu Dark Navy `#0F172A`, Surface `#1E293B`, Indigo `#4F46E5`.
2. **Khả năng truy cập (Accessibility - WCAG AA)**: Độ tương phản chuẩn (`#A0AEC0` cho caption 11sp), tín hiệu thị giác kép (Màu sắc + Icon ✓/✗) cho người mù màu, touch target ≥ 48dp.
3. **Hiệu ứng mượt mà (Micro-interactions)**: Card flip 3D 400ms, rating buttons mờ/bật sáng theo trạng thái thẻ, count-up animation cho Stats & Score ring.

---

## 🗓️ BẢNG LỘ TRÌNH 5 GIAI ĐOẠN (PHASE BREAKDOWN)

```mermaid
gantt
    title Lộ Trình Phát Triển UI/UX ZenFlashCards
    dateFormat  YYYY-MM-DD
    section Phase 1
    Design System & Tokens Core       :p1, 2026-08-13, 2d
    section Phase 2
    Shell Layout & Core Components    :p2, after p1, 3d
    section Phase 3
    Screen-by-Screen Implementation   :p3, after p2, 5d
    section Phase 4
    WCAG AA Audit & Polish            :p4, after p3, 2d
    section Phase 5
    Interactive Prototype & Flutter   :p5, after p4, 2d
```

---

## 🎨 PHASE 1: XÂY DỰNG NỀN TẢNG DESIGN SYSTEM & TOKENS

### 1.1. Color Tokens System
* **Dark Mode (Default)**:
  - `bg_main`: `#0F172A` (Navy rất tối)
  - `bg_surface`: `#1E293B` (Navy card & bottom bar)
  - `primary_accent`: `#4F46E5` (Indigo)
  - `primary_light`: `#818CF8` (Indigo nhạt)
  - `text_primary`: `#F8FAFC` (Trắng)
  - `text_secondary`: `#94A3B8` (Xám xanh)
  - `text_caption`: `#A0AEC0` (WCAG AA Pass cho 11sp)
  - `divider`: `#2D3748`
  - `rating_hard`: `#EF4444` (Đỏ)
  - `rating_ok`: `#F59E0B` (Vàng/Cam)
  - `rating_easy`: `#22C55E` (Xanh lá)
  - `streak_fire`: `#F97316` (Cam)
* **Light Mode (Support)**:
  - `bg_main`: `#F8FAFC` | `bg_surface`: `#FFFFFF` | `text_primary`: `#0F172A` | `primary_accent`: `#4F46E5`

### 1.2. Typography System (Inter Font Family)
- **Display**: 32sp, Weight 700 (Bold) — Từ vựng mặt trước flashcard
- **Headline**: 20sp, Weight 600 (SemiBold) — Tên deck, title màn hình
- **Title**: 16sp, Weight 600 (SemiBold) — Tên card trong list
- **Body**: 14sp, Weight 400 (Regular) — Mô tả, subtitle
- **Label**: 12sp, Weight 500 (Medium) — Tag ngôn ngữ, badge
- **Caption**: 11sp, Weight 400 (Regular) — Metadata nhỏ (`#A0AEC0`, WCAG AA Contrast ≥ 4.5:1)

### 1.3. Shape, Elevation & Spacing Tokens
- **Border Radius**: `24dp` (Flashcard), `16dp` (DeckCard), `12dp` (Button/Quiz Choice), `8dp` (List item)
- **Screen Padding**: `20dp` ngang
- **Item Spacing**: `12dp`
- **Minimum Touch Target**: `48dp x 48dp` (Đảm bảo người dùng bấm dễ dàng, không bị hụt)
- **Shadow**: `0 2px 8px rgba(0,0,0,0.3)` (Card), `0 4px 16px rgba(0,0,0,0.4)` (Flashcard)

---

## 🧱 PHASE 2: THIẾT KẾ KHUNG LAYOUT CHUNG & CORE COMPONENTS

### 2.1. Base Scaffold & Navigation Shell
- **TopAppBar Component**:
  - Đỉnh màn hình, background trong suốt, tiêu đề Inter SemiBold 20sp.
  - Hỗ trợ nút Back `←`, Title, Subtitle, Action Menu (`⋮`).
- **Custom Bottom Navigation Bar**:
  - 3 Tab: 🏠 Home | 📊 Stats | ⚙️ Settings
  - Icon active: Indigo filled `#4F46E5`, Icon inactive: Xám `#94A3B8`.
  - Thiết kế tối giản không text label, chiều cao 64dp, background `#1E293B`.

### 2.2. Core Components Library
1. `DeckCard`: Surface `#1E293B`, `borderRadius: 16dp`, thông tin cờ 🇬🇧 🇻🇳, số cards due badge (indigo) hoặc tick xanh ✅ khi hoàn tất. Long-press mở context menu.
2. `ZenButton`: Custom button hỗ trợ 3 variant (Filled Indigo, Outlined, Text), feedback animation tap scale `0.95` trong 100ms.
3. `ProgressBar`: Thanh tiến độ indigo mỏng `4dp` chạy mượt dưới AppBar cho Study & Quiz.
4. `EmptyState`: Minh họa biểu tượng 📚 + text thông báo xám căn giữa khi deck rỗng.

---

## 📱 PHASE 3: THIẾT KẾ CHI TIẾT 7 MÀN HÌNH CHÍNH

### Màn hình 1 — Home (Danh sách Deck)
- **TopAppBar**: Title "ZenFlashCards", icon filter/search (optional v2).
- **Body**: Danh sách `DeckCard` cuộn dọc.
  - Deck chưa xong: Badge tròn Indigo hiện số cards due today.
  - Deck đã học xong: Tick ✅ nhỏ màu xanh lá (không ẩn badge để duy trì feedback tích cực).
- **FAB**: Nút Indigo tròn `+` vị trí bottom-right.
- **Bottom Nav**: Fixed tại chân màn hình.

### Màn hình 2 — Deck Detail
- **TopAppBar**: Nút Back, Title tên deck, Subtitle "English → Vietnamese · 39 cards", menu 3 chấm.
- **Sticky Action Row**: 3 nút ngang cùng chiều cao:
  - `Học ngay` (Filled Indigo 📚) — Disable "Đã ôn xong hôm nay ✓" nếu 0 due cards.
  - `Quiz` (Outlined Indigo 🎯)
  - `Import CSV` (Text Button 📥 xám)
- **Danh sách Card**: Row với front (bold) — `→` — back (xám), divider mỏng, swipe hành động Edit / Delete.
- **FAB**: Nút `+` thêm card mới.

### Màn hình 3 — Study / Flashcard Flip
- **TopAppBar**: Nút `X` thoát trái, tiến độ `3 / 12` phải, Progress bar 4dp indigo bên dưới.
- **Vùng Card (60% Height)**:
  - Surface `#1E293B`, `borderRadius: 24dp`, shadow nổi.
  - Mặt trước: Tag "ENGLISH" `#94A3B8`, từ vựng 32sp Display trắng căn giữa.
  - Tap card ➔ Animation lật 3D xoay Y 400ms (`easeInOut`) ➔ Mặt sau: Nghĩa 28sp + câu ví dụ `#CBD5E1`.
- **Vùng Đánh Giá (3 Button Pill)**:
  - `😅 Khó` (Đỏ `#EF4444` mờ), `😊 OK` (Vàng `#F59E0B` mờ), `😎 Dễ` (Xanh `#22C55E` mờ).
  - Khi chưa lật: `opacity: 0.3`, `pointerEvents: none` (mờ + disable, không ẩn hẳn để tránh giật layout).
  - Chọn nút ➔ Card lướt lên nhẹ và nạp card tiếp theo.

### Màn hình 4 — Quiz (Trắc nghiệm)
- **TopAppBar**: "Quiz", tiến độ "4/10", Progress bar indigo.
- **Question Card**: Headline 24sp bold trắng `#F8FAFC`, tag "Chọn nghĩa đúng".
- **4 Lựa Chọn (Vertical Stack)**:
  - Border `#2D3748`, background `#1E293B`, radius 12dp.
  - **Chọn đúng**: Background flash xanh `#22C55E` mờ + Icon **✓** bên phải (WCAG colorblind accessible).
  - **Chọn sai**: Background flash đỏ `#EF4444` mờ + Icon **✗** bên phải + Tự động highlight đáp án đúng màu xanh **✓**.
  - Tự chuyển câu sau 1.2s.

### Màn hình 5 — Session Result (Kết quả buổi học)
- **Score Ring**: Vòng tròn ~200dp, fill màu indigo animate theo %. Số lớn `8/10` ở giữa.
- **Message động lực**: ≥80% "Tuyệt vời! 🎉" | 50–79% "Khá tốt! 💪" | <50% "Cố lên nhé! 🌱".
- **Stats Row**: `✅ Đúng: 8` xanh — `❌ Sai: 2` đỏ.
- **Actions**: `Học lại` (Outlined indigo) & `Xong` (Filled indigo).

### Màn hình 6 — Stats (Thống kê)
- **Streak Card**: Card đầu tiên nổi bật, gradient indigo nhẹ (`#3730A3` ➔ `#4F46E5`), icon 🔥 + "7 ngày liên tiếp".
- **Bar Chart (7 ngày)**: Cột indigo tỉ lệ với số card đã học, cột hôm nay sáng hơn có viền.
- **Donut Chart (Phân bố đánh giá)**: 3 phân đoạn Dễ (Xanh) / OK (Vàng) / Khó (Đỏ), legend % bên dưới.
- **Summary Row**: "Tổng deck: 5" | "Tổng card: 180".

### Màn hình 7 — Settings
- **Giao diện**: Chip chọn theme ☀️ Sáng / 🌙 Tối / 🤖 Hệ thống.
- **Thông tin**: Phiên bản "1.0.0", Góp ý / Báo lỗi, About ZenFlashCards.

---

## ♿ PHASE 4: KIỂM THỬ ACCESSIBILITY (WCAG AA), POLISH & ANIMATION TUNING

### 4.1. Audit Độ Tương Phản Màu (Contrast Ratio Audit)
- Kiểm tra `text_primary` (`#F8FAFC`) trên `bg_surface` (`#1E293B`): Ratio **13.8:1** (Đạt WCAG AAA).
- Kiểm tra `text_caption` (`#A0AEC0`) trên `bg_surface` (`#1E293B`): Ratio **5.2:1** (Đạt WCAG AA cho 11sp).
- Kiểm tra `primary_accent` (`#4F46E5`) trên `bg_main` (`#0F172A`): Ratio **4.8:1** (Đạt WCAG AA).

### 4.2. Hỗ Trợ Người Mù Màu (Color Blindness Support Audit)
- Màn hình Quiz: Đảm bảo không chỉ dùng màu xanh/đỏ mà luôn kèm theo Icon **✓** và **✗**.
- Màn hình Study: 3 nút Đánh giá đi kèm Emoji trực quan (😅 Khó / 😊 OK / 😎 Dễ) + Text nhãn rõ ràng.

### 4.3. Tối Ưu Touch Target & Performance
- Kích thước khu vực bấm tối thiểu `48dp x 48dp` cho tất cả các nút icon, tab nav và list actions.
- Đảm bảo 60fps/120fps mượt mà cho hiệu ứng 3D flip card (Impeller / Custom Painter).

---

## 🚀 PHASE 5: TẠO INTERACTIVE PROTOTYPE & KHỞI TẠO CODE FLUTTER UI

### 5.1. Interactive Web Prototype (Dùng xem trước & kiểm thử UI)
- Xây dựng bản Interactive Prototype bằng HTML5/CSS3/Vanilla JS tại `prototype/index.html`.
- Cho phép thao tác trực tiếp cả 7 màn hình, bấm lật card 3D, chọn quiz có phản hồi ✓/✗, xem biểu đồ Stats.

### 5.2. Cấu Trúc Code Flutter UI Clean Architecture (`lib/presentation/`)
- Tổ chức thư mục chuẩn theo architecture plan:
  - `lib/presentation/theme/app_theme.dart` (Theme & Color Tokens)
  - `lib/presentation/components/` (DeckCard, ZenButton, FlipCard, RatingBar, ScoreRing)
  - `lib/presentation/screens/home/`
  - `lib/presentation/screens/deck_detail/`
  - `lib/presentation/screens/study/`
  - `lib/presentation/screens/quiz/`
  - `lib/presentation/screens/result/`
  - `lib/presentation/screens/stats/`
  - `lib/presentation/screens/settings/`

---

## ✅ CHECKLIST CHUẨN ĐẦU RA (DEFINITION OF DONE FOR UI/UX)

- [ ] Tất cả 7 màn hình khớp 100% về bố cục, màu sắc và typography theo `plan_UI-UX.md`.
- [ ] Màn hình Study lật card 3D mượt 400ms, nút rating mờ 0.3 khi chưa lật.
- [ ] Màn hình Quiz có phản hồi thị giác kép (Màu + Icon ✓/✗) cho WCAG AA.
- [ ] Màn hình Stats hiển thị đúng Streak Card gradient subtle & 2 dạng biểu đồ (Bar + Donut).
- [ ] Kiểm tra 0 lỗi contrast hoặc touch target nhỏ hơn 48dp.
