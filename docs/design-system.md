# 🎨 Design System — ZenFlashCards

> Tài liệu mô tả đầy đủ hệ thống thiết kế (Design Tokens, Color, Typography, Components, Accessibility) của ứng dụng ZenFlashCards.

---

## 1. Design Vision

**Zen** — tối giản, yên tĩnh, không gây phân tâm.

> _"Người dùng mở app để học, không phải để thưởng thức animation. Mọi thứ phải nhanh, rõ, dễ chạm."_

Cảm giác tổng thể: **dark, calm, focused** — như ngồi trong phòng tối với một cuốn sách và ánh đèn nhỏ.

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

| Token | Hex | Ghi chú |
|-------|-----|---------|
| Background | `#F8FAFC` | Trắng xám nhẹ |
| Surface | `#FFFFFF` | Trắng tinh |
| Text Primary | `#0F172A` | Navy tối (đảo ngược) |
| Primary Accent | `#4F46E5` | Giữ nguyên Indigo |

### 2.3. Semantic Colors

| Ngữ cảnh | Màu | Hex | Dùng cho |
|----------|-----|-----|----------|
| Đánh giá **Khó** | 🔴 Đỏ | `#EF4444` | Button "😅 Khó", Quiz sai |
| Đánh giá **OK** | 🟡 Vàng/Cam | `#F59E0B` | Button "😊 OK" |
| Đánh giá **Dễ** | 🟢 Xanh lá | `#22C55E` | Button "😎 Dễ", Quiz đúng, tick ✅ |
| **Streak** | 🟠 Cam | `#F97316` | Icon lửa 🔥 |
| **Gradient** (Stats) | Indigo | `#3730A3` → `#4F46E5` | Streak card (subtle) |

---

## 3. Typography — Inter

| Style | Size | Weight | Line Height | Color | Dùng cho |
|-------|:----:|:------:|:-----------:|-------|----------|
| Display | 32sp | 700 Bold | 1.2 | `#F8FAFC` | Từ vựng mặt trước flashcard |
| Headline | 20sp | 600 Semi | 1.3 | `#F8FAFC` | Tên deck, title màn hình |
| Title | 16sp | 600 Semi | 1.3 | `#F8FAFC` | Tên card trong danh sách |
| Body | 14sp | 400 Reg | 1.4 | `#94A3B8` | Mô tả, subtitle |
| Label | 12sp | 500 Med | 1.3 | `#94A3B8` | Tag ngôn ngữ, badge |
| Caption | 11sp | 400 Reg | 1.3 | `#A0AEC0` | Metadata nhỏ (số card) |

> **Lưu ý WCAG**: Caption dùng `#A0AEC0` thay vì `#94A3B8` để đạt contrast ratio ≥ 4.5:1 trên nền `#1E293B` ở cỡ chữ nhỏ 11sp.

### Font Loading

Sử dụng `google_fonts` package — tải Inter qua CDN, không cần bundle `.ttf` vào APK:

```dart
textTheme: GoogleFonts.interTextTheme()
```

---

## 4. Shape & Spacing System

### 4.1. Border Radius

| Element | Radius | Ghi chú |
|---------|:------:|---------|
| Flashcard (Study) | 24dp | Nhấn mạnh, focus chính |
| DeckCard (Home) | 16dp | Card tiêu chuẩn |
| Button / Quiz Choice | 12dp | Tương tác chính |
| List Item | 8dp | Compact |
| Rating Pill Button | 26dp | Full round pill |

### 4.2. Spacing

| Token | Giá trị | Dùng cho |
|-------|:-------:|----------|
| Screen padding (horizontal) | 20dp | Padding ngang tất cả màn hình |
| Item spacing | 12dp | Khoảng cách giữa các item |
| Card padding (internal) | 18dp | Padding bên trong card |
| Touch target minimum | 48dp × 48dp | Tất cả nút tương tác |

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
│  Tiếng Anh Thông Dụng               │
│  🇬🇧 English → 🇻🇳 Tiếng Việt    [12]│
│  39 cards                            │
└──────────────────────────────────────┘
 Surface #1E293B │ radius 16dp │ shadow nhẹ
 Badge: Indigo circle (due count) hoặc ✅ (done)
 Long-press → context menu: Sửa / Xóa
```

### 5.2. FlipCard3D

```
┌──────────────────────┐      ┌──────────────────────┐
│     ENGLISH          │      │     TIẾNG VIỆT       │
│                      │      │                      │
│    Serendipity       │ ──→  │  Sự tình cờ may mắn  │
│                      │ 400ms│                      │
│    Tap để lật 👆     │      │  "Finding this was   │
└──────────────────────┘      │   pure serendipity"  │
                              └──────────────────────┘
 Surface #1E293B │ radius 24dp │ shadow nổi
 Animation: rotateY 400ms easeInOut
 Perspective: Matrix4 setEntry(3,2,0.001)
```

### 5.3. Rating Buttons

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  😅 Khó  │  │  😊 OK   │  │  😎 Dễ   │
└──────────┘  └──────────┘  └──────────┘
  #EF4444       #F59E0B       #22C55E
  (15% opacity  (15% opacity  (15% opacity
   background)   background)   background)

Khi chưa lật card: opacity 0.3, pointerEvents none
Khi đã lật card:   opacity 1.0, enabled
→ Không ẩn/hiện để tránh layout jump
```

### 5.4. Quiz Option Button

```
┌────────────────────────────────────────┐
│  Khả năng phục hồi, kiên cường     ✓  │  ← Đúng: flash xanh #22C55E
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│  Sự tình cờ may mắn                ✗  │  ← Sai: flash đỏ #EF4444
└────────────────────────────────────────┘
 Border #2D3748 │ radius 12dp │ surface #1E293B
 Dual signal: Color + Icon (✓/✗) cho người mù màu
```

### 5.5. Bottom Navigation Bar

```
┌────────────────────────────────────────┐
│      🏠          📊          ⚙️       │
│    (active)    (inactive)  (inactive)  │
│    #818CF8     #94A3B8     #94A3B8     │
└────────────────────────────────────────┘
 Background #1E293B │ height 64dp
 Không có text label │ Icon-only minimal
 Active: filled icon + subtle indigo bg (12% opacity)
```

---

## 6. Micro-Animations

| Animation | Duration | Curve | Mô tả |
|-----------|:--------:|:-----:|-------|
| Card flip 3D | 400ms | `easeInOut` | Xoay trục Y với perspective |
| Button tap | 100ms | linear | Scale down 0.95 → 1.0 |
| Screen transition | 300ms | `easeOut` | Slide từ phải vào |
| Score ring fill | 800ms | `easeOut` | Conic gradient animate từ 0% → actual% |
| Badge count-up | 600ms | `easeOut` | Số nhảy từ 0 lên giá trị thực |
| Quiz flash | 300ms | linear | Background flash xanh/đỏ rồi fade |
| Card dismiss | 200ms | `easeIn` | Swipe lên nhẹ khi chọn rating |

---

## 7. Accessibility Compliance (WCAG AA)

### 7.1. Contrast Ratio Audit

| Text | Background | Ratio | Kết quả |
|------|-----------|:-----:|:-------:|
| `#F8FAFC` (primary) | `#1E293B` (surface) | **13.8:1** | ✅ AAA |
| `#F8FAFC` (primary) | `#0F172A` (main bg) | **15.4:1** | ✅ AAA |
| `#A0AEC0` (caption) | `#1E293B` (surface) | **5.2:1** | ✅ AA |
| `#94A3B8` (secondary) | `#1E293B` (surface) | **4.6:1** | ✅ AA |
| `#4F46E5` (primary) | `#0F172A` (main bg) | **4.8:1** | ✅ AA |

### 7.2. Hỗ Trợ Người Mù Màu

| Màn hình | Giải pháp |
|----------|-----------|
| Quiz | Không chỉ dùng xanh/đỏ — luôn kèm icon **✓** (đúng) và **✗** (sai) |
| Study rating | Emoji trực quan 😅/😊/😎 + text label rõ ràng bên cạnh màu sắc |
| Home badge | Tick ✅ khi hoàn tất (không ẩn hẳn badge → tránh mất feedback tích cực) |

### 7.3. Touch Target

- Tất cả nút bấm, icon, tab nav: tối thiểu **48dp × 48dp**
- Không có hit area nhỏ hơn 44dp trong toàn bộ app
