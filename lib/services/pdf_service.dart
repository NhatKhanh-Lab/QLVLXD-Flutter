import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/user.dart' as app_user;
import '../services/firebase_auth_service.dart';

class PDFService {
  // Professional color scheme - neutral and serious
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF212121); // Dark gray/black
  static const PdfColor mediumGray = PdfColor.fromInt(0xFF757575);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE0E0E0);

  // Cache fonts to avoid reloading
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  // Load font with Unicode support
  static Future<void> _loadFonts({bool forceReload = false}) async {
    if (!forceReload && _regularFont != null && _boldFont != null) return;

    try {
      // Try to load Roboto font from assets (if user added them)
      try {
        print('Attempting to load fonts from assets/fonts/...');
        final regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
        final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
        
        print('Font files found:');
        print('  - Roboto-Regular.ttf: ${regularData.lengthInBytes} bytes');
        print('  - Roboto-Bold.ttf: ${boldData.lengthInBytes} bytes');
        
        // Validate font data
        if (regularData.lengthInBytes > 1000 && boldData.lengthInBytes > 1000) {
          _regularFont = pw.Font.ttf(regularData);
          _boldFont = pw.Font.ttf(boldData);
          print('✓ Successfully loaded Roboto fonts from assets');
          print('✓ Unicode/Vietnamese characters should display correctly');
          return;
        } else {
          print('⚠ Font files are too small (may be corrupted)');
        }
      } catch (e) {
        print('⚠ Could not load fonts from assets: $e');
        print('⚠ Make sure:');
        print('  1. Roboto-Regular.ttf and Roboto-Bold.ttf are in assets/fonts/');
        print('  2. pubspec.yaml has assets/fonts/ in assets section');
        print('  3. Run: flutter pub get && flutter clean && flutter run');
      }

      // Fallback: Use default fonts (may not support all Vietnamese characters)
      // Note: Default fonts may have Unicode issues
      _regularFont = pw.Font.courier();
      _boldFont = pw.Font.courierBold();
      print('⚠ Using default fonts (may have Unicode issues)');
      print('⚠ To fix Unicode: Download Roboto fonts from https://fonts.google.com/specimen/Roboto');
      print('⚠ Place Roboto-Regular.ttf and Roboto-Bold.ttf in assets/fonts/');
      print('⚠ Then run: flutter pub get && flutter clean && flutter run');
    } catch (e) {
      print('Error loading fonts: $e');
      // Ultimate fallback
      _regularFont = pw.Font.courier();
      _boldFont = pw.Font.courierBold();
    }
  }

  static Future<void> generateAndPrintInvoice(Invoice invoice) async {
    // Load fonts with Unicode support
    await _loadFonts();

    // Get employee information if available
    app_user.User? employee;
    if (invoice.createdBy != null && invoice.createdBy!.isNotEmpty) {
      try {
        employee = await FirebaseAuthService.getUserByUid(invoice.createdBy!);
      } catch (e) {
        print('Could not load employee info: $e');
      }
    }

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: _regularFont ?? pw.Font.courier(),
          bold: _boldFont ?? pw.Font.courierBold(),
        ),
        build: (pw.Context context) {
          return _buildInvoiceContent(invoice, dateFormat, currencyFormat, employee);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper function to build invoice content (reusable for both print and save)
  static List<pw.Widget> _buildInvoiceContent(
    Invoice invoice,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
    app_user.User? employee,
  ) {
    return [
      // Professional Header - clean and minimal
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'HÓA ĐƠN BÁN HÀNG',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Số: ${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: mediumGray,
                ),
              ),
            ],
          ),
          pw.Text(
            dateFormat.format(invoice.createdAt),
            style: pw.TextStyle(
              fontSize: 11,
              color: mediumGray,
            ),
          ),
        ],
      ),

      pw.Divider(color: borderColor, height: 30),

      // Customer and Employee Information - professional layout
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Customer Information
          if (invoice.customerName != null || invoice.customerPhone != null)
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                margin: const pw.EdgeInsets.only(bottom: 24, right: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'THÔNG TIN KHÁCH HÀNG',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (invoice.customerName != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Text(
                          'Tên: ${invoice.customerName}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    if (invoice.customerPhone != null)
                      pw.Text(
                        'SĐT: ${invoice.customerPhone}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Employee Information
          if (employee != null)
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                margin: const pw.EdgeInsets.only(bottom: 24, left: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NHÂN VIÊN BÁN HÀNG',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Tên: ${employee.fullName}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                      ),
                    ),
                    if (employee.username != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          'Mã NV: ${employee.username}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: mediumGray,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Professional Items Table
      pw.Table(
        border: pw.TableBorder.all(color: borderColor, width: 1),
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: lightGray),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'STT',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'TÊN SẢN PHẨM',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'ĐƠN GIÁ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'SL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'THÀNH TIỀN',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          // Items rows
          ...invoice.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    '${index + 1}',
                    style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    item.productName,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: primaryColor,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    '${currencyFormat.format(item.unitPrice)} đ',
                    style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    '${item.quantity}',
                    style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    '${currencyFormat.format(item.total)} đ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            );
          }),
        ],
      ),

      pw.SizedBox(height: 20),

      // Notes - simple and clean
      if (invoice.notes != null && invoice.notes!.isNotEmpty)
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          margin: const pw.EdgeInsets.only(bottom: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderColor, width: 1),
          ),
          child: pw.Text(
            'Ghi chú: ${invoice.notes}',
            style: pw.TextStyle(fontSize: 10, color: mediumGray),
          ),
        ),

      pw.SizedBox(height: 20),

      // Professional Totals Section
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          width: 250,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderColor, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tạm tính:',
                    style: pw.TextStyle(fontSize: 11, color: primaryColor),
                  ),
                  pw.Text(
                    '${currencyFormat.format(invoice.subtotal)} đ',
                    style: pw.TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'VAT (10%):',
                    style: pw.TextStyle(fontSize: 11, color: primaryColor),
                  ),
                  pw.Text(
                    '${currencyFormat.format(invoice.vat)} đ',
                    style: pw.TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              pw.Divider(color: borderColor, height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TỔNG CỘNG:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    '${currencyFormat.format(invoice.total)} đ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      pw.SizedBox(height: 40),

      // Professional Footer
      pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          'Cảm ơn quý khách đã sử dụng dịch vụ!',
          style: pw.TextStyle(
            fontSize: 10,
            color: mediumGray,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    ];
  }

  static Future<File> saveInvoiceToFile(Invoice invoice, String filePath) async {
    // Load fonts with Unicode support
    await _loadFonts();

    // Get employee information if available
    app_user.User? employee;
    if (invoice.createdBy != null && invoice.createdBy!.isNotEmpty) {
      try {
        employee = await FirebaseAuthService.getUserByUid(invoice.createdBy!);
      } catch (e) {
        print('Could not load employee info: $e');
      }
    }

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: _regularFont ?? pw.Font.courier(),
          bold: _boldFont ?? pw.Font.courierBold(),
        ),
        build: (pw.Context context) {
          return _buildInvoiceContent(invoice, dateFormat, currencyFormat, employee);
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
