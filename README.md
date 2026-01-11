# GKNM PROJECT - QLVLXD

Ứng dụng Flutter quản lý và bán vật liệu xây dựng cho cửa hàng/siêu thị. Hệ thống hỗ trợ quản lý sản phẩm, tồn kho, hóa đơn bán hàng, khách hàng, nhà cung cấp và thống kê doanh thu với đồng bộ realtime qua Firebase.

## ✨ Tính năng chính

### 🔐 Xác thực và Phân quyền
- Đăng nhập bằng username/password hoặc email/password
- Phân quyền Admin và Nhân viên
- Admin: Toàn quyền quản lý hệ thống
- Nhân viên: Chỉ xem và tạo hóa đơn

### 📦 Quản lý Sản phẩm
- Danh sách sản phẩm với hình ảnh, giá, số lượng tồn
- Thêm/Sửa/Xóa sản phẩm
- Lọc theo danh mục (Xi măng, Sắt thép, Gạch, Sơn, ...)
- Tìm kiếm sản phẩm nhanh
- Chụp/Chọn ảnh sản phẩm từ camera hoặc thư viện
- Cảnh báo tồn kho thấp

### 📊 Quản lý Kho
- Hiển thị số lượng tồn kho realtime
- Cảnh báo khi tồn kho thấp
- Tự động cập nhật tồn kho khi bán hàng
- Tự động cập nhật tồn kho khi nhập hàng

### 🧾 Quản lý Hóa đơn
- Tạo hóa đơn bán hàng nhanh
- Chọn sản phẩm và số lượng
- Tính tổng tiền + VAT (10%, có thể điều chỉnh)
- **Chọn khách hàng từ danh sách đã lưu** (icon search)
- Tự động điền thông tin khách hàng
- **Tạo và in PDF hóa đơn** với font Unicode (tiếng Việt)
- Hiển thị thông tin khách hàng và nhân viên bán hàng trong PDF
- Lưu lịch sử hóa đơn
- Tự động cập nhật tồn kho khi bán
- **Tự động cập nhật tổng mua hàng của khách hàng**

### 👥 Quản lý Khách hàng
- Danh sách khách hàng với thông tin đầy đủ
- Thêm/Sửa/Xóa khách hàng
- Xem tổng mua hàng của từng khách hàng
- Tìm kiếm khách hàng
- Tích hợp với hóa đơn: Chọn khách hàng từ danh sách khi tạo hóa đơn

### 🏢 Quản lý Nhà cung cấp (Admin only)
- Danh sách nhà cung cấp
- Thêm/Sửa/Xóa nhà cung cấp
- Lịch sử nhập hàng từ nhà cung cấp

### 📋 Quản lý Đơn nhập hàng (Admin only)
- Tạo đơn nhập hàng
- Chọn nhà cung cấp
- Chọn sản phẩm và số lượng
- Xác nhận đơn nhập hàng
- Tự động cập nhật tồn kho khi xác nhận

### 👨‍💼 Quản lý Nhân viên (Admin only)
- Danh sách nhân viên
- Thêm/Sửa/Xóa nhân viên
- Phân quyền Admin/Nhân viên
- Kích hoạt/Vô hiệu hóa tài khoản
- Theo dõi nhân viên tạo hóa đơn

### 📈 Thống kê và Báo cáo
- Dashboard tổng quan với KPI cards
- Doanh thu hôm nay, tháng này
- Tổng giá trị tồn kho
- Biểu đồ doanh thu theo ngày
- Top sản phẩm bán chạy
- Thống kê theo danh mục
- Lọc theo khoảng thời gian

### ⚙️ Cài đặt
- Đăng xuất
- Thông tin ứng dụng

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.10.0
- Firebase project đã được cấu hình

### Cài đặt

1. **Clone repository:**
```bash
git clone https://github.com/NhatKhanh-Lab/QLVLXD-Flutter.git
cd QLVLXD-Flutter
```

2. **Cài đặt dependencies:**
```bash
flutter pub get
```

3. **Cấu hình Firebase:**
   - Tạo project tại [Firebase Console](https://console.firebase.google.com/)
   - Tải file cấu hình:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
   - File `lib/firebase_options.dart` sẽ được tự động generate khi chạy `flutter pub get`

4. **Generate Hive Adapters (nếu cần):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Chạy ứng dụng:**
```bash
flutter run
```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                      # Entry point
├── firebase_options.dart          # Firebase configuration
├── models/                        # Data models
│   ├── product.dart              # Model sản phẩm
│   ├── invoice.dart              # Model hóa đơn
│   ├── invoice_item.dart         # Model chi tiết hóa đơn
│   ├── customer.dart             # Model khách hàng
│   ├── supplier.dart             # Model nhà cung cấp
│   ├── purchase_order.dart       # Model đơn nhập hàng
│   └── user.dart                 # Model người dùng
├── screens/                       # UI Screens
│   ├── login_screen.dart         # Màn hình đăng nhập
│   ├── home_screen.dart          # Màn hình chính (Dashboard)
│   ├── product_list_screen.dart  # Danh sách sản phẩm
│   ├── add_edit_product_screen.dart  # Thêm/Sửa sản phẩm
│   ├── invoice_screen.dart       # Tạo hóa đơn
│   ├── transaction_history_screen.dart  # Lịch sử giao dịch
│   ├── statistics_screen.dart    # Thống kê
│   ├── customer_list_screen.dart # Danh sách khách hàng
│   ├── add_edit_customer_screen.dart  # Thêm/Sửa khách hàng
│   ├── supplier_list_screen.dart # Danh sách nhà cung cấp
│   ├── add_edit_supplier_screen.dart  # Thêm/Sửa nhà cung cấp
│   ├── create_purchase_order_screen.dart  # Tạo đơn nhập hàng
│   ├── purchase_order_list_screen.dart  # Danh sách đơn nhập hàng
│   ├── user_management_screen.dart  # Quản lý nhân viên
│   ├── add_edit_user_screen.dart  # Thêm/Sửa nhân viên
│   ├── low_stock_products_screen.dart  # Sản phẩm sắp hết hàng
│   └── settings_screen.dart      # Cài đặt
├── widgets/                       # Reusable widgets
│   ├── invoice_item_widget.dart  # Widget chi tiết hóa đơn
│   └── ...
├── services/                      # Business logic
│   ├── firestore_service.dart    # Firestore database service
│   ├── firebase_auth_service.dart  # Firebase authentication
│   ├── pdf_service.dart          # PDF generation service
│   ├── firebase_analytics_service.dart  # Analytics
│   ├── firebase_crashlytics_service.dart  # Crash reporting
│   ├── firebase_messaging_service.dart  # Push notifications
│   ├── firebase_remote_config_service.dart  # Remote config
│   └── firebase_storage_service.dart  # File storage
└── providers/                     # State management
    ├── auth_provider.dart         # Authentication state
    ├── product_provider.dart      # Product state management
    ├── invoice_provider.dart      # Invoice state management
    ├── customer_provider.dart     # Customer state management
    ├── supplier_provider.dart     # Supplier state management
    ├── purchase_order_provider.dart  # Purchase order state
    └── ...
```

## 📦 Dependencies chính

### Core
- **flutter**: SDK framework
- **provider**: State management
- **intl**: Format số, ngày tháng
- **uuid**: Tạo ID duy nhất

### Firebase
- **firebase_core**: Firebase core
- **cloud_firestore**: Cloud database (realtime sync)
- **firebase_auth**: Authentication
- **firebase_storage**: File storage
- **firebase_analytics**: Analytics
- **firebase_crashlytics**: Crash reporting
- **firebase_messaging**: Push notifications
- **firebase_remote_config**: Remote configuration

### UI & Utilities
- **image_picker**: Chọn/chụp ảnh
- **fl_chart**: Biểu đồ
- **pdf**: PDF generation
- **printing**: Print PDF
- **google_fonts**: Font support

### Database (Legacy - có thể dùng cho offline cache)
- **sqflite**: SQLite database (nếu cần offline cache)
- **hive** / **hive_flutter**: Local storage (nếu cần)

## 🔧 Cấu hình Firebase

### Bước 1: Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Bật các service cần thiết:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
   - Analytics
   - Crashlytics

### Bước 2: Cấu hình Android
1. Vào Project Settings → Add app → Android
2. Nhập package name: `com.example.quanlyvlxd`
3. Tải file `google-services.json`
4. Đặt vào `android/app/google-services.json`

### Bước 3: Cấu hình iOS
1. Vào Project Settings → Add app → iOS
2. Nhập Bundle ID: `com.example.quanlyvlxd`
3. Tải file `GoogleService-Info.plist`
4. Đặt vào `ios/Runner/GoogleService-Info.plist`

### Bước 4: Cấu hình Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Invoices collection
    match /invoices/{invoiceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Customers collection
    match /customers/{customerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Suppliers collection
    match /suppliers/{supplierId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Purchase orders collection
    match /purchase_orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 Màn hình chính

### 🏠 Home Screen (Dashboard)
- KPI Cards: Tổng sản phẩm, Tồn kho thấp, Doanh thu hôm nay, Doanh thu tháng này
- Thao tác nhanh: Tạo hóa đơn, Xem lịch sử, Thống kê, Quản lý sản phẩm, v.v.
- Tổng quan tài chính
- Sản phẩm sắp hết hàng

### 📦 Product List
- Grid/List view
- Tìm kiếm sản phẩm
- Lọc theo danh mục
- Thêm/Sửa/Xóa sản phẩm

### 🧾 Invoice Screen
- Tạo hóa đơn mới
- **Chọn khách hàng từ danh sách** (icon search)
- Chọn sản phẩm và số lượng
- Tính VAT tự động
- **Xuất và in PDF hóa đơn**
- Tự động cập nhật tồn kho và tổng mua của khách hàng

### 📊 Statistics Screen
- Biểu đồ doanh thu theo ngày
- Top sản phẩm bán chạy
- Thống kê tồn kho
- Lọc theo khoảng thời gian

### 👥 Customer List
- Danh sách khách hàng
- Xem tổng mua hàng
- Tìm kiếm khách hàng
- Thêm/Sửa/Xóa khách hàng

### 👨‍💼 User Management (Admin only)
- Danh sách nhân viên
- Phân quyền Admin/Nhân viên
- Kích hoạt/Vô hiệu hóa tài khoản
- Thêm/Sửa/Xóa nhân viên

## 🎨 UI/UX

- **Material Design 3**: Giao diện hiện đại, trực quan
- **Responsive Design**: Tối ưu cho nhiều kích thước màn hình
- **Dark/Light Theme**: Hỗ trợ theme theo hệ thống
- **Smooth Animations**: Animation mượt mà
- **Intuitive Navigation**: Điều hướng dễ sử dụng

## 💾 Lưu trữ dữ liệu

- **Cloud**: Firebase Firestore (realtime sync)
- **Authentication**: Firebase Authentication
- **File Storage**: Firebase Storage (cho hình ảnh)
- **Offline Support**: Firestore tự động cache và sync khi có mạng

## 🔒 Bảo mật

- **Firebase Authentication**: Xác thực người dùng
- **Firestore Security Rules**: Bảo vệ dữ liệu
- **Phân quyền**: Admin và Nhân viên với quyền truy cập khác nhau
- **Data Encryption**: Dữ liệu được mã hóa khi truyền và lưu trữ

## 📝 Tính năng đặc biệt

### ✨ Đồng bộ Realtime
- Tất cả dữ liệu đồng bộ realtime qua Firestore
- Nhiều người dùng có thể làm việc đồng thời
- Tự động cập nhật khi có thay đổi

### 📄 PDF Invoice
- Hóa đơn PDF chuyên nghiệp
- Hỗ trợ font Unicode (tiếng Việt) với Roboto
- Hiển thị thông tin khách hàng và nhân viên
- Layout hiện đại, nghiêm túc

### 🔍 Chọn khách hàng thông minh
- Chọn khách hàng từ danh sách đã lưu
- Tự động điền thông tin
- Tự động cập nhật tổng mua hàng

## 🐛 Xử lý lỗi

Nếu gặp lỗi khi generate code:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Nếu gặp lỗi Firebase:

1. Kiểm tra file cấu hình đã đặt đúng vị trí chưa
2. Kiểm tra Firestore Rules đã cấu hình đúng chưa
3. Kiểm tra Authentication đã bật Email/Password chưa

## 📞 Hỗ trợ

Nếu có vấn đề, vui lòng tạo [issue](https://github.com/NhatKhanh-Lab/QLVLXD-Flutter/issues) trên repository.

## 👥 Contributors

- **Nguyễn Hoàng Giang** - 2280600758
- **Võ Nhật Khánh** - 2280601481
- **Lê Phạm Mẫn** - 2280601902
- **Trần Hoài Nam** - 2280602037

## 📄 License

Dự án này được tạo cho mục đích học tập và thương mại.

---

**GKNM PROJECT - QLVLXD** 🏗️

*Hệ thống quản lý bán vật liệu xây dựng hiện đại, hiệu quả*
