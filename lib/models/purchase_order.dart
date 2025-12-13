import 'package:hive/hive.dart';
import 'invoice_item.dart';

part 'purchase_order.g.dart';

@HiveType(typeId: 5)
class PurchaseOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String orderNumber;

  @HiveField(2)
  String supplierId;

  @HiveField(3)
  String? supplierName;

  @HiveField(4)
  List<InvoiceItem> items;

  @HiveField(5)
  double subtotal;

  @HiveField(6)
  double total;

  @HiveField(7)
  DateTime orderDate;

  @HiveField(8)
  DateTime? receivedDate;

  @HiveField(9)
  String status; // 'pending', 'received', 'cancelled'

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    this.supplierName,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.orderDate,
    this.receivedDate,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
  });

  PurchaseOrder copyWith({
    String? id,
    String? orderNumber,
    String? supplierId,
    String? supplierName,
    List<InvoiceItem>? items,
    double? subtotal,
    double? total,
    DateTime? orderDate,
    DateTime? receivedDate,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      receivedDate: receivedDate ?? this.receivedDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'] as String,
      orderNumber: map['orderNumber'] as String,
      supplierId: map['supplierId'] as String,
      supplierName: map['supplierName'] as String?,
      items: (map['items'] as List)
          .map((item) => InvoiceItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      orderDate: DateTime.parse(map['orderDate'] as String),
      receivedDate: map['receivedDate'] != null
          ? DateTime.parse(map['receivedDate'] as String)
          : null,
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

