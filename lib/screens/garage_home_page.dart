import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' show PathMetric;
import 'package:boost_plus/l10n/app_localizations.dart';
import '../widgets/update_km_dialog.dart';
import '../widgets/add_vehicle_dialog.dart';
import '../services/firebase_service.dart';
import '../models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/part.dart';
import '../services/part_calculator.dart';

class GarageHomePage extends StatefulWidget {
  const GarageHomePage({super.key});

  @override
  State<GarageHomePage> createState() => _GarageHomePageState();
}

class _GarageHomePageState extends State<GarageHomePage> {
  final BackendService _backendService = BackendService();
  int _selectedVehicleIndex = 0;
  late Stream<List<Vehicle>> _vehiclesStream;
  String? _cachedVehicleId;
  Stream<List<Maintenance>>? _cachedMaintenanceStream;

  Stream<List<Maintenance>> _getMaintenanceStream(String vehicleId) {
    if (_cachedVehicleId != vehicleId || _cachedMaintenanceStream == null) {
      _cachedVehicleId = vehicleId;
      _cachedMaintenanceStream = _backendService.getMaintenances(vehicleId);
    }
    return _cachedMaintenanceStream!;
  }

  @override
  void initState() {
    super.initState();
    _vehiclesStream = _backendService.getVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Vehicle>>(
      stream: _vehiclesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Erro: ${snapshot.error}')));
        }
        
        final veiculos = snapshot.data ?? [];
        if (veiculos.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Boost+', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(l10n.garageMyGarage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: _buildAddVehicleCard(context, colorScheme),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    l10n.historyNoVehicleSelected,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                const MaintenanceTipsSection(),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        if (_selectedVehicleIndex >= veiculos.length) {
          _selectedVehicleIndex = 0;
        }
        final veiculoSelecionado = veiculos[_selectedVehicleIndex];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (BackendService.selectedVehicleIdNotifier.value != veiculoSelecionado.id) {
            BackendService.selectedVehicleIdNotifier.value = veiculoSelecionado.id;
          }
        });

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Boost+', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(l10n.garageMyGarage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              // lista de carros
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: veiculos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == veiculos.length) {
                      return _buildAddVehicleCard(context, colorScheme);
                    }
                    final veiculo = veiculos[index];
                    return _buildVehicleCard(
                      veiculo,
                      0.8, // colocar saude de verdade depois
                      colorScheme,
                      index == _selectedVehicleIndex,
                      context,
                      () {
                        setState(() {
                          _selectedVehicleIndex = index;
                        });
                        BackendService.selectedVehicleIdNotifier.value = veiculo.id;
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // cartao do hodometro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.garageOdometer, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('${veiculoSelecionado.currentKm} km', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${veiculoSelecionado.brand} ${veiculoSelecionado.model} · ${veiculoSelecionado.plate}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // cabecalho de pecas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.garagePartStatus, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/parts');
                      },
                      child: Text(l10n.garageSeeAll),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // grade de pecas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<Maintenance>>(
                  stream: _getMaintenanceStream(veiculoSelecionado.id),
                  builder: (context, maintSnapshot) {
                    if (maintSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final history = maintSnapshot.data ?? [];
                    final List<Part> parts = PartCalculator.calculatePartsStatus(history, veiculoSelecionado.currentKm);

                    if (parts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Nenhuma manutenção cadastrada para este veículo.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    // ordena pecas pela saude
                    parts.sort((a, b) => a.health.compareTo(b.health));
                    final criticalParts = parts.take(2).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: criticalParts.length,
                      itemBuilder: (context, index) {
                        final part = criticalParts[index];
                        final name = _getLocalizedPartName(part.nameKey, l10n);

                        return _buildPartItem(
                          name,
                          l10n.partRemaining(part.remainingKm.toString()),
                          part.icon,
                          part.health,
                          context,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // dicas de manutencao
              const MaintenanceTipsSection(),
              const SizedBox(height: 40),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              UpdateKmDialog.show(context, veiculoSelecionado.currentKm, (newKm) async {
                await _backendService.atualizarOdometro(veiculoSelecionado.id, newKm, l10n: l10n);
              });
            },
            icon: const Icon(Icons.speed),
            label: Text(l10n.garageUpdateKm),
          ),
        );
      }
    );
  }

  Widget _buildVehicleCard(
    Vehicle veiculo,
    double health,
    ColorScheme colorScheme,
    bool active,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: active
              ? Border.all(color: colorScheme.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.directions_car, color: colorScheme.primary),
                Text(
                  veiculo.plate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              veiculo.year.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            Text(
              veiculo.model,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: health,
              backgroundColor: Colors.grey[200],
              color: health < 0.5 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
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

  Widget _buildAddVehicleCard(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _mostrarDialogoAdicionarVeiculo(context),
      child: Container(
        width: 182,
        height: 182,
        margin: const EdgeInsets.all(4),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: colorScheme.primary.withValues(alpha: 0.4),
            borderRadius: 28,
            dash: 6,
            gap: 4,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 36, color: colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  l10n.garageAddVehicle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAdicionarVeiculo(BuildContext context) {
    AddVehicleDialog.show(context, () {
      setState(() {
        _vehiclesStream = _backendService.getVehicles();
      });
    });
  }
}

class MaintenanceTipsSection extends StatefulWidget {
  const MaintenanceTipsSection({super.key});

  @override
  State<MaintenanceTipsSection> createState() => _MaintenanceTipsSectionState();
}

class _MaintenanceTipsSectionState extends State<MaintenanceTipsSection> {
  int _currentTipIndex = 0;
  late Timer _timer;

  List<String> _getTips(AppLocalizations l10n) {
    return [
      l10n.garageTips1,
      l10n.garageTips2,
      l10n.garageTips3,
      l10n.garageTips4,
    ];
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tips = _getTips(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.garageMaintenanceTips,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                tips[_currentTipIndex],
                key: ValueKey<int>(_currentTipIndex),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 4.0,
    this.dash = 6.0,
    this.borderRadius = 28.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dash : gap;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dash != dash ||
        oldDelegate.borderRadius != borderRadius;
  }
}

