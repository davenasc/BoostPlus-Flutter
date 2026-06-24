import 'package:flutter/material.dart';
import '../models/part.dart';
import '../models/maintenance.dart';

class PartCalculator {
  static List<Part> calculatePartsStatus(List<Maintenance> history, int currentKm) {
    final categories = [
      {
        'id': 'cat_oleo',
        'nameKey': 'partOilChange',
        'icon': Icons.water_drop_outlined,
      },
      {
        'id': 'cat_freio',
        'nameKey': 'partBrakePads',
        'icon': Icons.album_outlined,
      },
      {
        'id': 'cat_pneu',
        'nameKey': 'partTires',
        'icon': Icons.circle_outlined,
      },
      {
        'id': 'cat_bateria',
        'nameKey': 'partBattery',
        'icon': Icons.battery_charging_full,
      },
      {
        'id': 'cat_filtros',
        'nameKey': 'partFilters',
        'icon': Icons.filter_alt_outlined,
      },
      {
        'id': 'cat_arrefecimento',
        'nameKey': 'partCooling',
        'icon': Icons.thermostat_outlined,
      },
    ];

    List<Part> partsList = [];
    final now = DateTime.now();

    for (final cat in categories) {
      final catId = cat['id'] as String;
      final nameKey = cat['nameKey'] as String;
      final icon = cat['icon'] as IconData;

      MaintenanceItem? latestItem;
      DateTime? latestServiceDate;
      int latestKmAtService = 0;

      for (final maint in history) {
        for (final item in maint.items) {
          if (item.categoryId == catId) {
            if (latestServiceDate == null || maint.serviceDate.isAfter(latestServiceDate)) {
              latestServiceDate = maint.serviceDate;
              latestItem = item;
              latestKmAtService = maint.kmAtService;
            }
          }
        }
      }

      if (latestItem != null && latestServiceDate != null) {
        // calcula por km
        final limiteKm = latestKmAtService + latestItem.validKm;
        int kmRestante = limiteKm - currentKm;
        if (kmRestante < 0) kmRestante = 0;

        double saudeKm = latestItem.validKm > 0 
            ? kmRestante / latestItem.validKm 
            : 0.0;
        saudeKm = saudeKm.clamp(0.0, 1.0);

        // calcula por tempo em meses
        final totalDays = latestItem.validMonths * 30;
        final dataLimite = latestServiceDate.add(Duration(days: totalDays));
        final diasRestantes = dataLimite.difference(now).inDays;
        
        double saudeTempo = totalDays > 0 
            ? diasRestantes / totalDays 
            : 0.0;
        saudeTempo = saudeTempo.clamp(0.0, 1.0);

        // pega o menor resultado
        final saudeFinal = saudeKm < saudeTempo ? saudeKm : saudeTempo;

        partsList.add(Part(
          nameKey: nameKey,
          remainingKm: kmRestante,
          health: saudeFinal,
          icon: icon,
        ));
      }
    }

    return partsList;
  }
}
