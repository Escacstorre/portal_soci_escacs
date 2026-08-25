import 'dart:async';

import 'package:flutter/material.dart';
// ignore_for_file: prefer_const_constructors_in_immutables

import '../../models.dart';
import '../../estat.dart';
import '../../ginys.dart';

class IniciSociPantalla extends StatelessWidget {
  const IniciSociPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final d = st.inici;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${t('benvingut')} ${d?.nom ?? ''}',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: titol)),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                Text('${t('quotaAny')} ${d?.any ?? ''}: '),
                XipQuota(quota: d?.quota ?? ''),
                if (d?.quotaRebut != null)
                  TextButton(
                    onPressed: () => obrirUrl(d!.quotaRebut!.url),
                    child: Text('(${t('veureRebut')})', style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Gran(titol: t('fitxa'), icon: Icons.badge, onTap: () => st.go('fitxaHome')),
                const SizedBox(width: 12),
                _Gran(titol: t('classes'), icon: Icons.school, onTap: () => st.go('classesHome')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Gran extends StatelessWidget {
  const _Gran({required this.titol, required this.icon, required this.onTap});
  final String titol;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 110,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: pri,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        onPressed: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 34),
          const SizedBox(height: 6),
          Text(titol, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

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
          _Gran(titol: t('alta'), icon: Icons.person_add, onTap: () => st.go('classesAlta')),
          const SizedBox(width: 12),
          _Gran(titol: t('alumnes'), icon: Icons.list, onTap: () => st.go('classesAlumnes')),
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

  Future<void> _desa() async {
    final st = Estat.i;
    setState(() {
      msg = st.i18n.t('enviant');
      err = false;
    });
    try {
      await st.call('altaAlumne', [st.token, {'nom': n.text, 'telefon': tel.text, 'email': e.text}]);
      unawaited(st.recarregaTot());
      if (!mounted) return;
      setState(() {
        msg = 'OK';
        err = false;
      });
      n.clear();
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('inscriu'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
              const SizedBox(height: 12),
              CampText(controller: n, hint: t('nomAlumne')),
              CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
              CampText(controller: e, hint: t('email'), teclat: TextInputType.emailAddress),
              if (msg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(msg!, style: TextStyle(fontSize: 13.5, color: err ? vermell : verd)),
                ),
              Row(children: [
                FilledButton(onPressed: _desa, child: Text(t('guardar'))),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: () => n.clear(), child: Text(t('altre'))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class ClassesAlumnesPantalla extends StatelessWidget {
  const ClassesAlumnesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final alums = Estat.i.tot?.alumnes ?? const <AlumneSoci>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('llistatAlumnes'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
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
  TrimestresPantalla({super.key, required this.alumneId});
  final String alumneId;

  AlumneSoci? get _alumne {
    final llista = Estat.i.tot?.alumnes ?? const <AlumneSoci>[];
    for (final a in llista) {
      if (a.id == alumneId) return a;
    }
    return null;
  }

  Future<void> _puja(String periode) async {
    final st = Estat.i;
    final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
    if (f == null) return;
    await st.call('pujarRebut', [st.token, 'Classes', alumneId, periode, f]);
    await st.recarregaTot();
    st.mostraOk();
    st.refres();
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
                    label: Text(tr.rebut!.nom, overflow: TextOverflow.ellipsis),
                    onPressed: () => obrirUrl(tr.rebut!.url),
                  )
              else
                Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (tr.estat == 'En revisió' && tr.rebut != null)
                    IconButton(icon: const Icon(Icons.attach_file), onPressed: () => obrirUrl(tr.rebut!.url)),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(tr.estat == 'En revisió' ? t('substituir') : '${t('rebut')} 📎'),
                    onPressed: () => unawaited(_puja('${tr.t}')),
                  ),
                ]),
            ]),
          );
        }),
      ],
    );
  }
}

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
          _Gran(titol: t('jugadors'), icon: Icons.groups, onTap: () => st.go('jugadors')),
          const SizedBox(width: 12),
          _Gran(titol: t('alta'), icon: Icons.person_add_alt_1, onTap: () => st.go('jugadorAlta')),
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
  JugadorAnysPantalla({super.key, required this.jugadorId});
  final String jugadorId;

  JugadorSoci? get _jug {
    final llista = Estat.i.tot?.jugadors ?? const <JugadorSoci>[];
    for (final j in llista) {
      if (j.id == jugadorId) return j;
    }
    return null;
  }

  Future<void> _puja(String anyFed) async {
    final st = Estat.i;
    final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
    if (f == null) return;
    await st.call('pujarRebut', [st.token, 'Federacio', jugadorId, anyFed, f]);
    await st.recarregaTot();
    st.mostraOk();
    st.refres();
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
              if (a.estat == 'Validat' && a.rebut != null)
                IconButton(icon: const Icon(Icons.attach_file), onPressed: () => obrirUrl(a.rebut!.url))
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(a.estat == 'En revisió' ? t('substituir') : '${t('rebut')} 📎',
                      style: const TextStyle(fontSize: 13)),
                  onPressed: () => unawaited(_puja(a.any)),
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

  Future<void> _desa() async {
    final st = Estat.i;
    setState(() {
      msg = st.i18n.t('enviant');
      err = false;
    });
    foto ??= await triaArxiu('.jpg,.jpeg,.png');
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('alta'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
              const SizedBox(height: 12),
              CampText(controller: nom, hint: t('nomJug')),
              CampText(controller: cog, hint: t('cognoms')),
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
                  decoration: InputDecoration(labelText: t('dataNaix'), isDense: true),
                  child: Text(dataNaix),
                ),
              ),
              const SizedBox(height: 10),
              CampText(controller: dni, hint: t('dni')),
              CampText(controller: adr, hint: t('adreca')),
              CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
              CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress),
              OutlinedButton.icon(
                icon: Icon(foto == null ? Icons.upload_file : Icons.check_circle,
                    color: foto == null ? null : Colors.green),
                label: Text(foto == null ? t('fotoDni') : '${foto!['name'] ?? t('fotoDni')}'),
                onPressed: () async {
                  final f = await triaArxiu('.jpg,.jpeg,.png');
                  if (mounted) setState(() => foto = f);
                },
              ),
              if (msg != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(msg!, style: TextStyle(fontSize: 13.5, color: err ? vermell : verd)),
                ),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('guardar')))),
            ]),
          ),
        ),
      ),
    );
  }
}
