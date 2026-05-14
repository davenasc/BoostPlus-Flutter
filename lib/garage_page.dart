import 'package:flutter/material.dart';
import 'dart:async';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  int _currentTipIndex = 0;
  late Timer _timer;

  final List<String> _tips = [
    "Verifique a pressão dos pneus a cada 15 dias.",
    "Troque o óleo do motor a cada 10.000 km.",
    "Verifique o nível do fluido de freio mensalmente.",
    "Faça o rodízio dos pneus para garantir um desgaste uniforme.",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildVehicleList(colorScheme),
              _buildOdometerCard(colorScheme),
              _buildPartsStatusHeader(),
              _buildPartsGrid(colorScheme),
              _buildMaintenanceTips(colorScheme),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.speed),
        label: const Text("Atualizar KM"),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            label: 'Garagem',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seu veículo, mais saudável.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 14),
          ),
          Text(
            "Minha Garagem",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(ColorScheme colorScheme) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildVehicleCard(
            "Honda Civic",
            "BST-2049",
            "2022",
            0.47,
            colorScheme,
            true,
          ),
          _buildVehicleCard(
            "Toyota Corolla",
            "GO-7732",
            "2020",
            0.32,
            colorScheme,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    String model,
    String plate,
    String year,
    double health,
    ColorScheme colorScheme,
    bool active,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: active
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
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
              const Icon(Icons.directions_car, color: Colors.blueAccent),
              Text(
                plate,
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
            year,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          Text(
            model,
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
    );
  }

  Widget _buildOdometerCard(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Odômetro atual",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              "48,230 km",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Honda Civic · BST-2049",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartsStatusHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Status das peças",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "Ver tudo",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsGrid(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildPartItem(
            "Óleo Motor",
            "6.770 km restantes",
            Icons.opacity,
            colorScheme,
          ),
          _buildPartItem(
            "Freios",
            "6.770 km restantes",
            Icons.album_outlined,
            colorScheme,
          ),
          _buildPartItem(
            "Pneus",
            "3.770 km restantes",
            Icons.circle_outlined,
            colorScheme,
          ),
          _buildPartItem(
            "Bateria",
            "31.770 km restantes",
            Icons.battery_charging_full,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPartItem(
    String label,
    String sub,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTips(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  "DICAS DE MANUTENÇÃO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _tips[_currentTipIndex],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
