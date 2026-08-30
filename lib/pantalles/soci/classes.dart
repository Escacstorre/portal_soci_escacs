// ignore_for_file: prefer_const_constructors_in_immutables
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../widgets/form_scaffold.dart';
import 'inici.dart';

class ClassesIniciPantalla extends StatelessWidget {
  const ClassesIniciPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final st = Estat.i;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BotoGran(titol: t('alta'), icon: Icons.person_add, onTap: () => st.go('classesAlta')),
          const SizedBox(width: 12),
          BotoGran(titol: t('alumnes'), icon: Icons.list, onTap: () => st.go('classesAlumnes')),
        ],
      ),
    );
  }
}

class ClassesAltaPantalla extends StatefulWidget {
  const ClassesAltaPantalla({super.key});

  @override
  State<ClassesAltaPantalla> createState() => _ClassesAltaPantallaState();
}

class _ClassesAltaPantallaState extends State<ClassesAltaPantalla> {
  late final n = TextEditingController();
  late final tel = TextEditingController(text: Estat.i.inici?.telefon ?? '');
  late final e = TextEditingController(text: Estat.i.inici?.email ?? '');
  String? msg;
  bool err = false;
  bool intentat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ini = Estat.i.inici;
      if (ini == null || !mounted) return;
      setState(() {
        if (tel.text.isEmpty && ini.telefon.isNotEmpty) tel.text = ini.telefon;
        if (e.text.isEmpty && ini.email.isNotEmpty) e.text = ini.email;
      });
    });
  }

  @override
  void dispose() {
    n.dispose();
    tel.dispose();
    e.dispose();
    super.dispose();
  }

  Future<void> _desa() async {
    final st = Estat.i;
    setState(() => intentat = true);
    if (n.text.trim().isEmpty) return;
    setState(() {
      msg = st.i18n.t('enviant');
      err = false;
    });
    try {
      await st.call('altaAlumne', [st.token, {'nom': n.text, 'telefon': tel.text, 'email': e.text}]);
      unawaited(st.recarregaTot());
      if (!mounted) return;
      setState(() {
        msg = '✓ ${st.i18n.t('desatOk')}';
        err = false;
        intentat = false;
      });
      n.clear();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => msg = null);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        msg = st.toastMissatge ?? st.i18n.t('errGen');
        err = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return BastidaFormulari(
      ampladaMaxima: 440,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('inscriu'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 12),
        CampText(
          controller: n,
          hint: t('nomAlumne'),
          obligatori: true,
          error: (intentat && n.text.trim().isEmpty) ? t('campObligatori') : null,
        ),
        CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
        CampText(controller: e, hint: t('email'), teclat: TextInputType.emailAddress),
        if (msg != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: (err ? vermell : verd).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: err ? vermell : verd),
            ),
            child: Row(children: [
              Icon(err ? Icons.error_outline : Icons.check_circle, color: err ? vermell : verd, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(msg ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: err ? vermell : verd))),
            ]),
          ),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('guardar')))),
      ]),
    );
  }
}

class ClassesAlumnesPantalla extends StatelessWidget {
  const ClassesAlumnesPantalla({super.key});

  void _obreCalendari(BuildContext context) {
    final tot = Estat.i.tot;
    final sessions = tot?.sessions ?? const <String>[];
    final festius = (tot?.festius ?? const <String>[]).toSet();
    final anyCurs = tot?.anyCurs != null && tot!.anyCurs != 0 ? tot.anyCurs : (DateTime.now().month >= 8 ? DateTime.now().year : DateTime.now().year - 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: titol,
            surfaceTintColor: Colors.white,
            title: Text(Estat.i.i18n.t('calendari')),
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CalendariGraella(sessions: sessions, festius: festius, anyCurs: anyCurs, mostraHora: false),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.event, size: 18),
                label: Text(Estat.i.i18n.t('alCal'), style: const TextStyle(fontSize: 13)),
                onPressed: () async {
                  final ics = await Estat.i.call('descarregarICSSenseHora', [Estat.i.token]);
                  descarregarArxiu(ics as String, 'text/calendar', 'classes.ics');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final alums = Estat.i.tot?.alumnes ?? const <AlumneSoci>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: Text(t('llistatAlumnes'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol))),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(t('calendari'), style: const TextStyle(fontSize: 13)),
            onPressed: () => _obreCalendari(context),
          ),
        ]),
        const SizedBox(height: 10),
        if (alums.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('${t('llistatAlumnes')} — 0'))),
        ...alums.map((a) => ItemLlista(
              onTap: () => Estat.i.go('trimestres', a.id),
              children: [
                Expanded(child: Text(a.nom, style: const TextStyle(fontWeight: FontWeight.bold))),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: XipEstat(estat: i < a.trims.length ? a.trims[i].estat : ''),
                  ),
              ],
            )),
      ],
    );
  }
}

class TrimestresPantalla extends StatelessWidget {
  const TrimestresPantalla({super.key, required this.alumneId});
  final String alumneId;

  AlumneSoci? get _alumne {
    final llista = Estat.i.tot?.alumnes ?? const <AlumneSoci>[];
    for (final a in llista) {
      if (a.id == alumneId) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final a = _alumne;
    if (a == null) return const Center(child: Text('?'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: Text(a.nom, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol))),
        const SizedBox(height: 4),
        Center(child: Text('${t('compte')} ${st.inici?.compte ?? ''}', style: const TextStyle(fontSize: 13))),
        const SizedBox(height: 10),
        ...a.trims.map((tr) {
          return Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text('${t('trimestre')} ${tr.t} — ${tr.preu} €',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                XipEstat(estat: tr.estat),
              ]),
              const SizedBox(height: 8),
              if (tr.estat == 'Validat')
                if (tr.rebut == null)
                  const SizedBox.shrink()
                else
                  TextButton.icon(
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(tr.rebut?.nom ?? '', overflow: TextOverflow.ellipsis),
                    onPressed: () {
                      final url = tr.rebut?.url;
                      if (url != null) obrirUrl(url);
                    },
                  )
              else
                Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (tr.estat == 'En revisió' && tr.rebut?.url != null)
                    IconButton(icon: const Icon(Icons.attach_file), onPressed: () {
                      final url = tr.rebut?.url;
                      if (url != null) obrirUrl(url);
                    }),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(tr.estat == 'En revisió' ? t('substituir') : '${t('rebut')} 📎'),
                    onPressed: () => unawaited(pujaFitxer(st.token, 'Classes', alumneId, '${tr.t}')),
                  ),
                ]),
            ]),
          );
        }),
      ],
    );
  }
}
