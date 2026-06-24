import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'maintenance.g.dart';

@HiveType(typeId: 2)
class MaintenanceItem {
  @HiveField(0)
  final String categoryId;

  @HiveField(1)
  final String partSpecification;

  @HiveField(2)
  final int validKm;

  @HiveField(3)
  final int validMonths;

  MaintenanceItem({
    required this.categoryId,
    required this.partSpecification,
    required this.validKm,
    required this.validMonths,
  });

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) {
    return MaintenanceItem(
      categoryId: map['id_categoria'] ?? '',
      partSpecification: map['especificacao_peca'] ?? '',
      validKm: map['validade_km'] ?? 0,
      validMonths: map['validade_meses'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_categoria': categoryId,
      'especificacao_peca': partSpecification,
      'validade_km': validKm,
      'validade_meses': validMonths,
    };
  }
}

@HiveType(typeId: 1)
class Maintenance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String mechanicId;

  @HiveField(2)
  final DateTime serviceDate;

  @HiveField(3)
  final int kmAtService;

  @HiveField(4)
  final String observations;

  @HiveField(5)
  final String osNumber;

  @HiveField(6)
  final List<MaintenanceItem> items;

  @HiveField(7)
  final String vehicleId;

  Maintenance({
    required this.id,
    required this.mechanicId,
    required this.serviceDate,
    required this.kmAtService,
    required this.observations,
    required this.osNumber,
    required this.items,
    required this.vehicleId,
  });

  factory Maintenance.fromFirestore(Map<String, dynamic> data, String documentId, {String vehicleId = ''}) {
    List<MaintenanceItem> parsedItems = [];
    if (data['itens'] != null) {
      final List<dynamic> rawItens = data['itens'];
      parsedItems = rawItens
          .map((item) => MaintenanceItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      // Fallback para manter compatibilidade com registros antigos do banco
      parsedItems = [
        MaintenanceItem(
          categoryId: data['id_categoria'] ?? '',
          partSpecification: data['especificacao_peca'] ?? '',
          validKm: data['validade_km'] ?? 0,
          validMonths: data['validade_meses'] ?? 0,
        )
      ];
    }

    return Maintenance(
      id: documentId,
      mechanicId: data['id_mecanico'] ?? '',
      serviceDate: data['data_servico'] != null 
          ? (data['data_servico'] as Timestamp).toDate() 
          : DateTime.now(),
      kmAtService: data['km_no_servico'] ?? 0,
      observations: data['observacoes'] ?? '',
      osNumber: data['numero_os'] ?? '',
      items: parsedItems,
      vehicleId: vehicleId.isNotEmpty ? vehicleId : (data['veiculo_id'] ?? ''),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_mecanico': mechanicId,
      'data_servico': Timestamp.fromDate(serviceDate),
      'km_no_servico': kmAtService,
      'observacoes': observations,
      'numero_os': osNumber,
      'itens': items.map((item) => item.toMap()).toList(),
      'veiculo_id': vehicleId,
    };
  }
}
