// ignore_for_file: prefer_const_constructors_in_immutables
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../widgets/form_scaffold.dart';
import 'inici.dart';

class FitxaIniciPantalla extends StatelessWidget {
  const FitxaIniciPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final st = Estat.i;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BotoGran(titol: t('jugadors'), icon: Icons.groups, onTap: () => st.go('jugadors')),
          const SizedBox(width: 12),
          BotoGran(titol: t('alta'), icon: Icons.person_add_alt_1, onTap: () => st.go('jugadorAlta')),
        ],
      ),
    );
  }
}

class JugadorsPantalla extends StatelessWidget {
  const JugadorsPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final jugs = Estat.i.tot?.jugadors ?? const <JugadorSoci>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('jugadors'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 10),
        if (jugs.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('—'))),
        ...jugs.map((j) => ItemLlista(
              onTap: () => Estat.i.go('jugadorAnys', j.id),
              children: [
                Expanded(child: Text('${j.nom} ${j.cognoms}', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            )),
      ],
    );
  }
}

class JugadorAnysPantalla extends StatelessWidget {
  const JugadorAnysPantalla({super.key, required this.jugadorId});
  final String jugadorId;

  JugadorSoci? get _jug {
    final llista = Estat.i.tot?.jugadors ?? const <JugadorSoci>[];
    for (final j in llista) {
      if (j.id == jugadorId) return j;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final j = _jug;
    if (j == null) return const Center(child: Text('?'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: Text(t('fedEscacs'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol))),
        const SizedBox(height: 4),
        Center(child: Text('${j.nom} ${j.cognoms}', style: const TextStyle(fontSize: 15))),
        const SizedBox(height: 10),
        ...j.anys.map((a) => ItemLlista(children: [
              Text(a.any, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(' — ${a.preu} €'),
              const SizedBox(width: 8),
              XipEstat(estat: a.estat),
              const Spacer(),
              if (a.estat == 'Validat' && a.rebut?.url != null)
                IconButton(icon: const Icon(Icons.attach_file), onPressed: () {
                  final url = a.rebut?.url;
                  if (url != null) obrirUrl(url);
                })
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(a.estat == 'En revisió' ? t('substituir') : '${t('rebut')} 📎',
                      style: const TextStyle(fontSize: 13)),
                  onPressed: () => unawaited(pujaFitxer(Estat.i.token, 'Federacio', jugadorId, a.any)),
                ),
            ])),
      ],
    );
  }
}

class JugadorAltaPantalla extends StatefulWidget {
  const JugadorAltaPantalla({super.key});

  @override
  State<JugadorAltaPantalla> createState() => _JugadorAltaPantallaState();
}

class _JugadorAltaPantallaState extends State<JugadorAltaPantalla> {
  late final nom = TextEditingController();
  late final cog = TextEditingController();
  String dataNaix = '';
  late final dni = TextEditingController();
  late final adr = TextEditingController();
  late final tel = TextEditingController(text: Estat.i.inici?.telefon ?? '');
  late final em = TextEditingController(text: Estat.i.inici?.email ?? '');
  Map<String, dynamic>? foto;
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
        if (em.text.isEmpty && ini.email.isNotEmpty) em.text = ini.email;
      });
    });
  }

  @override
  void dispose() {
    nom.dispose();
    cog.dispose();
    dni.dispose();
    adr.dispose();
    tel.dispose();
    em.dispose();
    super.dispose();
  }

  Future<void> _desa() async {
    final st = Estat.i;
    setState(() => intentat = true);
    if (nom.text.trim().isEmpty ||
        cog.text.trim().isEmpty ||
        dataNaix.isEmpty ||
        dni.text.trim().isEmpty ||
        adr.text.trim().isEmpty) {
      return;
    }
    setState(() {
      msg = st.i18n.t('enviant');
      err = false;
    });
    try {
      await st.call('altaJugador', [
        st.token,
        {
          'nom': nom.text,
          'cognoms': cog.text,
          'dataNaix': dataNaix,
          'dni': dni.text,
          'adreca': adr.text,
          'telefon': tel.text,
          'email': em.text,
          if (foto != null) 'foto': foto,
        },
      ]);
      unawaited(st.recarregaTot());
      if (!mounted) return;
      setState(() {
        msg = 'OK';
        err = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        msg = st.toastMissatge ?? 'Error';
        err = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return BastidaFormulari(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('alta'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 12),
        CampText(controller: nom, hint: t('nomJug'), obligatori: true, error: (intentat && nom.text.trim().isEmpty) ? t('campObligatori') : null),
        CampText(controller: cog, hint: t('cognoms'), obligatori: true, error: (intentat && cog.text.trim().isEmpty) ? t('campObligatori') : null),
        InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2015),
                      firstDate: DateTime(1930),
                      lastDate: DateTime.now());
                  if (d != null && mounted) {
                    setState(() =>
                        dataNaix = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '${t('dataNaix')} *',
                    isDense: true,
                    errorText: (intentat && dataNaix.isEmpty) ? t('campObligatori') : null,
                  ),
                  child: Text(dataNaix.isEmpty ? '—' : mostraData(dataNaix)),
                ),
              ),
              const SizedBox(height: 10),
              CampText(controller: dni, hint: t('dni'), obligatori: true, error: (intentat && dni.text.trim().isEmpty) ? t('campObligatori') : null),
              CampText(controller: adr, hint: t('adreca'), obligatori: true, error: (intentat && adr.text.trim().isEmpty) ? t('campObligatori') : null),
              CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
              CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress),
              OutlinedButton.icon(
                icon: Icon(foto == null ? Icons.upload_file : Icons.check_circle,
                    color: foto == null ? null : verd),
                label: Text(foto == null ? t('fotoDni') : '${foto?['name'] ?? t('fotoDni')}'),
                onPressed: () async {
                  final f = await triaArxiu('.jpg,.jpeg,.png');
                  if (mounted) setState(() => foto = f);
                },
              ),
              if (msg != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(msg ?? '', style: TextStyle(fontSize: 13.5, color: err ? vermell : verd)),
                ),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('guardar')))),
            ]),
    );
  }
}
