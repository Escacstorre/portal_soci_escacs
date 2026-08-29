import 'dart:async';

import 'package:flutter/material.dart';
// ignore_for_file: prefer_const_constructors_in_immutables

import '../../models.dart';
import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../widgets/form_scaffold.dart';

Future<void> pujaFitxer(String? token, String col, String id, String periode, {VoidCallback? onFet}) async {
  if (token == null || token.isEmpty) {
    Estat.i.mostraError(Estat.i.i18n.t('sessioCaducada'));
    return;
  }
  final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
  if (f == null) return;
  await Estat.i.call('pujarRebut', [token, col, id, periode, f]);
  await Estat.i.recarregaTot();
  Estat.i.mostraOk();
  Estat.i.refres();
  onFet?.call();
}

class IniciSociPantalla extends StatelessWidget {
  const IniciSociPantalla({super.key});

  Future<void> _renova() async {
    final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
    if (f == null) return;
    await Estat.i.call('renovarQuota', [Estat.i.token, f]);
    await Estat.i.recarregaTot();
    Estat.i.mostraOk();
    Estat.i.refres();
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final d = st.inici;
    final vigent = d?.quotaVigent ?? false;
    final caducitat = d?.caducitat ?? '';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: decoCardGran(),
              child: Column(
                children: [
                  const IconaClub(),
                  const SizedBox(height: 12),
                  Text('${t('benvingut')} ${d?.nom ?? ''}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titol)),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text('${t('quotaAny')} ${d?.any ?? ''}: '),
                      XipQuota(quota: d?.quota ?? ''),
                      if (vigent && caducitat.isNotEmpty)
                        Text('${t('vigentFins')} ${mostraData(caducitat)}',
                            style: const TextStyle(fontSize: 12.5, color: verd)),
                      if (d?.quotaRebut?.url != null)
                        TextButton(
                          onPressed: () {
                            final url = d?.quotaRebut?.url;
                            if (url != null) obrirUrl(url);
                          },
                          child: Text('(${t('veureRebut')})', style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                  if (!vigent) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: taronja.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: taronja),
                      ),
                      child: Text(
                        '${t('quotaCaducadaMsg')}${caducitat.isNotEmpty ? ' (${mostraData(caducitat)})' : ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13.5, color: titol),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _renova,
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: Text(t('pujaRebutQuota'),
                            style: const TextStyle(fontSize: 15)),
                        style: FilledButton.styleFrom(
                          backgroundColor: pri,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiBoto)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BotoGran(titol: t('fitxa'), icon: Icons.badge, onTap: vigent ? () => st.go('fitxaInici') : null),
                const SizedBox(width: 16),
                BotoGran(titol: t('classes'), icon: Icons.school, onTap: vigent ? () => st.go('classesInici') : null),
              ],
            ),
          ],
        ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(msg ?? '', style: TextStyle(fontSize: 13.5, color: err ? vermell : verd)),
          ),
        Row(children: [
          FilledButton(onPressed: _desa, child: Text(t('guardar'))),
          const SizedBox(width: 10),
          OutlinedButton(onPressed: () => n.clear(), child: Text(t('altre'))),
        ]),
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
  TrimestresPantalla({super.key, required this.alumneId});
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
  JugadorAnysPantalla({super.key, required this.jugadorId});
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
