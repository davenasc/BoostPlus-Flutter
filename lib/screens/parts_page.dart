import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import '../services/firebase_service.dart';
import '../services/part_calculator.dart';
import '../models/maintenance.dart';
import '../models/vehicle.dart';
import '../models/part.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backendService = BackendService();

    return ValueListenableBuilder<String?>(
      valueListenable: BackendService.selectedVehicleIdNotifier,
      builder: (context, selectedVehicleId, child) {
        if (selectedVehicleId == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.partsAllParts, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            body: const Center(
              child: Text('Nenhum veículo selecionado.'),
            ),
          );
        }

        return StreamBuilder<List<Vehicle>>(
          stream: backendService.getVehicles(),
          builder: (context, vehiclesSnapshot) {
            if (vehiclesSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (vehiclesSnapshot.hasError) {
              return Scaffold(body: Center(child: Text('Erro: ${vehiclesSnapshot.error}')));
            }

            final vehicles = vehiclesSnapshot.data ?? [];
            final vehicle = vehicles.firstWhere(
              (v) => v.id == selectedVehicleId,
              orElse: () => Vehicle(
                id: selectedVehicleId,
                plate: '',
                brand: '',
                model: 'Veículo',
                year: 0,
                currentKm: 0,
                customerId: '',
              ),
            );

            return StreamBuilder<List<Maintenance>>(
              stream: backendService.getMaintenances(selectedVehicleId),
              builder: (context, maintenanceSnapshot) {
                if (maintenanceSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (maintenanceSnapshot.hasError) {
                  return Scaffold(body: Center(child: Text('Erro: ${maintenanceSnapshot.error}')));
                }

                final history = maintenanceSnapshot.data ?? [];
                final List<Part> parts = PartCalculator.calculatePartsStatus(history, vehicle.currentKm);

                return Scaffold(
                  appBar: AppBar(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${vehicle.brand} ${vehicle.model} · ${vehicle.plate}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(l10n.partsAllParts, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  body: parts.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma manutenção cadastrada para este veículo.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: parts.length,
                    itemBuilder: (context, index) {
                      final part = parts[index];
                      final name = _getLocalizedPartName(part.nameKey, l10n);

                      return _buildPartItem(
                        name,
                        l10n.partRemaining(part.remainingKm.toString()),
                        part.icon,
                        part.health,
                        context,
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getLocalizedPartName(String nameKey, AppLocalizations l10n) {
    switch (nameKey) {
      case 'partOilChange':
        return l10n.partOilChange;
      case 'partBrakePads':
        return l10n.partBrakePads;
      case 'partTires':
        return l10n.partTires;
      case 'partBattery':
        return l10n.partBattery;
      case 'partFilters':
        return l10n.partFilters;
      case 'partCooling':
        return l10n.partCooling;
      default:
        return nameKey;
    }
  }

  Widget _buildPartItem(
    String label,
    String sub,
    IconData icon,
    double health,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isHealthy = health >= 0.5;
    final statusColor = isHealthy ? Colors.green : Colors.orange;
    final statusText = isHealthy ? l10n.partStatusOk : l10n.partStatusWarning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: health,
                  strokeWidth: 6,
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Center(
                  child: Icon(icon, color: colorScheme.onSurface, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
