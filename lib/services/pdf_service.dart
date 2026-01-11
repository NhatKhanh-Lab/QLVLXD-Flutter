import 'package:emv_qr_builder/emv_qr_builder.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/user.dart' as app_user;
import '../services/firebase_auth_service.dart';

class PDFService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    try {
      final regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);
    } catch (_) {
      _regularFont = pw.Font.helvetica();
      _boldFont = pw.Font.helveticaBold();
    }
  }

  static Future<app_user.User?> _loadEmployee(Invoice invoice) async {
    if (invoice.createdBy == null || invoice.createdBy!.isEmpty) return null;
    try {
      return await FirebaseAuthService.getUserByUid(invoice.createdBy!);
    } catch (_) {
      return null;
    }
  }

  static Future<void> generateAndPrintInvoice(Invoice invoice) async {
    await _loadFonts();
    final employee = await _loadEmployee(invoice);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _regularFont!,
        bold: _boldFont!,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(marginLeft: 30, marginRight: 30, marginTop: 20, marginBottom: 20),
        build: (pw.Context context) {
          return _buildModernInvoiceA4(invoice, employee);
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'HoaDon_${invoice.invoiceNumber}.pdf',
    );
  }

  static pw.Widget _buildModernInvoiceA4(Invoice invoice, app_user.User? employee) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat('#,##0', 'vi_VN');

    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final normalStyle = const pw.TextStyle(fontSize: 10);
    final smallStyle = const pw.TextStyle(fontSize: 9, color: PdfColors.grey700);

    final payQrPayload = _buildVietQrPayloadTpBank(
      amount: invoice.total,
      addInfo: invoice.invoiceNumber,
    );
    
    final vatPercent = (invoice.subtotal > 0) ? (invoice.vat / invoice.subtotal * 100) : 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Store Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('GKNM', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('266 Đội Cấn, Hà Nội', style: smallStyle),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Invoice Title and Info
        pw.Center(
          child: pw.Text(
            'HÓA ĐƠN BÁN HÀNG',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            'Số HĐ: ${invoice.invoiceNumber} - Ngày: ${dateFormat.format(invoice.createdAt)}',
            style: smallStyle,
          ),
        ),
        pw.SizedBox(height: 20),

        // Customer Info
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(width: 50, child: pw.Text('Khách:', style: normalStyle)),
                  pw.Text(invoice.customerName ?? 'Khách lẻ', style: headerStyle),
                ],
              ),
              pw.SizedBox(height: 4),
              if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty)
                pw.Row(
                  children: [
                    pw.SizedBox(width: 50, child: pw.Text('SĐT:', style: normalStyle)),
                    pw.Text(invoice.customerPhone!, style: normalStyle),
                  ],
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),

        // Items Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(6),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2.5),
            3: const pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tên hàng', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('SL', style: headerStyle, textAlign: pw.TextAlign.right)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('ĐG', style: headerStyle, textAlign: pw.TextAlign.right)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Thành tiền', style: headerStyle, textAlign: pw.TextAlign.right)),
              ],
            ),
            ...invoice.items.map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.productName, style: normalStyle)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.quantity.toString(), style: normalStyle, textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(currencyFormat.format(item.unitPrice), style: normalStyle, textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(currencyFormat.format(item.total), style: normalStyle, textAlign: pw.TextAlign.right)),
                ],
              );
            }).toList(),
          ],
        ),
        pw.SizedBox(height: 20),

        // Totals
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.SizedBox(
              width: 280,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildTotalRow('Tiền hàng', currencyFormat.format(invoice.subtotal), normalStyle),
                  _buildTotalRow('VAT (${vatPercent.toStringAsFixed(0)}%)', currencyFormat.format(invoice.vat), normalStyle),
                  pw.SizedBox(height: 5),
                  _buildTotalRow('Tổng thanh toán', currencyFormat.format(invoice.total), pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1, color: PdfColors.black),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.SizedBox(
              width: 280,
              child: _buildTotalRow('Còn phải thu', currencyFormat.format(invoice.total), normalStyle),
            ),
          ],
        ),
        pw.Spacer(),

        // QR Code and Footer
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Vui lòng kiểm tra kỹ lại nội dung trước khi thanh toán!', style: headerStyle),
              pw.SizedBox(height: 10),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: payQrPayload,
                width: 140,
                height: 140,
              ),
              pw.SizedBox(height: 10),
              pw.Text('Cảm ơn quý khách đã sử dụng dịch vụ!', style: normalStyle),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static String _buildVietQrPayloadTpBank({
    required double amount,
    required String addInfo,
  }) {
    try {
      final emvData = VietQrFactory.createPersonal(
        bankBin: '970423',
        accountNumber: '68610042009',
        amount: amount.toStringAsFixed(0),
        description: addInfo,
        accountName: 'NGUYEN HOANG GIANG',
      );
      return EmvBuilder.build(emvData);
    } catch (_) {
      return 'TPBANK|68610042009|NGUYEN HOANG GIANG|${amount.toStringAsFixed(0)}|$addInfo';
    }
  }
}
