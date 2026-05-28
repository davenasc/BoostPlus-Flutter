import 'package:flutter/material.dart';
import 'dart:async';
import 'package:boost_plus/l10n/app_localizations.dart';
import '../widgets/update_km_dialog.dart';
import '../services/firebase_service.dart';
import '../models/vehicle.dart';

class GarageHomePage extends StatefulWidget {
  const GarageHomePage({super.key});

  @override
  State<GarageHomePage> createState() => _GarageHomePageState();
}

class _GarageHomePageState extends State<GarageHomePage> {
  int _currentTipIndex = 0;
  late Timer _timer;
  final BackendService _backendService = BackendService();
  int _selectedVehicleIndex = 0;

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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Vehicle>>(
      stream: _backendService.getVehicles(),
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.garageVehicleMaintenance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(l10n.garageMyGarage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            body: const Center(child: Text('Nenhum veículo encontrado.')),
          );
        }

        if (_selectedVehicleIndex >= veiculos.length) {
          _selectedVehicleIndex = 0;
        }
        final veiculoSelecionado = veiculos[_selectedVehicleIndex];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.garageVehicleMaintenance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(l10n.garageMyGarage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              // Vehicles List
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: veiculos.length,
                  itemBuilder: (context, index) {
                    final veiculo = veiculos[index];
                    return _buildVehicleCard(
                      veiculo,
                      0.8, // TODO: Calcular saúde real do veículo depois
                      colorScheme,
                      index == _selectedVehicleIndex,
                      context,
                      () {
                        setState(() {
                          _selectedVehicleIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Odometer Card
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
              
              // Parts Overview Header
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
              
              // Parts Grid (Static for now, will update in PartsPage / later)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildPartItem(l10n.partOilChange, l10n.partRemaining('1,500'), Icons.water_drop_outlined, 0.75, context),
                    _buildPartItem(l10n.partBrakePads, l10n.partRemaining('12,000'), Icons.album_outlined, 0.40, context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Maintenance Tips
              _buildMaintenanceTips(context),
              const SizedBox(height: 40),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              UpdateKmDialog.show(context, veiculoSelecionado.currentKm, (newKm) async {
                await _backendService.atualizarOdometro(veiculoSelecionado.id, newKm);
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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

  Widget _buildMaintenanceTips(BuildContext context) {
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
