# 🎨 ZenFlashCards — UI/UX Design Brief

> Tài liệu mô tả ý tưởng thiết kế để dùng làm prompt cho Stitch.

---

## Tinh thần thiết kế (Design Vision)

**Zen** — tối giản, yên tĩnh, không gây phân tâm. Người dùng mở app để học, không phải để thưởng thức animation. Mọi thứ phải nhanh, rõ, dễ chạm. Cảm giác tổng thể: *dark, calm, focused* — như ngồi trong phòng tối với một cuốn sách và ánh đèn nhỏ.

---

## Design System

### Màu sắc

| Vai trò | Màu | Hex |
|---------|-----|-----|
| Background chính | Navy rất tối | `#0F172A` |
| Surface (card, bottom bar) | Navy tối hơn chút | `#1E293B` |
| Accent / Primary | Indigo | `#4F46E5` |
| Accent sáng (dark mode) | Indigo nhạt | `#818CF8` |
| Text chính | Trắng | `#F8FAFC` |
| Text phụ | Xám xanh | `#94A3B8` |
| Text Caption | Xám sáng hơn (pass WCAG AA thoải mái hơn ở 11sp) | `#A0AEC0` |
| Đường kẻ / divider | `#2D3748` | |
| **Khó** (rating) | Đỏ | `#EF4444` |
| **OK** (rating) | Vàng cam | `#F59E0B` |
| **Dễ** (rating) | Xanh lá | `#22C55E` |
| Streak / fire | Cam | `#F97316` |

> Light mode: background `#F8FAFC`, surface `#FFFFFF`, text `#0F172A`, accent giữ nguyên Indigo `#4F46E5`.

### Typography — Inter

| Style | Size | Weight | Dùng cho |
|-------|------|--------|----------|
| Display | 32sp | 700 Bold | Từ vựng mặt trước flashcard |
| Headline | 20sp | 600 SemiBold | Tên deck, title màn hình |
| Title | 16sp | 600 SemiBold | Tên card trong list |
| Body | 14sp | 400 Regular | Mô tả, subtitle |
| Label | 12sp | 500 Medium | Tag ngôn ngữ, badge |
| Caption | 11sp | 400 Regular | Metadata nhỏ (số card) — dùng `#A0AEC0` thay vì `#94A3B8` để đảm bảo contrast ở cỡ chữ nhỏ |

### Hình dạng & khoảng cách

- Border radius: **16dp** cho card deck, **12dp** cho button, **8dp** cho list item
- Padding ngang màn hình: **20dp**
- Khoảng cách giữa các item: **12dp**
- Card elevation: shadow nhẹ `0 2px 8px rgba(0,0,0,0.3)`

### Micro-animations

- **Flip card**: xoay 3D theo trục Y, duration 400ms, curve `easeInOut`
- **Button tap**: scale nhẹ `0.95` trong 100ms
- **Screen transition**: slide từ phải, duration 300ms
- **Badge/score**: count-up animation khi Stats load
- **Quiz answer**: flash xanh (đúng) hoặc đỏ (sai) trong 300ms, không chuyển màn hình ngay

---

## Màn hình 1 — Home (Danh sách Deck)

**Layout**: Scaffold với TopAppBar + danh sách deck dạng list + FAB

**TopAppBar**:
- Title: "ZenFlashCards" — Inter SemiBold 20sp, màu trắng
- Bên phải: icon filter hoặc search (optional v2)
- Background: trong suốt, không có đường kẻ

**Body** — danh sách các DeckCard:
- Mỗi DeckCard là một `Card` với `borderRadius: 16dp`, background `#1E293B`
- **Trái**: tên deck (Headline, trắng), bên dưới là "🇬🇧 English → 🇻🇳 Tiếng Việt" (Label, xám), và "39 cards" (Caption, xám)
- **Phải**: badge tròn indigo, số **cards due today** ở giữa — chỉ hiện nếu > 0; nếu = 0 thì **hiện tick ✅ nhỏ màu xanh lá** (không ẩn badge — ẩn hẳn sẽ làm deck "đã học xong" trông y hệt deck chưa từng đụng tới, mất feedback tích cực)
- Long-press deck → context menu: Sửa / Xóa

**Empty state** (chưa có deck nào):
- Icon lớn 📚 hoặc minh hoạ đơn giản
- Text: "Chưa có bộ thẻ nào\nBấm + để tạo bộ thẻ đầu tiên"
- Màu xám, căn giữa

**FAB**: indigo tròn `+`, vị trí bottom-right, elevation thấp

**Bottom Navigation Bar**:
- 3 tab: 🏠 Home / 📊 Stats / ⚙️ Settings
- Icon active: indigo, filled
- Icon inactive: xám
- Không có label text (icon đủ rõ)

---

## Màn hình 2 — Deck Detail

**Layout**: Scaffold với TopAppBar cuộn ẩn + sticky action row + danh sách card + FAB

**TopAppBar**:
- Nút back ←
- Title: tên deck, Inter SemiBold
- Subtitle: "English → Vietnamese · 39 cards"
- 3 chấm menu: Sửa tên deck / Xoá deck

**Action Row** (sticky, không cuộn):
- 3 button nằm ngang, cùng chiều cao:
  - `Học ngay` — filled indigo, icon 📚
  - `Quiz` — outlined indigo, icon 🎯
  - `Import CSV` — text button, icon 📥, màu xám
- Nếu 0 cards due today: button "Học ngay" disable với text "Đã ôn xong hôm nay ✓"

**Danh sách Card** (cuộn):
- Mỗi item: row với front (bold) — dấu `→` — back (xám)
- Swipe phải → edit, swipe trái → delete (với confirm)
- Tap → xem chi tiết card (optional)
- Divider mỏng giữa các item

**FAB**: `+` để thêm card thủ công, indigo

---

## Màn hình 3 — Study / Flashcard Flip

**Layout**: Full screen, không có bottom nav. TopAppBar tối giản: nút X (thoát) bên trái, progress dạng text "3 / 12" bên phải.

**Progress bar** mỏng (4dp) ngay dưới AppBar, màu indigo, fill theo tiến độ.

**Vùng card** (chiếm 60% chiều cao màn hình):
- Card dùng surface tối `#1E293B`, `borderRadius: 24dp`, shadow `0 4px 16px rgba(0,0,0,0.4)`
- Text trên card màu trắng `#F8FAFC` — nhất quán với phần còn lại của app (không dùng card trắng để tránh phá vỡ tinh thần dark/calm)
- Khi chưa lật: chỉ hiện **từ mặt trước** — font Display 32sp, căn giữa. Tag nhỏ "ENGLISH" phía trên từ, màu `#94A3B8`
- Tap card → flip animation 3D → mặt sau hiện: **nghĩa** font Display 28sp + có thể thêm ví dụ câu nhỏ hơn bên dưới, màu `#CBD5E1`
- Corner hint nhỏ "Tap để lật 👆" lần đầu tiên (sau đó ẩn)

**Vùng đánh giá** (3 button luôn hiện, nhưng dim khi chưa lật):
- 3 button pill nằm ngang, chiều rộng bằng nhau:
  - `😅 Khó` — background `#EF4444` mờ, text đỏ
  - `😊 OK` — background `#F59E0B` mờ, text vàng
  - `😎 Dễ` — background `#22C55E` mờ, text xanh
- Tap một trong 3 → card biến mất (swipe lên nhẹ), card tiếp theo xuất hiện
- **Khi chưa lật card**: 3 button `opacity: 0.3`, `pointerEvents: none` — **mờ + disable, không ẩn hẳn** (ẩn sẽ làm layout nhảy giật khi card flip)

---

## Màn hình 4 — Quiz (Trắc nghiệm)

**Layout**: Không có bottom nav. AppBar: "Quiz", tiến độ "4/10" bên phải

**Progress bar** indigo mỏng ngay dưới AppBar

**Question card**: surface tối `#1E293B`, `borderRadius: 20dp` — nhất quán với DeckCard và flashcard (không dùng card trắng)
- Từ cần đoán: Headline 24sp bold, màu trắng `#F8FAFC`, căn giữa
- Tag nhỏ "Chọn nghĩa đúng" phía trên, màu `#94A3B8`

**4 lựa chọn** — stack dọc, mỗi button:
- `borderRadius: 12dp`, background `#1E293B`, border mỏng `#2D3748`
- Text Body 16sp, căn trái, padding 16dp, màu trắng
- Khi chọn **đúng**: background flash xanh `#22C55E` mờ, icon **✓** bên phải, text xanh
- Khi chọn **sai**: button đó flash đỏ `#EF4444` mờ, icon **✗** bên phải, text đỏ — đồng thời đáp án đúng tự highlight xanh + icon ✓ (hỗ trợ người mù màu: icon ✓/✗ là tín hiệu phụ ngoài màu sắc, nhất quán với emoji 😅/😊/😎 ở Study screen)
- Sau 1.2 giây → tự chuyển câu tiếp

---

## Màn hình 5 — Session Result (Kết quả buổi học)

**Layout**: Full screen, căn giữa nội dung

**Score ring**: vòng tròn lớn (~200dp diameter)
- Track mỏng màu `#1E293B`
- Fill màu indigo, animate fill theo % đúng khi vào màn hình
- Giữa ring: text `8/10` — số lớn Bold + /10 nhỏ hơn

**Message động lực** dựa vào %:
- ≥ 80%: "Tuyệt vời! 🎉"
- 50–79%: "Khá tốt! 💪"
- < 50%: "Cố lên nhé! 🌱"

**Stats row**: `✅ Đúng: 8` xanh — `❌ Sai: 2` đỏ (nằm ngang cách nhau)

**2 button** nằm ngang:
- `Học lại` — outlined, indigo — reset queue với các card đã sai
- `Xong` — filled indigo — về Deck Detail

---

## Màn hình 6 — Stats (Thống kê)

**Layout**: Scaffold + ScrollView, có bottom nav

**Header**: "Thống kê" title

**Streak Card** (card đầu tiên, nổi bật):
- Background gradient **rất nhẹ**: 2 sắc độ indigo gần nhau (`#3730A3` → `#4F46E5`), không dùng gradient tương phản cao — đây là điểm nhấn duy nhất trong app, chấp nhận được nhưng phải giữ subtle để không phá vỡ tinh thần flat/minimal
- Icon 🔥 lớn + số ngày "7 ngày liên tiếp"
- Subtext: "Học hôm nay để giữ streak!"

**Bar Chart** (7 ngày gần nhất):
- Title: "Cards học trong 7 ngày"
- Bar màu indigo, height tỉ lệ với số card
- X-axis: T2 T3 T4 T5 T6 T7 CN (hoặc ngày tháng ngắn)
- Bar hôm nay: sáng hơn / có viền

**Donut Chart** (Phân bố chất lượng):
- Title: "Phân bố đánh giá"
- 3 segment: Dễ (xanh) / OK (vàng) / Khó (đỏ)
- Legend bên dưới: màu + % + label
- Tổng reviews lớn ở giữa donut

**Summary Row**:
- 2 tile nằm ngang: "Tổng deck: 5" | "Tổng card: 180"

---

## Màn hình 7 — Settings

**Layout**: List settings đơn giản, không có bottom padding phức tạp

**Sections**:

**Giao diện**:
- `Chủ đề` — trailing: chip chọn ☀️ Sáng / 🌙 Tối / 🤖 Hệ thống (segment control nhỏ)

**Thông tin**:
- `Phiên bản` — trailing: "1.0.0"
- `Góp ý / Báo lỗi` — trailing: icon mũi tên →
- `About ZenFlashCards` — trailing: icon mũi tên →

> Section header: chữ nhỏ Label xám, uppercase, không có background khác biệt

---

## Empty States & Edge Cases

| Tình huống | UI |
|-----------|-----|
| Deck không có card | Illustration + "Chưa có thẻ nào. Thêm thủ công hoặc import CSV" |
| Không có card due today | Deck Detail: "🎉 Bạn đã ôn xong hôm nay!" + button "Xem lại tất cả" |
| Quiz cần ít nhất 4 card | Alert: "Cần ít nhất 4 thẻ để làm quiz" |
| Import CSV lỗi | Snackbar đỏ: "File không đúng định dạng — cần 2 cột front, back" |
| File picker bytes null | (xử lý nội bộ, user không thấy — đọc qua bytes fallback) |
