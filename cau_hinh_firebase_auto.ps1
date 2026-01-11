# Script tự động cấu hình Firebase với project QLVLXD

Write-Host "=== Cấu hình Firebase cho project QLVLXD ===" -ForegroundColor Cyan

# Thêm npm vào PATH
$env:Path += ";$env:APPDATA\npm"

# Kiểm tra project
Write-Host "`nĐang kiểm tra projects..." -ForegroundColor Yellow
$projects = firebase projects:list

if ($projects -match "qlvlxd-e5fbd") {
    Write-Host "✓ Tìm thấy project QLVLXD (qlvlxd-e5fbd)" -ForegroundColor Green
} else {
    Write-Host "✗ Không tìm thấy project qlvlxd-e5fbd" -ForegroundColor Red
    exit 1
}

Write-Host "`nĐang cấu hình FlutterFire..." -ForegroundColor Yellow
Write-Host "Vui lòng chọn project 'qlvlxd-e5fbd (QLVLXD)' khi được hỏi" -ForegroundColor Cyan
Write-Host ""

# Chạy FlutterFire configure
# Lưu ý: Cần chọn platforms (Android, iOS, Web, Windows)
dart pub global run flutterfire_cli:flutterfire configure

Write-Host "`n=== Hoàn tất cấu hình ===" -ForegroundColor Green
Write-Host "`nBước tiếp theo:" -ForegroundColor Yellow
Write-Host "1. Kiểm tra file lib/firebase_options.dart đã được tạo" -ForegroundColor White
Write-Host "2. Vào Firebase Console và enable:" -ForegroundColor White
Write-Host "   - Authentication → Email/Password" -ForegroundColor White
Write-Host "   - Firestore Database → Create database (test mode)" -ForegroundColor White
Write-Host "3. Restart app: flutter run -d chrome" -ForegroundColor White

