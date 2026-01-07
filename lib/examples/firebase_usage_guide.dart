/// HƯỚNG DẪN SỬ DỤNG FIREBASE TRONG DỰ ÁN (TÀI LIỆU)
///
/// File này CHỈ để đọc hướng dẫn, không được import code dự án
/// để tránh lỗi analyzer khi bạn chưa setup Firebase.
///
/// ✅ Khi cần bật Firebase:
/// 1) Setup Firebase project (google-services.json / GoogleService-Info.plist)
/// 2) Bật firebase_core + cloud_firestore trong pubspec.yaml
/// 3) Trong main.dart: gọi FirebaseService.init()
/// 4) Viết FirebaseService sync/restore theo nhu cầu

/*
============================================
BƯỚC 1: THIẾT LẬP FIREBASE PROJECT
============================================
1. Truy cập Firebase Console
2. Tạo project
3. Thêm app Android/iOS
4. Tải google-services.json → android/app/
5. Bật Firestore Database

============================================
BƯỚC 2: KHỞI TẠO FIREBASE TRONG APP
============================================
Trong main.dart, trước runApp():

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();

  // Bật khi đã setup Firebase
  // await FirebaseService.init();

  runApp(const MyApp());
}

============================================
GHI CHÚ
============================================
- App chạy OFFLINE-FIRST (Hive)
- Firebase là OPTIONAL (sync/backup)
*/
