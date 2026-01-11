# Script cấu hình Firebase cho dự án Flutter

Write-Host "=== Cấu hình Firebase ===" -ForegroundColor Cyan

# Thêm npm vào PATH
$env:Path += ";$env:APPDATA\npm"

# Kiểm tra Firebase CLI
Write-Host "`nKiểm tra Firebase CLI..." -ForegroundColor Yellow
try {
    $firebaseVersion = firebase --version
    Write-Host "✓ Firebase CLI: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Firebase CLI chưa được cài đặt" -ForegroundColor Red
    Write-Host "Đang cài đặt Firebase CLI..." -ForegroundColor Yellow
    npm install -g firebase-tools
}

# Kiểm tra đăng nhập
Write-Host "`nKiểm tra đăng nhập Firebase..." -ForegroundColor Yellow
try {
    firebase login --no-localhost
    Write-Host "✓ Đã đăng nhập Firebase" -ForegroundColor Green
} catch {
    Write-Host "✗ Chưa đăng nhập Firebase" -ForegroundColor Red
    Write-Host "Vui lòng đăng nhập: firebase login" -ForegroundColor Yellow
    exit 1
}

# Chạy FlutterFire configure
Write-Host "`nĐang cấu hình Firebase cho Flutter..." -ForegroundColor Yellow
Write-Host "Vui lòng chọn Firebase project hoặc tạo mới" -ForegroundColor Cyan
Write-Host ""

dart pub global run flutterfire_cli:flutterfire configure

Write-Host "`n=== Hoàn tất ===" -ForegroundColor Green
Write-Host "Sau khi cấu hình xong:" -ForegroundColor Yellow
Write-Host "1. Vào Firebase Console: https://console.firebase.google.com" -ForegroundColor White
Write-Host "2. Enable Authentication → Email/Password" -ForegroundColor White
Write-Host "3. Enable Firestore Database → Create database (test mode)" -ForegroundColor White
Write-Host "4. Restart app: flutter run" -ForegroundColor White

