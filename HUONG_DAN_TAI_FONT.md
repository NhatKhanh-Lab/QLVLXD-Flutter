# Hướng dẫn tải font Roboto cho PDF

## Vấn đề
Font mặc định của package PDF không hỗ trợ tốt ký tự tiếng Việt (Unicode), dẫn đến hiển thị sai các ký tự như "HÓA ĐƠN" thành "HÓA ĐƠN" với ký tự lỗi.

## Giải pháp
Tải font Roboto (hỗ trợ đầy đủ Unicode và tiếng Việt) và thêm vào project.

## Các bước thực hiện:

### Bước 1: Tải font Roboto
1. Truy cập: https://fonts.google.com/specimen/Roboto
2. Click "Download family"
3. Giải nén file ZIP

### Bước 2: Copy font vào project
1. Tìm 2 file sau trong thư mục đã giải nén:
   - `Roboto-Regular.ttf`
   - `Roboto-Bold.ttf`
2. Copy 2 file này vào thư mục: `assets/fonts/`
   - Nếu thư mục chưa có, tạo mới: `assets/fonts/`

### Bước 3: Cập nhật pubspec.yaml
Mở file `pubspec.yaml` và uncomment phần fonts:

```yaml
  assets:
    - assets/images/
    - assets/fonts/  # Uncomment dòng này

  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### Bước 4: Chạy lại app
```bash
flutter pub get
flutter run
```

## Kết quả
Sau khi thêm font, hóa đơn PDF sẽ hiển thị đúng tất cả ký tự tiếng Việt.

## Lưu ý
- Font Roboto là font miễn phí từ Google Fonts
- Font sẽ được nhúng vào PDF, đảm bảo hiển thị đúng trên mọi thiết bị
- Kích thước file PDF có thể tăng nhẹ do nhúng font

