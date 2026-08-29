import 'dart:async';
import 'dart:ui';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'traduccions.dart';
import 'estat.dart';
import 'estils.dart';
import 'pantalles/ruta.dart';
import 'pont.dart';
import 'serveis/estat_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled: $error');
    return true;
  };
  Pont.instance.init(urlAppsScript);
  unawaited(Estat.i.arrenca());
  runApp(const PortalApp());
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});
  static final _estatNotifier = EstatNotifier(Estat.i);

  static const _isoIdiomes = {
    'CA': 'ca', 'ES': 'es', 'EN': 'en', 'FR': 'fr', 'DE': 'de', 'IT': 'it',
    'PT': 'pt', 'GL': 'gl', 'EU': 'eu', 'OC': 'oc', 'NL': 'nl', 'PL': 'pl',
  };

  List<Locale> _localesDisponibles() {
    final out = <Locale>[];
    for (final l in Traduccions.instance.langs) {
      final iso = _isoIdiomes[l];
      if (iso != null) out.add(Locale(iso));
    }
    if (out.isEmpty) out.add(const Locale('es'));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return EstatScope(
      notifier: _estatNotifier,
      child: MaterialApp(
      title: 'Portal Socis',
      debugShowCheckedModeBanner: false,
      navigatorKey: Estat.i.navigatorKey,
      supportedLocales: _localesDisponibles(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: pri, primary: pri),
        scaffoldBackgroundColor: suau,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: titol,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
        ),
        tabBarTheme: TabBarThemeData(
          indicatorColor: pri,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: pri,
          unselectedLabelColor: textCol,
          overlayColor: WidgetStatePropertyAll(pri.withValues(alpha: .08)),
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: pri,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(foregroundColor: pri),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: pri),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: pri, foregroundColor: Colors.white),
      ),
      home: const Arrel(),
      ),
    );
  }
}

class Arrel extends StatelessWidget {
  const Arrel({super.key});

  @override
  Widget build(BuildContext context) => PantallaRuta(vista: Estat.i.stack.first);
}