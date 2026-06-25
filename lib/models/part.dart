import 'package:flutter/material.dart';

class Part {
  final String nameKey;
  final int remainingKm;
  final double health;
  final IconData icon;

  Part({
    required this.nameKey,
    required this.remainingKm,
    required this.health,
    required this.icon,
  });
}
