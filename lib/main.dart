import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boost_plus/l10n/app_localizations.dart';

import 'screens/login_page.dart';
import 'screens/app_shell.dart';
import 'screens/parts_page.dart';

void main() => runApp(const BoostPlusApp());

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
            Locale('pt', ''), // Portuguese
            Locale('en', ''), // English
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/home': (context) => const AppShell(),
            '/parts': (context) => const PartsPage(),
          },
        );
      },
    );
  }
}

