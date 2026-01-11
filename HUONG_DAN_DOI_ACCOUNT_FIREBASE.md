# Hướng dẫn đổi Account Google trong Firebase

## 🔄 Đổi Account trong Firebase Console (Web)

### Cách 1: Đăng xuất và đăng nhập lại

1. **Đăng xuất khỏi Firebase Console:**
   - Click vào avatar/icon account ở góc trên bên phải
   - Chọn **"Sign out"** hoặc **"Đăng xuất"**

2. **Đăng nhập với account mới:**
   - Vào https://console.firebase.google.com
   - Click **"Sign in"**
   - Chọn account Google mới

### Cách 2: Thêm account mới (Multi-account)

1. Click vào avatar ở góc trên bên phải
2. Click **"Add another account"** hoặc **"Thêm tài khoản"**
3. Đăng nhập với account Google mới
4. Chuyển đổi giữa các account bằng cách click vào avatar

## 💻 Đổi Account trong Firebase CLI (Terminal)

### Bước 1: Đăng xuất Firebase CLI

```powershell
$env:Path += ";$env:APPDATA\npm"
firebase logout
```

### Bước 2: Đăng nhập với account mới

```powershell
firebase login
```

Hoặc nếu không có browser:

```powershell
firebase login --no-localhost
```

### Bước 3: Chọn account khi đăng nhập

- Mở link được hiển thị trong terminal
- Chọn account Google mới
- Copy token và paste vào terminal

## 🔧 Đổi Account cho FlutterFire CLI

Sau khi đổi account trong Firebase CLI, FlutterFire CLI sẽ tự động dùng account mới:

```powershell
$env:Path += ";$env:APPDATA\npm"
dart pub global run flutterfire_cli:flutterfire configure
```

## ⚠️ Lưu ý quan trọng

### 1. Quyền truy cập Project
- Nếu project `qlvlxd-e5fbd` thuộc account cũ, bạn cần:
  - **Option A:** Mời account mới vào project (recommended)
  - **Option B:** Chuyển ownership project sang account mới

### 2. Mời account mới vào project (Khuyến nghị)

1. Vào Firebase Console với account cũ
2. Vào **Project Settings** (⚙️) → **Users and permissions**
3. Click **"Add member"**
4. Nhập email account mới
5. Chọn role: **Owner** hoặc **Editor**
6. Click **"Add"**

Sau đó account mới sẽ thấy project trong danh sách.

### 3. Chuyển ownership project

1. Vào **Project Settings** → **Users and permissions**
2. Tìm account mới trong danh sách
3. Đổi role thành **Owner**
4. Xóa account cũ (nếu muốn)

## 🎯 Quick Steps để đổi account

```powershell
# 1. Đăng xuất Firebase CLI
$env:Path += ";$env:APPDATA\npm"
firebase logout

# 2. Đăng nhập với account mới
firebase login

# 3. Cấu hình lại FlutterFire
dart pub global run flutterfire_cli:flutterfire configure
```

## 📝 Kiểm tra account hiện tại

```powershell
$env:Path += ";$env:APPDATA\npm"
firebase login:list
```

Lệnh này sẽ hiển thị tất cả accounts đã đăng nhập.

## 🔐 Nếu project thuộc account khác

Nếu project `qlvlxd-e5fbd` thuộc account khác và bạn muốn dùng account mới:

1. **Mời account mới vào project** (tốt nhất)
2. Hoặc **tạo project mới** với account mới
3. Hoặc **chuyển ownership** project

---

**Lưu ý:** Sau khi đổi account, bạn cần chạy lại `flutterfire configure` để cập nhật cấu hình.

