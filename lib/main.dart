import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Services
import 'services/db_service.dart';
// import 'services/firebase_service.dart'; // ✅ Tạm tắt để chạy UI ổn định (bật sau)

// ✅ Providers
import 'providers/product_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/purchase_order_provider.dart';

// ✅ UI Shell
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hiển thị lỗi ngay trên màn hình nếu có crash (đỡ bị trắng)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(details.exceptionAsString()),
        ),
      ),
    );
  };

  // ✅ Web: tạm bỏ Hive/DB để UI chạy chắc chắn
  // ✅ Mobile/Desktop (Android/Windows): vẫn init như bình thường
  if (!kIsWeb) {
    await DatabaseService.init();
  }

  // ✅ Firebase: TẠM TẮT để tránh crash (bật lại sau khi setup xong)
  // await FirebaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
      ],
      child: MaterialApp(
        title: 'Quản lý Vật liệu Xây dựng',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF1F2937),
            onPrimary: Colors.white,
            secondary: Color(0xFF3B82F6),
            onSecondary: Colors.white,
            error: Color(0xFFEF4444),
            onError: Colors.white,
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF1F2937),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          ),
          cardTheme: CardThemeData(
  elevation: 0,
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: const Color(0xFFE5E7EB), // viền xám nhạt
      width: 1,
    ),
  ),
),

          textTheme: const TextTheme(
            titleMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
              letterSpacing: 0.5,
            ),
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1F2937),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: CircleBorder(),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
