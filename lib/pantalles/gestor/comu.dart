import 'dart:async';

import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../models.dart';
import '../../widgets/form_scaffold.dart';

class AdminIniciPantalla extends StatelessWidget {
  const AdminIniciPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final st = Estat.i;
    return Stack(children: [
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${t('benvingut')} ${st.user?['nom'] ?? ''}',
              style: estilTitol),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            BotoGran(titol: t('escola'), icon: Icons.school, onTap: () => st.go('escola')),
            const SizedBox(width: 12),
            BotoGran(titol: t('pagatTab'), icon: Icons.payments, onTap: () => st.go('pagat')),
          ]),
        ]),
      ),
      Positioned(
        bottom: 24,
        right: 24,
        child: FloatingActionButton(
          onPressed: () => st.go('config'),
          backgroundColor: pri,
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ),
    ]);
  }
}

Future<GestorDades> carregaGestor() async {
  final st = Estat.i;
  final g = st.dadesGestor;
  if (g != null) return g;
  final cargat = GestorDades.de(await st.call('obtenirTotGestor', [st.token]));
  st.dadesGestor = cargat;
  return cargat;
}

class AltaRapidaPantalla extends StatefulWidget {
  const AltaRapidaPantalla({super.key});

  @override
  State<AltaRapidaPantalla> createState() => _AltaRapidaPantallaState();
}

class _AltaRapidaPantallaState extends State<AltaRapidaPantalla> {
  final n = TextEditingController(), dni = TextEditingController(), tel = TextEditingController();
  final em = TextEditingController(), banc = TextEditingController(), pw = TextEditingController();
  final a1 = TextEditingController(), a2 = TextEditingController(), a3 = TextEditingController();
  String? msg;
  bool err = false;
  bool intentat = false;

  @override
  void dispose() {
    n.dispose();
    dni.dispose();
    tel.dispose();
    em.dispose();
    banc.dispose();
    pw.dispose();
    a1.dispose();
    a2.dispose();
    a3.dispose();
    super.dispose();
  }

  String? eDe(TextEditingController c) =>
      (intentat && c.text.trim().isEmpty) ? Estat.i.i18n.t('campObligatori') : null;

  Future<void> _imprimeix() async {
    final d = await Estat.i.call('obtenirDadesFormulari', [Estat.i.token]);
    if (!mounted) return;
    imprimirFormulari((d as Map).cast<String, dynamic>());
  }

  Future<void> _desa() async {
    final st = Estat.i;
    final t = st.i18n.t;
    setState(() => intentat = true);
    if ([n, dni, tel, em, banc, pw].any((c) => c.text.trim().isEmpty)) return;
    setState(() {
      msg = t('enviant');
      err = false;
    });
    try {
      await st.call('altaRapida', [
        st.token,
        {
          'soci': {
            'nom': n.text,
            'dni': dni.text,
            'telefon': tel.text,
            'email': em.text,
            'numBanc': banc.text,
            'contrasenya': pw.text,
          },
          'alumnes': [
            {'nom': a1.text},
            {'nom': a2.text},
            {'nom': a3.text},
          ],
        },
      ]);
      if (!mounted) return;
      setState(() {
        msg = t('refrescat');
        err = false;
      });
      for (final c in [n, dni, tel, em, banc, pw, a1, a2, a3]) {
        c.clear();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        msg = st.toastMissatge ?? t('errGen');
        err = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return BastidaFormulari(
      ampladaMaxima: 470,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Text(t('formulariRapid'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.print, size: 18),
            label: Text(t('imprimir'), style: const TextStyle(fontSize: 13)),
            onPressed: _imprimeix,
          ),
        ]),
        const SizedBox(height: 4),
        Text(t('altaRapidaDesc'),
            style: const TextStyle(fontSize: 12, color: textCol)),
        const SizedBox(height: 12),
        CampText(controller: n, hint: t('nom'), obligatori: true, error: eDe(n)),
        CampText(controller: dni, hint: t('dni'), obligatori: true, error: eDe(dni)),
        CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone, obligatori: true, error: eDe(tel)),
        CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress, obligatori: true, error: eDe(em)),
        CampText(controller: banc, hint: t('banc'), obligatori: true, error: eDe(banc)),
        CampText(controller: pw, hint: t('contra'), obscure: true, obligatori: true, error: eDe(pw)),
        const SizedBox(height: 4),
        Text(t('alumnesOpt'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        CampText(controller: a1, hint: '${t('alumneU')} 1'),
        CampText(controller: a2, hint: '${t('alumneU')} 2'),
        CampText(controller: a3, hint: '${t('alumneU')} 3'),
        if (msg != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(msg ?? '',
                style: TextStyle(fontSize: 13.5, color: err ? vermell : verd)),
          ),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('desa')))),
      ]),
    );
  }
}
