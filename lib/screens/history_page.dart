import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.historyMaintenanceHistory, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(l10n.historyTimeline, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHistoryItem(context, l10n.partOilChange, '15 Oct 2023 · at 43,500 km', 'Synthetic 5W-30', Icons.water_drop),
          _buildHistoryItem(context, l10n.partBrakePads, '10 Jan 2023 · at 38,000 km', 'Front only', Icons.adjust),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String subtitle, String specs, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(specs, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
