import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/db_service.dart';
import 'services/firebase_service.dart';
import 'providers/product_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/purchase_order_provider.dart';
import 'shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await DatabaseService.init();

  // Initialize Firebase (uncomment sau khi đã setup Firebase)
  // Xem hướng dẫn trong lib/examples/firebase_usage_guide.dart
  await FirebaseService.init();

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
            primary: Color(0xFF1F2937),      // Charcoal
            onPrimary: Colors.white,
            secondary: Color(0xFF3B82F6),    // Modern Blue
            onSecondary: Colors.white,
            error: Color(0xFFEF4444),        // Danger Red
            onError: Colors.white,
            background: Color(0xFFF8FAFC),  // Light Gray BG
            onBackground: Color(0xFF1F2937),
            surface: Color(0xFFFFFFFF),      // White Surface
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
            color: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
          ),
          ),
          textTheme: const TextTheme(
            // For section headers
            titleMedium: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: Color(0xFF4B5563),
              letterSpacing: 0.5,
            ),
            // For KPI values
            headlineLarge: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1F2937),
            ),
            // For card titles/labels
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
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
