// HƯỚNG DẪN SỬ DỤNG FIREBASE TRONG DỰ ÁN
// File này chứa ví dụ và hướng dẫn chi tiết

import '../services/firebase_service.dart';
import '../services/db_service.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/supplier.dart';
import '../models/customer.dart';
import '../models/purchase_order.dart';

/// ============================================
/// BƯỚC 1: THIẾT LẬP FIREBASE PROJECT
/// ============================================
/*
1. Truy cập https://console.firebase.google.com/
2. Tạo project mới hoặc chọn project có sẵn
3. Thêm app Android:
   - Package name: com.example.quanlyvlxd (kiểm tra trong android/app/build.gradle.kts)
   - Tải file google-services.json
   - Đặt vào: android/app/google-services.json
4. Thêm app iOS (nếu cần):
   - Bundle ID: com.example.quanlyvlxd (kiểm tra trong ios/Runner/Info.plist)
   - Tải file GoogleService-Info.plist
   - Đặt vào: ios/Runner/GoogleService-Info.plist
5. Bật Firestore Database trong Firebase Console
6. Tạo Firestore Database (chọn chế độ Production hoặc Test)
*/

/// ============================================
/// BƯỚC 2: KHỞI TẠO FIREBASE TRONG APP
/// ============================================
/*
Trong main.dart, thêm dòng này TRƯỚC runApp():

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DatabaseService.init();
  
  // Initialize Firebase (uncomment khi đã setup Firebase)
  await FirebaseService.init();
  
  runApp(const MyApp());
}
*/

/// ============================================
/// BƯỚC 3: CÁCH SỬ DỤNG FIREBASE
/// ============================================

class FirebaseUsageExamples {
  
  // ========== ĐỒNG BỘ DỮ LIỆU LÊN FIREBASE ==========
  
  /// Đồng bộ một sản phẩm lên Firebase
  /// (Tự động được gọi khi thêm/sửa sản phẩm trong ProductProvider)
  Future<void> exampleSyncProduct() async {
    final product = Product(
      id: 'prod_001',
      name: 'Xi măng PC40',
      category: 'Xi măng',
      price: 85000,
      quantity: 100,
      unit: 'Bao',
      minStock: 20,
    );
    
    // Lưu vào local database (Hive)
    await DatabaseService.addProduct(product);
    
    // Đồng bộ lên Firebase
    await FirebaseService.syncProductToFirebase(product);
    print('Đã đồng bộ sản phẩm lên Firebase');
  }
  
  /// Đồng bộ một hóa đơn lên Firebase
  Future<void> exampleSyncInvoice() async {
    final invoice = Invoice(
      id: 'inv_001',
      customerId: 'cus_001',
      customerName: 'Nguyễn Văn A',
      items: [],
      total: 425000,
      createdAt: DateTime.now(),
    );
    
    // Lưu vào local database
    await DatabaseService.addInvoice(invoice);
    
    // Đồng bộ lên Firebase
    await FirebaseService.syncInvoiceToFirebase(invoice);
    print('Đã đồng bộ hóa đơn lên Firebase');
  }
  
  /// Đồng bộ TẤT CẢ dữ liệu lên Firebase
  /// (Dùng khi muốn backup toàn bộ dữ liệu)
  Future<void> exampleSyncAllData() async {
    await FirebaseService.syncAllToFirebase();
    print('Đã đồng bộ tất cả dữ liệu lên Firebase');
  }
  
  
  // ========== TẢI DỮ LIỆU TỪ FIREBASE ==========
  
  /// Tải tất cả sản phẩm từ Firebase
  Future<void> exampleFetchProductsFromFirebase() async {
    final products = await FirebaseService.fetchProductsFromFirebase();
    print('Đã tải ${products.length} sản phẩm từ Firebase');
    
    // Lưu vào local database
    for (final product in products) {
      await DatabaseService.addProduct(product);
    }
  }
  
  /// Tải tất cả hóa đơn từ Firebase
  Future<void> exampleFetchInvoicesFromFirebase() async {
    final invoices = await FirebaseService.fetchInvoicesFromFirebase();
    print('Đã tải ${invoices.length} hóa đơn từ Firebase');
    
    // Lưu vào local database
    for (final invoice in invoices) {
      await DatabaseService.addInvoice(invoice);
    }
  }
  
  /// Khôi phục TẤT CẢ dữ liệu từ Firebase về local
  /// (Dùng khi muốn restore dữ liệu từ cloud)
  Future<void> exampleRestoreFromFirebase() async {
    await FirebaseService.restoreFromFirebase();
    print('Đã khôi phục dữ liệu từ Firebase');
  }
  
  
  // ========== XÓA DỮ LIỆU TRÊN FIREBASE ==========
  
  /// Xóa sản phẩm trên Firebase
  Future<void> exampleDeleteProductFromFirebase() async {
    final productId = 'prod_001';
    
    // Xóa trong local database
    await DatabaseService.deleteProduct(productId);
    
    // Xóa trên Firebase
    await FirebaseService.deleteProductFromFirebase(productId);
    print('Đã xóa sản phẩm trên Firebase');
  }
}


/// ============================================
/// BƯỚC 4: SỬ DỤNG TRONG PROVIDER (Tự động)
/// ============================================
/*
Firebase đã được tích hợp tự động trong các Provider:

1. ProductProvider:
   - Khi thêm/sửa sản phẩm → Tự động sync lên Firebase
   - Khi xóa sản phẩm → Tự động xóa trên Firebase

2. InvoiceProvider:
   - Khi tạo hóa đơn → Tự động sync lên Firebase

Bạn không cần gọi FirebaseService trực tiếp trong UI,
chỉ cần sử dụng Provider như bình thường!
*/

/// ============================================
/// BƯỚC 5: SỬ DỤNG TRONG UI (Settings Screen)
/// ============================================
/*
Trong Settings Screen đã có sẵn 2 nút:

1. "Đồng bộ lên Firebase" - Đồng bộ tất cả dữ liệu local lên cloud
2. "Khôi phục từ Firebase" - Tải dữ liệu từ cloud về local

Người dùng có thể sử dụng các nút này để:
- Backup dữ liệu lên cloud
- Restore dữ liệu từ cloud
- Đồng bộ giữa các thiết bị
*/


/// ============================================
/// BƯỚC 6: CẤU TRÚC DỮ LIỆU TRONG FIRESTORE
/// ============================================
/*
Firestore Database Structure:

/collection: products
  /document: {productId}
    - id: string
    - name: string
    - category: string
    - price: number
    - quantity: number
    - unit: string
    - minStock: number
    - description: string
    - createdAt: timestamp
    - updatedAt: timestamp

/collection: invoices
  /document: {invoiceId}
    - id: string
    - customerId: string
    - customerName: string
    - items: array
    - total: number
    - createdAt: timestamp
*/


/// ============================================
/// BƯỚC 7: MỞ RỘNG FIREBASE SERVICE
/// ============================================
/*
Nếu muốn thêm đồng bộ cho Supplier, Customer, PurchaseOrder:

1. Thêm collection names trong firebase_service.dart:
   static const String suppliersCollection = 'suppliers';
   static const String customersCollection = 'customers';
   static const String purchaseOrdersCollection = 'purchase_orders';

2. Thêm các method sync tương tự như Product và Invoice

3. Gọi sync trong các Provider tương ứng
*/


/// ============================================
/// LƯU Ý QUAN TRỌNG
/// ============================================
/*
1. App hoạt động OFFLINE-FIRST:
   - Dữ liệu luôn được lưu vào Hive (local) trước
   - Firebase chỉ là backup/sync
   - Nếu Firebase lỗi, app vẫn hoạt động bình thường

2. Firebase là OPTIONAL:
   - Nếu chưa setup Firebase, app vẫn chạy được
   - Các lỗi Firebase sẽ được bỏ qua (silent fail)

3. Security Rules:
   - Nhớ setup Firestore Security Rules trong Firebase Console
   - Mặc định: chỉ authenticated users mới đọc/ghi được
   - Có thể tạm thời cho phép read/write cho testing:
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if true;
         }
       }
     }
   ⚠️ CẢNH BÁO: Quy tắc trên cho phép mọi người đọc/ghi!
     Chỉ dùng cho testing, không dùng cho production!

4. Chi phí:
   - Firestore có free tier: 50K reads, 20K writes/ngày
   - Vượt quá sẽ tính phí
   - Nên tối ưu số lần đọc/ghi
*/

