import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'login_page.dart';

void main() => runApp(const BoostPlusApp());

class BoostPlusApp extends StatelessWidget {
  const BoostPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Boost+',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
