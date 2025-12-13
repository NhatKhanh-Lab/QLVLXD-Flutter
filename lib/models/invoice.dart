import 'package:hive/hive.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

@HiveType(typeId: 2)
class Invoice extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNumber;

  @HiveField(2)
  List<InvoiceItem> items;

  @HiveField(3)
  double subtotal;

  @HiveField(4)
  double vat;

  @HiveField(5)
  double total;

  @HiveField(6)
  String? customerName;

  @HiveField(7)
  String? customerPhone;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? notes;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.total,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
    this.notes,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    List<InvoiceItem>? items,
    double? subtotal,
    double? vat,
    double? total,
    String? customerName,
    String? customerPhone,
    DateTime? createdAt,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'total': total,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoiceNumber'] as String,
      items: (map['items'] as List)
          .map((item) => InvoiceItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      vat: (map['vat'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      customerName: map['customerName'] as String?,
      customerPhone: map['customerPhone'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String?,
    );
  }
}

