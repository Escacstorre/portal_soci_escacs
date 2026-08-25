import 'dart:async';

import 'package:flutter/material.dart';

import 'i18n.dart';
import 'screens/auth.dart';
import 'screens/config.dart';
import 'screens/gestor.dart';
import 'screens/profe.dart';
import 'screens/soci.dart';
import 'state.dart';
import 'widgets.dart';
import 'bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bridge.instance.init('$appsScriptUrl?page=bridge');
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: pri),
        scaffoldBackgroundColor: suau,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
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

  @override
  void initState() {
    super.initState();
    _sub = Estat.i.onCanvi.listen((_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Widget _vista(String v) {
    switch (v) {
      case 'login':
        return const LoginScreen();
      case 'registre':
        return const RegistreScreen();
      case 'selector':
        return const SelectorScreen();
      case 'homeSoci':
        return const HomeSociScreen();
      case 'classesHome':
        return const ClassesHomeScreen();
      case 'classesAlta':
        return const ClassesAltaScreen();
      case 'classesAlumnes':
        return const ClassesAlumnesScreen();
      case 'trimestres':
        return TrimestresScreen(alumneId: Estat.i.vistaActual.dades as String);
      case 'fitxaHome':
        return const FitxaHomeScreen();
      case 'jugadorAlta':
        return const JugadorAltaScreen();
      case 'jugadors':
        return const JugadorsScreen();
      case 'jugadorAnys':
        return JugadorAnysScreen(jugadorId: Estat.i.vistaActual.dades as String);
      case 'profe':
        return const ProfeScreen();
      case 'profeAlumnes':
        return const ProfeAlumnesScreen();
      case 'adminHome':
        return const AdminHomeScreen();
      case 'escola':
        return const EscolaScreen();
      case 'pagat':
        return const PagatScreen();
      case 'edicioSoci':
        return EdicioSociScreen(sociId: Estat.i.vistaActual.dades as String);
      case 'jugEdit':
        final d = (Estat.i.vistaActual.dades as Map).cast<String, dynamic>();
        return JugEditScreen(jugadorId: d['id'] as String, sociId: d['sociId'] as String);
      case 'alumneEdit':
        final d = (Estat.i.vistaActual.dades as Map).cast<String, dynamic>();
        return AlumneEditScreen(alumneId: d['id'] as String, sociId: d['sociId'] as String);
      case 'altaRapida':
        return const AltaRapidaScreen();
      case 'config':
        return const ConfigScreen();
      default:
        return const LoginScreen();
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
          KeyedSubtree(key: ValueKey('${vista.nom}#${st.stack.length}#${I18n.instance.lang}'), child: _vista(vista.nom)),
          if (st.ocupats > 0)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (st.toastMsg != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: st.toastOk ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 8)],
                  ),
                  child: Text(st.toastMsg!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
    return Hdr(torna: !const ['homeSoci', 'classesHome', 'fitxaHome', 'adminHome', 'profe'].contains(v));
  }
}
