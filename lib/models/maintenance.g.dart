// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceItemAdapter extends TypeAdapter<MaintenanceItem> {
  @override
  final int typeId = 2;

  @override
  MaintenanceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceItem(
      categoryId: fields[0] as String,
      partSpecification: fields[1] as String,
      validKm: fields[2] as int,
      validMonths: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.categoryId)
      ..writeByte(1)
      ..write(obj.partSpecification)
      ..writeByte(2)
      ..write(obj.validKm)
      ..writeByte(3)
      ..write(obj.validMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaintenanceAdapter extends TypeAdapter<Maintenance> {
  @override
  final int typeId = 1;

  @override
  Maintenance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Maintenance(
      id: fields[0] as String,
      mechanicId: fields[1] as String,
      serviceDate: fields[2] as DateTime,
      kmAtService: fields[3] as int,
      observations: fields[4] as String,
      osNumber: fields[5] as String,
      items: (fields[6] as List).cast<MaintenanceItem>(),
      vehicleId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Maintenance obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mechanicId)
      ..writeByte(2)
      ..write(obj.serviceDate)
      ..writeByte(3)
      ..write(obj.kmAtService)
      ..writeByte(4)
      ..write(obj.observations)
      ..writeByte(5)
      ..write(obj.osNumber)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.vehicleId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
