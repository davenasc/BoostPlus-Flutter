import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String id;
  final String categoryId;
  final String mechanicId;
  final DateTime serviceDate;
  final int kmAtService;
  final String partSpecification;
  final int validKm;
  final int validMonths;
  final String observations;

  Maintenance({
    required this.id,
    required this.categoryId,
    required this.mechanicId,
    required this.serviceDate,
    required this.kmAtService,
    required this.partSpecification,
    required this.validKm,
    required this.validMonths,
    required this.observations,
  });

  factory Maintenance.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Maintenance(
      id: documentId,
      categoryId: data['id_categoria'] ?? '',
      mechanicId: data['id_mecanico'] ?? '',
      serviceDate: data['data_servico'] != null ? (data['data_servico'] as Timestamp).toDate() : DateTime.now(),
      kmAtService: data['km_no_servico'] ?? 0,
      partSpecification: data['especificacao_peca'] ?? '',
      validKm: data['validade_km'] ?? 0,
      validMonths: data['validade_meses'] ?? 0,
      observations: data['observacoes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_categoria': categoryId,
      'id_mecanico': mechanicId,
      'data_servico': Timestamp.fromDate(serviceDate),
      'km_no_servico': kmAtService,
      'especificacao_peca': partSpecification,
      'validade_km': validKm,
      'validade_meses': validMonths,
      'observacoes': observations,
    };
  }
}
