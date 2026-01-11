# Hướng dẫn cấu hình Project Firebase đúng

## 🔍 Vấn đề hiện tại

Bạn thấy project `qlvlxd-e5fbd` trong Firebase Console nhưng:
- Project này có thể thuộc account khác
- Hoặc chưa được cấu hình trong FlutterFire CLI
- Bạn muốn project có tên là **QLVLXD**

## ✅ Giải pháp

### Option 1: Dùng project `qlvlxd-e5fbd` hiện có (Nếu bạn có quyền)

1. **Kiểm tra project có trong danh sách không:**
   ```powershell
   $env:Path += ";$env:APPDATA\npm"
   firebase projects:list
   ```

2. **Nếu project `qlvlxd-e5fbd` KHÔNG có trong danh sách:**
   - Project này thuộc account khác
   - Cần đăng nhập với account đúng hoặc được mời vào project

3. **Nếu project có trong danh sách:**
   ```powershell
   dart pub global run flutterfire_cli:flutterfire configure
   ```
   - Chọn project `qlvlxd-e5fbd`

### Option 2: Tạo project mới với tên QLVLXD (Khuyến nghị)

1. **Tạo project mới trong Firebase Console:**
   - Vào https://console.firebase.google.com
   - Click **"Add project"** hoặc **"Thêm dự án"**
   - Đặt tên: **QLVLXD**
   - Project ID sẽ tự động: `qlvlxd-xxxxx` (không thể đổi)
   - Click **"Create project"**

2. **Cấu hình FlutterFire:**
   ```powershell
   $env:Path += ";$env:APPDATA\npm"
   dart pub global run flutterfire_cli:flutterfire configure
   ```
   - Chọn project **QLVLXD** vừa tạo
   - Chọn platforms (Android, iOS, Web, Windows)

3. **Enable các dịch vụ:**
   - **Authentication** → Email/Password
   - **Firestore Database** → Create database (test mode)

### Option 3: Đổi tên hiển thị của project (Không đổi Project ID)

**Lưu ý:** Project ID (`qlvlxd-e5fbd`) **KHÔNG THỂ ĐỔI** sau khi tạo. Chỉ có thể đổi **Display Name**.

1. Vào Firebase Console → Project Settings
2. Click **"Edit"** ở **Project name**
3. Đổi thành **QLVLXD**
4. Click **"Save"**

Project ID vẫn là `qlvlxd-e5fbd` nhưng tên hiển thị sẽ là **QLVLXD**.

## 🎯 Cách nhanh nhất

### Nếu project `qlvlxd-e5fbd` đã có dữ liệu và bạn muốn dùng:

1. **Đảm bảo đăng nhập đúng account:**
   ```powershell
   $env:Path += ";$env:APPDATA\npm"
   firebase login:list
   ```

2. **Kiểm tra project có trong danh sách:**
   ```powershell
   firebase projects:list
   ```

3. **Nếu có, cấu hình FlutterFire:**
   ```powershell
   dart pub global run flutterfire_cli:flutterfire configure
   ```
   Chọn project `qlvlxd-e5fbd`

4. **Đổi tên hiển thị thành QLVLXD:**
   - Vào Firebase Console
   - Project Settings → Đổi Project name thành **QLVLXD**

### Nếu project `qlvlxd-e5fbd` KHÔNG có trong danh sách:

**Có 2 khả năng:**

1. **Project thuộc account khác:**
   - Đăng nhập với account đúng
   - Hoặc được mời vào project

2. **Tạo project mới:**
   - Tạo project mới với tên **QLVLXD**
   - Cấu hình FlutterFire với project mới

## 📝 Kiểm tra project hiện tại

Sau khi cấu hình, kiểm tra file `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: '...',
  appId: '...',
  messagingSenderId: '...',
  projectId: 'qlvlxd-e5fbd', // <-- Đây là project ID
  // ...
);
```

Project ID (`qlvlxd-e5fbd`) là duy nhất và không thể đổi, nhưng **Display Name** có thể đổi thành **QLVLXD**.

## ⚠️ Lưu ý

- **Project ID** (`qlvlxd-e5fbd`) = Không thể đổi, dùng để kết nối
- **Display Name** = Có thể đổi thành **QLVLXD** trong Firebase Console
- Nếu project có dữ liệu, nên dùng project hiện có thay vì tạo mới

