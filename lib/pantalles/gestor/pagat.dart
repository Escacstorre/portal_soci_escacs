import 'dart:async';

import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../models.dart';
import '../../utils/filtra.dart';
import 'comu.dart';

class PagatPantalla extends StatefulWidget {
  const PagatPantalla({super.key});

  @override
  State<PagatPantalla> createState() => _PagatPantallaState();
}

class _PagatPantallaState extends State<PagatPantalla> with SingleTickerProviderStateMixin {
  late Future<GestorDades> _fut = carregaGestor();
  late final TabController _tabs = TabController(length: 3, vsync: this, initialIndex: Estat.i.pagatTab);
  Timer? _deb;

  void _tab(int i) => Estat.i.pagatTab = i;

  @override
  void dispose() {
    _tabs.dispose();
    _deb?.cancel();
    super.dispose();
  }

  List<SociGestor> _filtra(List<SociGestor> socis) {
    final st = Estat.i;
    final q = st.pagatText.trim().toLowerCase();
    final estatF = st.pagatEstat;
    return socis.where((s) {
      if (estatF.isEmpty && s.estat == 'Rebutjat') return false;
      if (estatF.isNotEmpty && estatF != 'Tots' && s.estat != estatF) return false;
      if (q.isNotEmpty) {
        final camp = '${s.nom} ${s.email} ${s.dni}'.toLowerCase();
        if (!camp.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return FutureBuilder<GestorDades>(
      future: _fut,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const Center(child: CircularProgressIndicator());
        return Column(
          children: [
            TabBar(
              controller: _tabs,
              labelColor: pri,
              unselectedLabelColor: textCol,
              isScrollable: true,
              onTap: _tab,
              tabs: [
                Tab(text: t('tabSocis')),
                Tab(text: t('tabFitxes')),
                Tab(text: t('tabAlumnes')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _tabSocis(d),
                  _TabFitxes(d: d, onRefresca: _refrescaTot),
                  _TabAlumnes(d: d, onRefresca: _refrescaTot),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _refrescaTot() {
    Estat.i.buidaCau();
    setState(() => _fut = carregaGestor());
  }

  Widget _validacioQuota(SociGestor s) {
    final t = Estat.i.i18n.t;
    if (s.estat == 'Actiu') {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _dialogAnys(s),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: verd.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
          child: Text(
            s.caducitat.isNotEmpty ? '${t('vigent')} · ${mostraData(s.caducitat)}' : t('vigent'),
            style: const TextStyle(fontSize: 11.5, color: verd, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _dialogAnys(s),
      child: Text(t('validar')),
    );
  }

  Future<void> _dialogAnys(SociGestor s) async {
    final t = Estat.i.i18n.t;
    var anys = 1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('${s.nom} — ${t('anysQuota')}', style: const TextStyle(fontSize: 17)),
          content: Wrap(
            spacing: 6,
            children: [
              for (var i = 1; i <= 5; i++)
                ChoiceChip(
                  label: Text(i == 1 ? '1 ${t('any')}' : '$i ${t('anys')}'),
                  selected: anys == i,
                  onSelected: (_) => setD(() => anys = i),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('guardar'))),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await Estat.i.call('decidirAltaSoci', [Estat.i.token, s.id, true, anys]);
    Estat.i.mostraOk();
    _refrescaTot();
  }

  Widget _tabSocis(GestorDades d) {
    final t = Estat.i.i18n.t;
    final llista = _filtra(d.socis);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: t('buscador'), prefixIcon: const Icon(Icons.search, size: 20), isDense: true),
                  onChanged: (v) {
                    Estat.i.pagatText = v;
                    _deb?.cancel();
                    _deb = Timer(const Duration(milliseconds: 350), () {
                      if (mounted) setState(() {});
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: Estat.i.pagatEstat,
                items: [
                  ('', t('actPend')),
                  ('Tots', t('tots')),
                  ('Pendent', t('estatPendent')),
                  ('Actiu', t('estatActiu')),
                  ('Rebutjat', t('estatRebutjat')),
                ]
                    .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => Estat.i.pagatEstat = v ?? ''),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => Estat.i.go('altaRapida'),
                child: Text(t('altaRapida'), style: const TextStyle(fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 12),
            ...llista.map((s) {
              return ItemLlista(children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Estat.i.go('edicioSoci', s.id),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                      const SizedBox(height: 3),
                      Text(s.email,
                          style: const TextStyle(fontSize: 12, color: textCol), overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                if (s.estat != 'Rebutjat') _validacioQuota(s),
                if (s.rebutQuota?.url != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: t('rebutAlta'),
                    icon: const Icon(Icons.attach_file, size: 20),
                    onPressed: () {
                      final url = s.rebutQuota?.url;
                      if (url != null) obrirUrl(url);
                    },
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: t('elimina'),
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () async {
                    final ok = await confirmaEliminacio(context, t('eliminarConfirmacio', [s.nom]));
                    if (ok != true) return;
                    await Estat.i.call('eliminarSoci', [Estat.i.token, s.id]);
                    Estat.i.buidaCau();
                    setState(() => _fut = carregaGestor());
                  },
                ),
              ]);
            }),
          ],
        );
  }
}

class _TabFitxes extends StatefulWidget {
  const _TabFitxes({required this.d, required this.onRefresca});
  final GestorDades d;
  final VoidCallback onRefresca;

  @override
  State<_TabFitxes> createState() => _TabFitxesState();
}

class _TabFitxesState extends State<_TabFitxes> {
  String q = '';
  String filtre = '';

  bool _passa(PersonaGestor j) {
    switch (filtre) {
      case 'cap':
        return !j.pagActual.validat;
      case 'actual':
        return j.pagActual.validat;
      case 'dos':
        return j.pagActual.validat && j.pagVinent.validat;
      default:
        return true;
    }
  }

  Map<String, List<PersonaGestor>> get _grups => agrupaPerSoci(
        widget.d.fitxes,
        q,
        filtreAddicional: _passa,
        text: (j) => '${j.nom} ${j.cognoms} ${j.soci}',
      );

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final grups = _grups;
    final anyFed = widget.d.anyFed;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                  hintText: t('buscarSociJugador'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: filtre,
            underline: const SizedBox.shrink(),
            isDense: true,
            items: [
              ('', t('totes')),
              ('cap', t('noPagatAny', [anyFed.toString()])),
              ('actual', t('pagatAny', [anyFed.toString()])),
              ('dos', t('pagatsDosAnys', [anyFed.toString(), (int.parse(anyFed) + 1).toString()])),
            ]
                .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => filtre = v ?? ''),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _FormulariRapidFitxa(socis: widget.d.socis),
                  ),
                ),
              );
              widget.onRefresca();
            },
            child: Text(t('novaFitxa'), style: const TextStyle(fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (grups.isEmpty)
          const Carda(child: Center(child: Padding(padding: EdgeInsets.all(16), child: Text('—')))),
        ...grups.entries.map((e) {
          final sociNom = e.value.first.soci;
          return Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () => Estat.i.go('edicioSoci', e.key),
                child: Row(children: [
                  Expanded(
                    child: Text(sociNom.isEmpty ? e.key : sociNom,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: titol)),
                  ),
                  Text('${e.value.length}',
                      style: const TextStyle(fontSize: 12, color: textCol)),
                  const Icon(Icons.chevron_right, size: 20, color: textCol),
                ]),
              ),
              const SizedBox(height: 6),
              ...e.value.map((j) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.badge, size: 15, color: textCol),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Estat.i.go('edicioSoci', e.key),
                          child: Text('${j.nom} ${j.cognoms}'.trim(),
                              style: const TextStyle(fontSize: 13.5)),
                        ),
                      ),
                    ]),
                  )),
            ]),
          );
        }),
      ],
    );
  }
}

class _TabAlumnes extends StatefulWidget {
  const _TabAlumnes({required this.d, required this.onRefresca});
  final GestorDades d;
  final VoidCallback onRefresca;

  @override
  State<_TabAlumnes> createState() => _TabAlumnesState();
}

class _TabAlumnesState extends State<_TabAlumnes> {
  String q = '';

  Map<String, List<PersonaGestor>> get _grups => agrupaPerSoci(
        widget.d.alumnes,
        q,
        text: (a) => '${a.nom} ${a.soci}',
      );

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final grups = _grups;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                  hintText: t('buscarSociAlumne'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (_) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _FormulariRapidAlumne(socis: widget.d.socis),
                  ),
                ),
              );
              widget.onRefresca();
            },
            child: Text(t('nouAlumne'), style: const TextStyle(fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (grups.isEmpty)
          const Carda(child: Center(child: Padding(padding: EdgeInsets.all(16), child: Text('—')))),
        ...grups.entries.map((e) {
          final sociNom = e.value.first.soci;
          return Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () => Estat.i.go('edicioSoci', e.key),
                child: Row(children: [
                  Expanded(
                    child: Text(sociNom.isEmpty ? e.key : sociNom,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: titol)),
                  ),
                  Text('${e.value.length}',
                      style: const TextStyle(fontSize: 12, color: textCol)),
                  const Icon(Icons.chevron_right, size: 20, color: textCol),
                ]),
              ),
              const SizedBox(height: 6),
              ...e.value.map((a) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.school, size: 15, color: textCol),
                      const SizedBox(width: 6),
                      Expanded(child: Text(a.nom, style: const TextStyle(fontSize: 13.5))),
                    ]),
                  )),
            ]),
          );
        }),
      ],
    );
  }
}

class SelectorSoci extends StatefulWidget {
  const SelectorSoci({super.key, required this.socis, required this.onSeleccionat, this.error});
  final List<SociGestor> socis;
  final ValueChanged<SociGestor> onSeleccionat;
  final String? error;

  @override
  State<SelectorSoci> createState() => _SelectorSociState();
}

class _SelectorSociState extends State<SelectorSoci> {
  final ctrl = TextEditingController();
  bool triat = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: '${Estat.i.i18n.t('soci')} *',
            prefixIcon: const Icon(Icons.person_search, size: 20),
            isDense: true,
            errorText: widget.error,
            suffixIcon: triat
                ? IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        triat = false;
                        ctrl.clear();
                      });
                    },
                  )
                : null,
          ),
          onChanged: (_) {
            if (!mounted) return;
            setState(() => triat = false);
          },
        ),
        if (!triat && ctrl.text.trim().isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: Builder(builder: (context) {
              final q = ctrl.text.trim().toLowerCase();
              final opts = widget.socis
                  .where((s) =>
                      s.estat != 'Rebutjat' &&
                      '${s.nom} ${s.email} ${s.dni}'.toLowerCase().contains(q))
                  .take(8)
                  .toList();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: opts.length,
                itemBuilder: (_, i) {
                  final s = opts[i];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(s.nom, style: const TextStyle(fontSize: 13.5)),
                    subtitle: Text(s.email, style: const TextStyle(fontSize: 11.5, color: textCol)),
                    onTap: () {
                      setState(() {
                        triat = true;
                        ctrl.text = '${s.nom} · ${s.email}';
                      });
                      widget.onSeleccionat(s);
                    },
                  );
                },
              );
            }),
          ),
      ]),
    );
  }
}

class _FormulariRapidFitxa extends StatefulWidget {
  const _FormulariRapidFitxa({required this.socis});
  final List<SociGestor> socis;

  @override
  State<_FormulariRapidFitxa> createState() => _FormulariRapidFitxaState();
}

class _FormulariRapidFitxaState extends State<_FormulariRapidFitxa> {
  SociGestor? soci;
  final nom = TextEditingController(), cog = TextEditingController(), dni = TextEditingController(), adr = TextEditingController();
  final tel = TextEditingController(), em = TextEditingController();
  String dataNaix = '';
  String? msg;
  bool err = false;
  bool intentat = false;

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
    if (soci == null || nom.text.trim().isEmpty || cog.text.trim().isEmpty || dataNaix.isEmpty) return;
    setState(() { msg = st.i18n.t('enviant'); err = false; });
    try {
      final sid = soci?.id;
      if (sid == null || sid.isEmpty) throw Exception('Soci no seleccionat');
      await st.call('altaRapidaJugador', [
        st.token,
        sid,
        {
          'nom': nom.text,
          'cognoms': cog.text,
          'dataNaix': dataNaix,
          'dni': dni.text,
          'adreca': adr.text,
          'telefon': tel.text,
          'email': em.text,
        },
      ]);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() { msg = Estat.i.toastMissatge ?? Estat.i.i18n.t('errGen'); err = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final eCamp = Estat.i.i18n.t('campObligatori');
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(t('novaFitxaRapidaFed'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titol)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ]),
        const SizedBox(height: 4),
        SelectorSoci(
          socis: widget.socis,
          onSeleccionat: (s) {
            tel.text = s.telefon;
            em.text = s.email;
            setState(() => soci = s);
          },
          error: (intentat && soci == null) ? eCamp : null,
        ),
        CampText(controller: nom, hint: t('nomJug'), obligatori: true, error: (intentat && nom.text.trim().isEmpty) ? eCamp : null),
        CampText(controller: cog, hint: t('cognoms'), obligatori: true, error: (intentat && cog.text.trim().isEmpty) ? eCamp : null),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CampData(
            valor: dataNaix,
            etiqueta: t('dataNaix'),
            obligatori: true,
            error: (intentat && dataNaix.isEmpty) ? eCamp : null,
            onCanvi: (v) => setState(() => dataNaix = v),
          ),
        ),
        CampText(controller: dni, hint: t('dni')),
        CampText(controller: adr, hint: t('adreca')),
        CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
        CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress),
        if (msg != null)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(msg ?? '', style: TextStyle(fontSize: 13.5, color: err ? vermell : verd))),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('desa')))),
      ]),
    );
  }
}

class _FormulariRapidAlumne extends StatefulWidget {
  const _FormulariRapidAlumne({required this.socis});
  final List<SociGestor> socis;

  @override
  State<_FormulariRapidAlumne> createState() => _FormulariRapidAlumneState();
}

class _FormulariRapidAlumneState extends State<_FormulariRapidAlumne> {
  SociGestor? soci;
  final nom = TextEditingController(), tel = TextEditingController(), em = TextEditingController();
  String? msg;
  bool err = false;
  bool intentat = false;

  @override
  void dispose() {
    nom.dispose();
    tel.dispose();
    em.dispose();
    super.dispose();
  }

  Future<void> _desa() async {
    final st = Estat.i;
    setState(() => intentat = true);
    if (soci == null || nom.text.trim().isEmpty) return;
    setState(() { msg = st.i18n.t('enviant'); err = false; });
    try {
      final sid = soci?.id;
      if (sid == null || sid.isEmpty) throw Exception('Soci no seleccionat');
      await st.call('altaRapidaAlumne', [
        st.token,
        sid,
        {'nom': nom.text, 'telefon': tel.text, 'email': em.text},
      ]);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() { msg = Estat.i.toastMissatge ?? Estat.i.i18n.t('errGen'); err = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final eCamp = Estat.i.i18n.t('campObligatori');
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(t('nouAlumneRapides'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titol)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ]),
        const SizedBox(height: 4),
        SelectorSoci(socis: widget.socis, onSeleccionat: (s) {
          tel.text = s.telefon;
          em.text = s.email;
          setState(() => soci = s);
        }, error: (intentat && soci == null) ? eCamp : null),
        CampText(controller: nom, hint: t('nomAlumne'), obligatori: true, error: (intentat && nom.text.trim().isEmpty) ? eCamp : null),
        CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
        CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress),
        if (msg != null)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(msg ?? '', style: TextStyle(fontSize: 13.5, color: err ? vermell : verd))),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('desa')))),
      ]),
    );
  }
}
