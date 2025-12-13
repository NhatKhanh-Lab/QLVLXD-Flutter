// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseOrderAdapter extends TypeAdapter<PurchaseOrder> {
  @override
  final int typeId = 5;

  @override
  PurchaseOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseOrder(
      id: fields[0] as String,
      orderNumber: fields[1] as String,
      supplierId: fields[2] as String,
      supplierName: fields[3] as String?,
      items: (fields[4] as List).cast<InvoiceItem>(),
      subtotal: fields[5] as double,
      total: fields[6] as double,
      orderDate: fields[7] as DateTime,
      receivedDate: fields[8] as DateTime?,
      status: fields[9] as String,
      notes: fields[10] as String?,
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrder obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.supplierId)
      ..writeByte(3)
      ..write(obj.supplierName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.subtotal)
      ..writeByte(6)
      ..write(obj.total)
      ..writeByte(7)
      ..write(obj.orderDate)
      ..writeByte(8)
      ..write(obj.receivedDate)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
