import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double price;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  String unit;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  String? description;

  @HiveField(8)
  int lowStockThreshold;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imagePath,
    this.description,
    this.lowStockThreshold = 10,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  double get totalValue => price * quantity;

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? unit,
    String? imagePath,
    String? description,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imagePath': imagePath,
      'description': description,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      imagePath: map['imagePath'] as String?,
      description: map['description'] as String?,
      lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

