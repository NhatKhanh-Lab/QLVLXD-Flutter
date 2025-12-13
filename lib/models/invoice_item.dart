import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 1)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double total;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  InvoiceItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? total,
  }) {
    return InvoiceItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'total': total,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      total: (map['total'] as num).toDouble(),
    );
  }
}

