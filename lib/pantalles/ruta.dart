import 'dart:async';

import 'package:flutter/material.dart';

import '../estat.dart';
import '../estils.dart';
import '../ginys.dart';
import 'acces.dart';
import 'configuracio.dart';
import 'gestor.dart';
import 'profe.dart';
import 'soci.dart';

class PantallaRuta extends StatefulWidget {
  const PantallaRuta({super.key, required this.vista});
  final Vista vista;

  @override
  State<PantallaRuta> createState() => _PantallaRutaState();
}

class _PantallaRutaState extends State<PantallaRuta> {
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

  Widget _vista(Vista v) {
    switch (v.nom) {
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
        return TrimestresPantalla(alumneId: v.dades as String);
      case 'fitxaInici':
        return const FitxaIniciPantalla();
      case 'jugadorAlta':
        return const JugadorAltaPantalla();
      case 'jugadors':
        return const JugadorsPantalla();
      case 'jugadorAnys':
        return JugadorAnysPantalla(jugadorId: v.dades as String);
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
        return EdicioSociPantalla(sociId: v.dades as String);
      case 'jugEdit':
        final d = (v.dades as Map).cast<String, dynamic>();
        return JugadorEdicioPantalla(jugadorId: d['id'] as String, sociId: d['sociId'] as String);
      case 'alumneEdit':
        final d = (v.dades as Map).cast<String, dynamic>();
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
    final nom = widget.vista.nom;
    final mostraCap = nom != 'login' && nom != 'selector';
    return Scaffold(
      appBar: mostraCap
          ? Capcalera(torna: Navigator.canPop(context), tancaSessio: nom != 'registre')
          : null,
      body: Stack(
        children: [
          KeyedSubtree(
            key: ValueKey('$nom#${st.i18n.lang}'),
            child: _vista(widget.vista),
          ),
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
}