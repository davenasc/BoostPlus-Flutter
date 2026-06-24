import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import '../services/firebase_service.dart';
import '../models/maintenance.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backendService = BackendService();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Boost+', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(l10n.historyMaintenanceHistory, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ValueListenableBuilder<String?>(
        valueListenable: BackendService.selectedVehicleIdNotifier,
        builder: (context, selectedVehicleId, child) {
          if (selectedVehicleId == null) {
            return Center(
              child: Text(
                l10n.historyNoVehicleSelected,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return StreamBuilder<List<Maintenance>>(
            stream: backendService.getMaintenances(selectedVehicleId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return Center(
                  child: Text(
                    l10n.historyNoHistoryFound,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final maintenance = history[index];
                  return _buildHistoryCard(context, maintenance, l10n);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Maintenance maintenance, AppLocalizations l10n) {
    final formattedDate = DateFormat('dd MMM yyyy').format(maintenance.serviceDate);
    final itemsSummary = maintenance.items
        .map((item) => _getCategoryName(item.categoryId, l10n))
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showOSDetailsBottomSheet(context, maintenance, l10n),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maintenance.osNumber.isNotEmpty
                              ? l10n.historyOSWithNumber(maintenance.osNumber)
                              : l10n.historyOS,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedDate · ${maintenance.kmAtService} km',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          itemsSummary,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOSDetailsBottomSheet(BuildContext context, Maintenance maintenance, AppLocalizations l10n) {
    final formattedDate = DateFormat('dd MMM yyyy').format(maintenance.serviceDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra superior arrastável
              Center(
                child: Container(
                  height: 6,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cabeçalho
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maintenance.osNumber.isNotEmpty
                              ? l10n.historyOSWithNumber(maintenance.osNumber)
                              : l10n.historyOSDetails,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$formattedDate · no KM ${maintenance.kmAtService}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Informações Gerais (Mecânico)
              Row(
                children: [
                  const Icon(Icons.build_circle_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    l10n.historyMechanic(maintenance.mechanicId),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Observações gerais do mecânico
              if (maintenance.observations.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          maintenance.observations,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Título Seção Itens
              Text(
                l10n.historyReplacedParts,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Lista de peças trocadas
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: maintenance.items.length,
                  itemBuilder: (context, idx) {
                    final item = maintenance.items[idx];
                    final name = _getCategoryName(item.categoryId, l10n);
                    final icon = _getCategoryIcon(item.categoryId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.partSpecification,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.historyValidity(item.validKm.toString(), item.validMonths.toString()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryName(String categoryId, AppLocalizations l10n) {
    switch (categoryId) {
      case 'cat_oleo':
        return l10n.partOilChange;
      case 'cat_freio':
        return l10n.partBrakePads;
      case 'cat_pneu':
        return l10n.partTires;
      case 'cat_bateria':
        return l10n.partBattery;
      case 'cat_filtros':
        return l10n.partFilters;
      case 'cat_arrefecimento':
        return l10n.partCooling;
      default:
        return categoryId;
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_oleo':
        return Icons.water_drop_outlined;
      case 'cat_freio':
        return Icons.album_outlined;
      case 'cat_pneu':
        return Icons.circle_outlined;
      case 'cat_bateria':
        return Icons.battery_charging_full;
      case 'cat_filtros':
        return Icons.filter_alt_outlined;
      case 'cat_arrefecimento':
        return Icons.thermostat_outlined;
      default:
        return Icons.build_outlined;
    }
  }
}
