# Hướng dẫn cấu hình Firebase cho dự án

## ⚠️ Vấn đề hiện tại

App không đăng nhập được vì **Firebase chưa được cấu hình**. Cần setup Firebase để app hoạt động.

## 🚀 Cách cấu hình Firebase

### Bước 1: Cài đặt FlutterFire CLI

```powershell
dart pub global activate flutterfire_cli
```

### Bước 2: Đăng nhập Firebase

```powershell
firebase login
```

### Bước 3: Cấu hình Firebase cho dự án

```powershell
flutterfire configure
```

Lệnh này sẽ:
- Kết nối với Firebase project của bạn
- Tạo file `firebase_options.dart` tự động
- Cấu hình cho tất cả platforms (Android, iOS, Web, Windows)

### Bước 4: Chọn/Create Firebase Project

Khi chạy `flutterfire configure`:
1. Chọn Firebase project có sẵn HOẶC
2. Tạo project mới tại [Firebase Console](https://console.firebase.google.com)

### Bước 5: Enable các dịch vụ trong Firebase Console

Sau khi cấu hình, vào [Firebase Console](https://console.firebase.google.com):

1. **Authentication** → Enable Email/Password
2. **Firestore Database** → Create database (Start in test mode)
3. **Storage** → Enable (nếu cần upload ảnh)

## 🔧 Nếu không có Firebase project

### Tạo Firebase project mới:

1. Vào https://console.firebase.google.com
2. Click "Add project"
3. Đặt tên project (ví dụ: `quanlyvlxd`)
4. Enable Google Analytics (tùy chọn)
5. Click "Create project"

### Sau đó chạy:

```powershell
flutterfire configure
```

Và chọn project vừa tạo.

## ✅ Sau khi cấu hình xong

1. Restart app: `flutter run`
2. Default admin sẽ được tạo tự động:
   - Username: `admin`
   - Password: `admin123`
   - Email: `admin@quanlyvlxd.com`

## 🐛 Troubleshooting

### Lỗi: "Firebase not initialized"
- Chạy `flutterfire configure` lại
- Kiểm tra file `lib/firebase_options.dart` có tồn tại không

### Lỗi: "Permission denied"
- Kiểm tra Firestore Rules trong Firebase Console
- Đảm bảo Authentication đã được enable

### Lỗi: "User not found"
- Kiểm tra console logs để xem default admin có được tạo không
- Có thể cần tạo user thủ công trong Firestore

## 📝 Firestore Security Rules (tạm thời cho development)

Vào Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write if user is authenticated
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Hoặc cho phép tất cả (CHỈ DÙNG CHO DEVELOPMENT!)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ LƯU Ý:** Rules trên cho phép tất cả (chỉ dùng cho development). Production cần rules chặt chẽ hơn.

## 🎯 Quick Start (Nếu muốn test nhanh)

1. Tạo Firebase project tại https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Firestore (test mode)
4. Chạy: `flutterfire configure`
5. Chọn project vừa tạo
6. Restart app: `flutter run`

Sau đó đăng nhập với:
- Username: `admin`
- Password: `admin123`

