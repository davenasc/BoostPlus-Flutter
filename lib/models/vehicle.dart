class Vehicle {
  final int? id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final int currentKm;
  final String? customerId;

  Vehicle({
    this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentKm,
    this.customerId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id_veiculo'],
      plate: json['placa'],
      brand: json['marca'],
      model: json['modelo'],
      year: json['ano'],
      currentKm: json['km_atual'],
      customerId: json['id_cliente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': plate,
      'marca': brand,
      'modelo': model,
      'ano': year,
      'km_atual': currentKm,
      if (customerId != null) 'id_cliente': customerId,
    };
  }
}
