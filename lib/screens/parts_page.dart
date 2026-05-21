import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Honda Civic · ABC-1234', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(l10n.partsAllParts, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _buildPartItem(l10n.partOilChange, l10n.partRemaining('6,770'), Icons.water_drop_outlined, 0.75, context),
          _buildPartItem(l10n.partBrakePads, l10n.partRemaining('6,770'), Icons.album_outlined, 0.40, context),
          _buildPartItem(l10n.partTires, l10n.partRemaining('3,770'), Icons.circle_outlined, 0.60, context),
          _buildPartItem(l10n.partBattery, l10n.partRemaining('31,770'), Icons.battery_charging_full, 0.85, context),
          _buildPartItem(l10n.partFilters, l10n.partRemaining('11,770'), Icons.filter_alt_outlined, 0.90, context),
          _buildPartItem(l10n.partCooling, l10n.partRemaining('11,770'), Icons.thermostat_outlined, 0.80, context),
        ],
      ),
    );
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
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
                  backgroundColor: statusColor.withOpacity(0.2),
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
              color: statusColor.withOpacity(0.1),
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
