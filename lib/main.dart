import 'dart:async';
import 'dart:ui';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'traduccions.dart';
import 'pantalles/acces.dart';
import 'pantalles/configuracio.dart';
import 'pantalles/gestor.dart';
import 'pantalles/profe.dart';
import 'pantalles/soci.dart';
import 'estat.dart';
import 'estils.dart';
import 'ginys.dart';
import 'pont.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Socis',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('ca'), Locale('es')],
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
    );
  }
}

class Arrel extends StatefulWidget {
  const Arrel({super.key});

  @override
  State<Arrel> createState() => _ArrelState();
}

class _ArrelState extends State<Arrel> {
  late StreamSubscription<void> _sub;
  late StreamSubscription<html.PopStateEvent> _popSub;

  @override
  void initState() {
    super.initState();
    _sub = Estat.i.onCanvi.listen((_) => mounted ? setState(() {}) : null);
    _popSub = html.window.onPopState.listen((_) => Estat.i.onPopState());
  }

  @override
  void dispose() {
    _sub.cancel();
    _popSub.cancel();
    super.dispose();
  }

  Widget _vista(String v) {
    switch (v) {
      case 'login':
        return const IniciSessioPantalla();
      case 'registre':
        return const RegistrePantalla();
      case 'selector':
        return const SelectorPantalla();
      case 'iniciSoci':
        return const IniciSociPantalla();
      case 'classesInici':
        return const ClassesIniciPantalla();
      case 'classesAlta':
        return const ClassesAltaPantalla();
      case 'classesAlumnes':
        return const ClassesAlumnesPantalla();
      case 'trimestres':
        return TrimestresPantalla(alumneId: Estat.i.vistaActual.dades as String);
      case 'fitxaInici':
        return const FitxaIniciPantalla();
      case 'jugadorAlta':
        return const JugadorAltaPantalla();
      case 'jugadors':
        return const JugadorsPantalla();
      case 'jugadorAnys':
        return JugadorAnysPantalla(jugadorId: Estat.i.vistaActual.dades as String);
      case 'profe':
        return const ProfePantalla();
      case 'profeAlumnes':
        return const ProfeAlumnesPantalla();
      case 'adminInici':
        return const AdminIniciPantalla();
      case 'escola':
        return const EscolaPantalla();
      case 'pagat':
        return const PagatPantalla();
      case 'edicioSoci':
        return EdicioSociPantalla(sociId: Estat.i.vistaActual.dades as String);
      case 'jugEdit':
        final d = (Estat.i.vistaActual.dades as Map).cast<String, dynamic>();
        return JugadorEdicioPantalla(jugadorId: d['id'] as String, sociId: d['sociId'] as String);
      case 'alumneEdit':
        final d = (Estat.i.vistaActual.dades as Map).cast<String, dynamic>();
        return AlumneEdicioPantalla(alumneId: d['id'] as String, sociId: d['sociId'] as String);
      case 'altaRapida':
        return const AltaRapidaPantalla();
      case 'config':
        return const ConfiguracioPantalla();
      default:
        return const IniciSessioPantalla();
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final vista = st.vistaActual;
    return Scaffold(
      appBar: _appBar(vista.nom),
      body: Stack(
        children: [
          KeyedSubtree(key: ValueKey('${vista.nom}#${st.stack.length}#${Traduccions.instance.lang}'), child: _vista(vista.nom)),
          if (st.ocupats > 0)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (st.toastMissatge != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: st.toastCorrecte ? verd : vermell,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 8)],
                  ),
                  child: Text(st.toastMissatge ?? '',
                      style: estilToast,
                      textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _appBar(String v) {
    if (v == 'login' || v == 'selector') return null;
    if (v == 'registre') return Capcalera(torna: true, tancaSessio: false);
    return Capcalera(torna: !const ['iniciSoci', 'classesInici', 'fitxaInici', 'adminInici', 'profe'].contains(v));
  }
}
