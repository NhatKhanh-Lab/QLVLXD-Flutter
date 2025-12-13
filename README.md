# Ứng dụng Quản lý Vật liệu Xây dựng

Ứng dụng Flutter để quản lý và bán vật liệu xây dựng cho cửa hàng/siêu thị. Ứng dụng hỗ trợ hoạt động offline và có thể đồng bộ với Firebase (tùy chọn).

## ✨ Tính năng chính

### 📦 Quản lý sản phẩm
- Danh sách sản phẩm với hình ảnh, giá, số lượng tồn
- Thêm/Sửa/Xóa sản phẩm
- Lọc theo danh mục (Xi măng, Sắt thép, Gạch, Sơn, ...)
- Tìm kiếm sản phẩm nhanh
- Chụp/Chọn ảnh sản phẩm từ camera hoặc thư viện
- Cảnh báo tồn kho thấp

### 📊 Quản lý kho
- Hiển thị số lượng tồn kho
- Cảnh báo khi tồn kho thấp
- Thống kê tồn kho theo danh mục
- Biểu đồ tồn kho (Pie Chart)

### 🧾 Quản lý hóa đơn
- Tạo hóa đơn bán hàng nhanh
- Chọn sản phẩm và số lượng
- Tính tổng tiền + VAT (có thể điều chỉnh)
- Xuất PDF hóa đơn
- Lưu lịch sử hóa đơn
- Tự động cập nhật tồn kho khi bán

### 📈 Thống kê
- Dashboard tổng quan
- Biểu đồ tồn kho theo danh mục
- Biểu đồ doanh thu theo ngày
- Top sản phẩm bán chạy
- Thống kê theo danh mục

### ⚙️ Cài đặt & Đồng bộ
- Sao lưu dữ liệu ra file JSON
- Khôi phục dữ liệu từ backup
- Đồng bộ với Firebase (tùy chọn)
- Hoạt động hoàn toàn offline

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.10.0

### Cài đặt

1. **Clone repository và cài đặt dependencies:**
```bash
flutter pub get
```

2. **Tạo thư mục assets:**
```bash
mkdir -p assets/images
```

3. **Generate Hive Adapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Chạy ứng dụng:**
```bash
flutter run
```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                      # Entry point
├── models/                        # Data models
│   ├── product.dart              # Model sản phẩm
│   ├── invoice.dart              # Model hóa đơn
│   └── invoice_item.dart         # Model chi tiết hóa đơn
├── screens/                       # UI Screens
│   ├── home_screen.dart          # Màn hình chính (Dashboard)
│   ├── product_list_screen.dart  # Danh sách sản phẩm
│   ├── add_edit_product_screen.dart  # Thêm/Sửa sản phẩm
│   ├── invoice_screen.dart       # Tạo hóa đơn
│   ├── statistics_screen.dart    # Thống kê
│   └── settings_screen.dart      # Cài đặt
├── widgets/                       # Reusable widgets
│   ├── product_card.dart         # Card hiển thị sản phẩm
│   ├── invoice_item_widget.dart  # Widget chi tiết hóa đơn
│   └── chart_widget.dart         # Widget biểu đồ
├── services/                      # Business logic
│   ├── db_service.dart           # Hive database service
│   ├── pdf_service.dart          # PDF generation service
│   └── firebase_service.dart     # Firebase sync (optional)
└── providers/                     # State management
    ├── product_provider.dart      # Product state management
    └── invoice_provider.dart      # Invoice state management
```

## 📦 Dependencies chính

- **hive** / **hive_flutter**: Database offline
- **provider**: State management
- **image_picker**: Chọn/chụp ảnh
- **fl_chart**: Biểu đồ
- **pdf** / **printing**: Xuất PDF hóa đơn
- **firebase_core** / **cloud_firestore**: Đồng bộ Firebase (tùy chọn)
- **intl**: Format số, ngày tháng
- **uuid**: Tạo ID duy nhất

## 🔧 Cấu hình Firebase (Tùy chọn)

Nếu muốn sử dụng tính năng đồng bộ Firebase:

1. Tạo project tại [Firebase Console](https://console.firebase.google.com)
2. Thêm file cấu hình:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
3. Uncomment các dòng Firebase trong code nếu cần

**Lưu ý:** Ứng dụng hoạt động hoàn toàn offline, Firebase chỉ cần thiết nếu muốn đồng bộ đa thiết bị.

## 📱 Màn hình chính

### Home Screen (Dashboard)
- Tổng số sản phẩm
- Số sản phẩm tồn kho thấp
- Doanh thu hôm nay
- Tổng doanh thu
- Cảnh báo tồn kho thấp
- Thao tác nhanh

### Product List
- Grid/List view
- Tìm kiếm
- Lọc theo danh mục
- Thêm/Sửa/Xóa sản phẩm

### Invoice Screen
- Tạo hóa đơn mới
- Chọn sản phẩm và số lượng
- Thông tin khách hàng
- Tính VAT
- Xuất PDF

### Statistics Screen
- Biểu đồ tồn kho
- Biểu đồ doanh thu
- Top sản phẩm bán chạy
- Thống kê theo danh mục

### Settings Screen
- Sao lưu/Khôi phục dữ liệu
- Đồng bộ Firebase
- Xóa dữ liệu

## 🎨 UI/UX

- Material Design 3
- Giao diện hiện đại, trực quan
- Hỗ trợ dark mode (theo hệ thống)
- Animation mượt mà
- Responsive design

## 💾 Lưu trữ dữ liệu

- **Local**: Hive database (offline-first)
- **Cloud**: Firebase Firestore (tùy chọn)
- **Backup**: File JSON

## 🔒 Bảo mật

- Dữ liệu lưu local, không cần internet
- Firebase có thể cấu hình rules để bảo vệ dữ liệu
- Backup file có thể mã hóa nếu cần

## 📝 License

Dự án này được tạo cho mục đích học tập và thương mại.

## 👨‍💻 Phát triển

Để phát triển thêm tính năng:

1. Thêm model mới trong `lib/models/`
2. Tạo provider trong `lib/providers/` nếu cần
3. Tạo service trong `lib/services/` cho business logic
4. Tạo screen trong `lib/screens/` cho UI
5. Tạo widget tái sử dụng trong `lib/widgets/`

## 🐛 Xử lý lỗi

Nếu gặp lỗi khi generate Hive adapters:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📞 Hỗ trợ

Nếu có vấn đề, vui lòng tạo issue trên repository.

---

**Chúc bạn sử dụng ứng dụng hiệu quả! 🎉**
