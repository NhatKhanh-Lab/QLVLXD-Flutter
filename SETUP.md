# Hướng dẫn thiết lập dự án

## Bước 1: Cài đặt dependencies

```bash
flutter pub get
```

## Bước 2: Tạo thư mục assets (nếu chưa có)

```bash
mkdir -p assets/images
```

## Bước 3: Generate Hive Adapters

Chạy lệnh sau để tạo các file adapter cho Hive:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ tạo các file:
- `lib/models/product.g.dart`
- `lib/models/invoice_item.g.dart`
- `lib/models/invoice.g.dart`

## Bước 4: Cấu hình Firebase (Tùy chọn)

Nếu bạn muốn sử dụng Firebase để đồng bộ dữ liệu:

1. Tạo project Firebase tại https://console.firebase.google.com
2. Thêm file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
3. Uncomment các dòng Firebase trong code nếu cần

**Lưu ý:** Ứng dụng có thể chạy hoàn toàn offline mà không cần Firebase.

## Bước 5: Chạy ứng dụng

```bash
flutter run
```

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── product.dart
│   ├── invoice.dart
│   └── invoice_item.dart
├── screens/                  # UI Screens
│   ├── home_screen.dart
│   ├── product_list_screen.dart
│   ├── add_edit_product_screen.dart
│   ├── invoice_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── product_card.dart
│   ├── invoice_item_widget.dart
│   └── chart_widget.dart
├── services/                 # Business logic
│   ├── db_service.dart       # Hive database
│   ├── pdf_service.dart       # PDF generation
│   └── firebase_service.dart # Firebase sync (optional)
└── providers/                # State management
    ├── product_provider.dart
    └── invoice_provider.dart
```

## Tính năng chính

✅ Quản lý sản phẩm (CRUD)
✅ Quản lý kho (tồn kho, cảnh báo)
✅ Tạo hóa đơn bán hàng
✅ Xuất PDF hóa đơn
✅ Thống kê và biểu đồ
✅ Sao lưu/Khôi phục dữ liệu
✅ Đồng bộ Firebase (tùy chọn)
✅ Hoạt động offline

## Lưu ý

- Dữ liệu được lưu local bằng Hive, không cần internet
- Firebase chỉ cần thiết nếu muốn đồng bộ đa thiết bị
- Ảnh sản phẩm có thể lưu local hoặc URL

