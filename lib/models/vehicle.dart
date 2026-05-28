class Vehicle {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final int currentKm;

  Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentKm,
  });

  factory Vehicle.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Vehicle(
      id: documentId,
      plate: data['placa'] ?? '',
      brand: data['marca'] ?? '',
      model: data['modelo'] ?? '',
      year: data['ano'] ?? 0,
      currentKm: data['km_atual'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'placa': plate,
      'marca': brand,
      'modelo': model,
      'ano': year,
      'km_atual': currentKm,
    };
  }
}
