import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'models/vehicle.dart';
import 'models/maintenance.dart';

import 'screens/login_page.dart';
import 'screens/app_shell.dart';
import 'screens/parts_page.dart';
import 'screens/signup_page.dart';
import 'screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // inicia o hive
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(VehicleAdapter());
    Hive.registerAdapter(MaintenanceItemAdapter());
    Hive.registerAdapter(MaintenanceAdapter());
    await Hive.openBox<Vehicle>('vehicles');
    await Hive.openBox<Maintenance>('maintenances');
    await Hive.openBox<bool>('notified_parts');
  } catch (e) {
    debugPrint('Erro ao inicializar o Hive: $e');
  }

  // inicia as notificacoes
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Erro ao inicializar notificacoes: $e');
  }

  // inicia o firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Erro ao inicializar o Firebase: $e');
  }
  
  // popula banco de teste
  final backendService = BackendService();
  try {
    await backendService.seedDatabase();
  } catch (e) {
    debugPrint('Aviso: Não foi possível semear o banco de dados (regras de segurança restritivas): $e');
  }

  runApp(const BoostPlusApp());
}

class BoostPlusApp extends StatefulWidget {
  const BoostPlusApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _BoostPlusAppState? state = context.findAncestorStateOfType<_BoostPlusAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<BoostPlusApp> createState() => _BoostPlusAppState();
}

class _BoostPlusAppState extends State<BoostPlusApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Boost+',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', ''), // portugues
            Locale('en', ''), // ingles
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/home': (context) => const AppShell(),
            '/parts': (context) => const PartsPage(),
            '/signup': (context) => const SignUpPage(),
          },
        );
      },
    );
  }
}

