import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
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
  final g = st.gest;
  if (g != null) return g;
  final cargat = GestorDades.de(await st.call('obtenirTotGestor', [st.token]));
  st.gest = cargat;
  return cargat;
}

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
    Estat.i.buidaCachu();
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
                  label: Text(i == 1 ? '1 ${t('anys')}' : '$i ${t('anys')}'),
                  selected: anys == i,
                  onSelected: (_) => setD(() => anys = i),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Desar')),
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
                    Estat.i.buidaCachu();
                    setState(() => _fut = carregaGestor());
                  },
                ),
              ]);
            }),
          ],
        );
  }
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
        msg = 'OK';
        err = false;
      });
      for (final c in [n, dni, tel, em, banc, pw, a1, a2, a3]) {
        c.clear();
      }
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
          constraints: const BoxConstraints(maxWidth: 470),
          child: Carda(
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
          ),
        ),
      ),
    );
  }
}

class EdicioSociPantalla extends StatefulWidget {
  const EdicioSociPantalla({super.key, required this.sociId});
  final String sociId;

  @override
  State<EdicioSociPantalla> createState() => _EdicioSociPantallaState();
}

class _EdicioSociPantallaState extends State<EdicioSociPantalla> {
  late Future<Map<String, dynamic>> _fut = _carrega();
  final n = TextEditingController(), dni = TextEditingController(), tel = TextEditingController();
  final em = TextEditingController(), banc = TextEditingController();
  bool _init = false;

  Future<Map<String, dynamic>> _carrega() async {
    final d = ((await Estat.i.call('obtenirEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
    if (!_init) {
      final s = (d['soci'] as Map).cast<String, dynamic>();
      n.text = '${s['nom'] ?? ''}';
      dni.text = '${s['dni'] ?? ''}';
      tel.text = '${s['telefon'] ?? ''}';
      em.text = '${s['email'] ?? ''}';
      banc.text = '${s['numBanc'] ?? ''}';
      _init = true;
    }
    return d;
  }

  void _refresca() => setState(() => _fut = _carrega());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fut,
      builder: (context, snap) {
        final d0 = snap.data;
        if (d0 == null) return const Center(child: CircularProgressIndicator());
        final d = d0;
        final s = (d['soci'] as Map).cast<String, dynamic>();
        return ListView(padding: const EdgeInsets.all(16), children: [
          _dades(s),
          _fitxa(d),
          _alumnes(d),
        ]);
      },
    );
  }

  Widget _dades(Map<String, dynamic> s) {
    final t = Estat.i.i18n.t;
    final rebut = s['rebutQuota'] as Map?;
    return Carda(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${s['nom']} · ${t('edicio')}', style: const TextStyle(fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 16),
        CampText(controller: n, hint: t('nom')),
        CampText(controller: dni, hint: t('dni')),
        CampText(controller: tel, hint: t('telefon')),
        CampText(controller: em, hint: t('email')),
        CampText(controller: banc, hint: t('banc')),
        CampData(
          valor: '${s['caducitat'] ?? ''}',
          etiqueta: t('caducitatQuota'),
          onCanvi: (v) async {
            await Estat.i.call('desarCaducitat', [Estat.i.token, s['id'], v]);
            Estat.i.buidaCachu();
            Estat.i.mostraOk();
            _refresca();
          },
        ),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: Text(t('editaDades'), style: const TextStyle(fontSize: 13)),
            onPressed: () async {
              await Estat.i.call('desarDadesSoci', [
                Estat.i.token,
                s['id'],
                {'nom': n.text, 'dni': dni.text, 'telefon': tel.text, 'email': em.text, 'numBanc': banc.text},
              ]);
              Estat.i.buidaCachu();
              Estat.i.mostraOk();
              _refresca();
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.key, size: 16),
            label: Text(t('restabContra'), style: const TextStyle(fontSize: 13)),
            onPressed: () async {
              await Estat.i.call('restablirContrasenya', [Estat.i.token, s['id']]);
              Estat.i.mostraOk();
            },
          ),
        ]),
        const SizedBox(height: 14),
        if (rebut != null)
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.attach_file, size: 16),
            label: Text(t('rebutAlta'), style: const TextStyle(fontSize: 13)),
            onPressed: () => obrirUrl('${rebut['url']}'),
          )
        else
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.attach_file, size: 15, color: textCol),
            const SizedBox(width: 5),
            Text('${t('rebutAlta')}: ${t('noRebut')}',
                style: const TextStyle(fontSize: 12.5, color: textCol)),
          ]),
      ]),
    );
  }

  Widget _fitxa(Map<String, dynamic> d) {
    final jugadors = ((d['jugadors'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final anyFed = d['anyFed'] as num;
    return Carda(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(Estat.i.i18n.t('federacio'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titol, letterSpacing: .5)),
        const SizedBox(height: 10),
        if (jugadors.isEmpty) const Text('—'),
          ...jugadors.map((j) => ItemLlista(
              onTap: () => Estat.i.go('jugEdit', {'id': j['id'], 'sociId': widget.sociId}),
              children: [
                Expanded(child: Text('${j['nom'] ?? ''} ${j['cognoms'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                _chkAny(j['anyActual'], '${j['id']}', '$anyFed'),
                const SizedBox(width: 14),
                _chkAny(j['anyVinent'], '${j['id']}', '${anyFed + 1}'),
                const SizedBox(width: 6),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), onPressed: () async {
                  await Estat.i.call('eliminarJugador', [Estat.i.token, j['id']]);
                  Estat.i.buidaCachu();
                  _refresca();
                }),
              ],
            )),
      ]),
    );
  }

  Widget _chkAny(dynamic info, String jugadorId, String any) {
    final m = (info as Map?)?.cast<String, dynamic>();
    final validat = m != null && m['estat'] == 'Validat';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(any, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      const SizedBox(width: 2),
      Checkbox(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: validat,
        onChanged: (v) async {
          await Estat.i.call('alternarAnyJugador', [Estat.i.token, jugadorId, any, v == true]);
          Estat.i.buidaCachu();
          Estat.i.mostraOk();
          _refresca();
        },
      ),
      if (m != null && m['rebut'] != null)
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.attach_file, size: 18),
          onPressed: () => obrirUrl('${m['rebut']['url']}'),
        )
      else
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 6),
          child: Text(Estat.i.i18n.t('noRebut'), style: const TextStyle(fontSize: 10, color: textCol)),
        ),
    ]);
  }

  Widget _alumnes(Map<String, dynamic> d) {
    final t = Estat.i.i18n.t;
    final alumnes = ((d['alumnes'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final curs = d['curs'] as num;
    return Carda(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('classes'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titol, letterSpacing: .5)),
        const SizedBox(height: 10),
        if (alumnes.isEmpty) const Text('—'),
        ...alumnes.map((a) {
          final trims = ((a['trims'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ItemLlista(
              onTap: () => Estat.i.go('alumneEdit', {'id': a['id'], 'sociId': widget.sociId}),
              children: [
                Expanded(child: Text('${a['nom'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                ...trims.map((tr) {
                  if (tr['rebut'] == null) return const SizedBox.shrink();
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.attach_file, size: 18),
                    onPressed: () => obrirUrl('${tr['rebut']['url']}'),
                  );
                }),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 12, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              for (var n = 1; n <= 3; n++)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$n:', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 2),
                  ...() {
                    final tr = trims.firstWhere((x) => x['t'] == n, orElse: () => {});
                    if (tr['id'] == null) {
                      return [Padding(
                        padding: const EdgeInsets.only(left: 2, right: 6),
                        child: Text(t('noPagat'), style: const TextStyle(fontSize: 10, color: textCol)),
                      )];
                    }
                    return [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: tr['estat'] == 'Validat',
                        onChanged: (v) async {
                          await Estat.i.call('alternarPagament', [Estat.i.token, tr['id'], v == true]);
                          Estat.i.buidaCachu();
                          Estat.i.mostraOk();
                          _refresca();
                        },
                      ),
                      if (tr['rebut'] == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 2, right: 6),
                          child: Text(t('noRebut'),
                              style: const TextStyle(fontSize: 10, color: textCol)),
                        )
                      else
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.attach_file, size: 16),
                          onPressed: () => obrirUrl('${tr['rebut']['url']}'),
                        ),
                    ];
                  }(),
                ]),
              IconButton(
                tooltip: t('valida3'),
                icon: const Icon(Icons.done_all, size: 20, color: verd),
                onPressed: () async {
                  await Estat.i.call('validarCursComplet', [Estat.i.token, a['id'], curs.toInt()]);
                  Estat.i.buidaCachu();
                  _refresca();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                onPressed: () async {
                  await Estat.i.call('eliminarAlumne', [Estat.i.token, a['id']]);
                  Estat.i.buidaCachu();
                  _refresca();
                },
              ),
            ]),
          ]);
        }),
        ],
      ),
    );
  }
}

class JugadorEdicioPantalla extends StatefulWidget {
  const JugadorEdicioPantalla({super.key, required this.jugadorId, required this.sociId});
  final String jugadorId;
  final String sociId;

  @override
  State<JugadorEdicioPantalla> createState() => _JugadorEdicioPantallaState();
}

class _JugadorEdicioPantallaState extends State<JugadorEdicioPantalla> {
  final nom = TextEditingController(), cog = TextEditingController(), dn = TextEditingController();
  final dni = TextEditingController(), adr = TextEditingController();
  Map<String, dynamic>? fotoNova;
  Map<String, dynamic>? fotoActual;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final d = ((await Estat.i.call('obtenirEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
      for (final x in ((d['jugadors'] as List?) ?? const []).cast<Map>()) {
        if ('${x['id']}' == widget.jugadorId) {
          nom.text = '${x['nom'] ?? ''}';
          cog.text = '${x['cognoms'] ?? ''}';
          dn.text = '${x['dataNaix'] ?? ''}';
          dni.text = '${x['dni'] ?? ''}';
          adr.text = '${x['adreca'] ?? ''}';
          fotoActual = (x['foto'] as Map?)?.cast<String, dynamic>();
          if (mounted) setState(() {});
          break;
        }
      }
    });
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
              CampText(controller: nom, hint: t('nomJug')),
              CampText(controller: cog, hint: t('cognoms')),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CampData(
                  valor: dn.text,
                  etiqueta: t('dataNaix'),
                  onCanvi: (v) => setState(() => dn.text = v),
                ),
              ),
              CampText(controller: dni, hint: t('dni')),
              CampText(controller: adr, hint: t('adreca')),
              if (fotoActual != null && fotoNova == null)
                Row(children: [
                  TextButton.icon(
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    label: Text('${t('fotoDni')}: ${fotoActual?['nom'] ?? 'veure'}',
                        style: const TextStyle(fontSize: 13)),
                    onPressed: () {
                      final url = fotoActual?['url'] as String?;
                      if (url != null) obrirUrl(url);
                    },
                  ),
                ]),
              OutlinedButton.icon(
                icon: Icon(fotoNova == null ? Icons.upload_file : Icons.check_circle,
                    color: fotoNova == null ? null : verd),
                label: Text(fotoNova == null
                    ? (fotoActual != null ? '${t('substituir')} ${t('fotoDni')}' : t('pujaFitxer'))
                    : '${fotoNova?['name'] ?? t('fotoDni')}'),
                onPressed: () async {
                  final f = await triaArxiu('.jpg,.jpeg,.png');
                  if (mounted) setState(() => fotoNova = f);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
                await Estat.i.call('editarJugador', [
                  Estat.i.token,
                  widget.jugadorId,
                  {
                    'nom': nom.text,
                    'cognoms': cog.text,
                    'dataNaix': dn.text,
                    'dni': dni.text,
                    'adreca': adr.text,
                    if (fotoNova != null) 'foto': fotoNova,
                  },
                ]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
                Estat.i.go('edicioSoci', widget.sociId);
              }, child: Text(t('guardar')))),
            ]),
          ),
        ),
      ),
    );
  }
}

class AlumneEdicioPantalla extends StatefulWidget {
  const AlumneEdicioPantalla({super.key, required this.alumneId, required this.sociId});
  final String alumneId;
  final String sociId;

  @override
  State<AlumneEdicioPantalla> createState() => _AlumneEdicioPantallaState();
}

class _AlumneEdicioPantallaState extends State<AlumneEdicioPantalla> {
  final nom = TextEditingController(), tel = TextEditingController(), em = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final d = ((await Estat.i.call('obtenirEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
      for (final x in ((d['alumnes'] as List?) ?? const []).cast<Map>()) {
        if ('${x['id']}' == widget.alumneId) {
          nom.text = '${x['nom'] ?? ''}';
          tel.text = '${x['telefon'] ?? ''}';
          em.text = '${x['email'] ?? ''}';
          if (mounted) setState(() {});
          break;
        }
      }
    });
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
              CampText(controller: nom, hint: t('nomAlumne')),
              CampText(controller: tel, hint: t('telefon')),
              CampText(controller: em, hint: t('email')),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
                await Estat.i.call('editarAlumne', [
                  Estat.i.token,
                  widget.alumneId,
                  {'nom': nom.text, 'telefon': tel.text, 'email': em.text},
                ]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
                Estat.i.back();
              }, child: Text(t('guardar')))),
            ]),
          ),
        ),
      ),
    );
  }
}

class EscolaPantalla extends StatefulWidget {
  const EscolaPantalla({super.key});

  @override
  State<EscolaPantalla> createState() => _EscolaPantallaState();
}

class _EscolaPantallaState extends State<EscolaPantalla> with SingleTickerProviderStateMixin {
  late Future<GestorDades> _fut = carregaGestor();
  bool get _admin => Estat.i.isAdmin();
  List<String> get _nomsTabs => _admin
      ? const ['festius', 'preus', 'trimestres', 'classes']
      : const ['festius', 'trimestres', 'classes'];
  late final TabController _tabs = TabController(length: _nomsTabs.length, vsync: this, initialIndex: _idx0());

  int _idx0() {
    final i = _nomsTabs.indexOf(Estat.i.escolaTab);
    return i > -1 ? i : 0;
  }

  EscolaConfig? _escola;

  void _tab(int i) {
    Estat.i.escolaTab = _nomsTabs[i];
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return FutureBuilder<GestorDades>(
      future: _fut,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const Center(child: CircularProgressIndicator());
        _escola = data.escola;
        return Column(
          children: [
            TabBar(
              controller: _tabs,
              labelColor: pri,
              unselectedLabelColor: textCol,
              isScrollable: true,
              onTap: _tab,
              tabs: [
                Tab(text: t('festius')),
                if (_admin) Tab(text: t('preusTab')),
                Tab(text: t('trimTab')),
                Tab(text: t('classesTab')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _festius(),
                  if (_admin) _preus(),
                  _trims(),
                  _classes(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _festius() {
    final t = Estat.i.i18n.t;
    final festius = _escola?.festius ?? const <String>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('festius'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titol)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(t('seleccionaData'), style: TextStyle(fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: Locale(Estat.i.i18n.lang.toLowerCase()),
                  );
                  if (d != null) {
                    final data = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    await Estat.i.call('definirFestiu', [Estat.i.token, data]);
                    Estat.i.buidaCachu();
                    Estat.i.mostraOk();
                    setState(() => _fut = carregaGestor());
                  }
                },
              ),
            ),
          ]),
        ),
        if (festius.isEmpty)
          Carda(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(t('noDefinit'), style: const TextStyle(color: textCol, fontSize: 14)),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('${t('festius')} (${festius.length})', style: const TextStyle(fontSize: 13, color: textCol)),
          ),
          ...festius.map((f) => Carda(
            child: Row(
              children: [
                const Icon(Icons.event_busy, size: 20, color: vermell),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(mostraData(f), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () async {
                    final ok = await confirmaEliminacio(context, t('eliminarFestiu', [f.toString()]));
                    if (ok != true) return;
                    await Estat.i.call('esborrarFestiu', [Estat.i.token, f]);
                    Estat.i.buidaCachu();
                    Estat.i.mostraOk();
                    setState(() => _fut = carregaGestor());
                  },
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _preus() {
    final t = Estat.i.i18n.t;
    final preuDive =
        TextEditingController(text: _escola == null ? '' : '${_escola?.preuDivendres}');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: CampText(controller: preuDive, hint: t('preuDive'), sufix: ' €', teclat: TextInputType.number))
            ]),
            FilledButton(
              onPressed: () async {
                await Estat.i.call('definirPreuDivendres', [Estat.i.token, preuDive.text]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
                setState(() => _fut = carregaGestor());
              },
              child: Text(t('guardar')),
            ),
            const SizedBox(height: 4),
            Text(t('nomesAdmin'), style: const TextStyle(fontSize: 12, color: textCol)),
          ]),
        ),
      ],
    );
  }

  Widget _trims() => _TabsTrims(
        trims: _escola?.trimestres ?? const <String, String>{},
        onRefresca: () {
          Estat.i.buidaCachu();
          setState(() => _fut = carregaGestor());
        },
      );

  Widget _classes() => _TabsClasses(
        hora: _escola?.hora ?? '17:00',
        lloc: _escola?.lloc ?? '',
        onRefresca: () {
          Estat.i.buidaCachu();
          Estat.i.mostraOk();
          setState(() => _fut = carregaGestor());
        },
      );
}

class _TabsTrims extends StatefulWidget {
  const _TabsTrims({required this.trims, required this.onRefresca});
  final Map<String, String> trims;
  final VoidCallback onRefresca;

  @override
  State<_TabsTrims> createState() => _TabsTrimsState();
}

class _TabsTrimsState extends State<_TabsTrims> {
  late Map<String, String> valors = {for (final e in widget.trims.entries) e.key: e.value};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 1; i <= 3; i++) ...[
              Text('${Estat.i.i18n.t('trimestre')} $i', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: CampDataTrim(
                    valor: valors['Trim${i}Inici'] ?? '',
                    etiqueta: Estat.i.i18n.t('inici'),
                    onCanvi: (v) => setState(() => valors['Trim${i}Inici'] = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CampDataTrim(
                    valor: valors['Trim${i}Fi'] ?? '',
                    etiqueta: Estat.i.i18n.t('fi'),
                    onCanvi: (v) => setState(() => valors['Trim${i}Fi'] = v),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await Estat.i.call('definirTrimestres', [Estat.i.token, valors]);
                  widget.onRefresca();
                },
                child: Text(Estat.i.i18n.t('guardar')),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _TabsClasses extends StatefulWidget {
  const _TabsClasses({required this.hora, required this.lloc, required this.onRefresca});
  final String hora;
  final String lloc;
  final VoidCallback onRefresca;

  @override
  State<_TabsClasses> createState() => _TabsClassesState();
}

class _TabsClassesState extends State<_TabsClasses> {
  late final hora = TextEditingController(text: widget.hora);
  late final lloc = TextEditingController(text: widget.lloc);

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CampHora(controller: hora, hint: t('horaInici')),
            CampText(controller: lloc, hint: t('lloc'), linies: 3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await Estat.i.call('definirConfigClasse', [Estat.i.token, {'hora': normalitzaHora(hora.text), 'lloc': lloc.text}]);
                  widget.onRefresca();
                },
                child: Text(t('guardar')),
              ),
            ),
          ]),
        ),
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

  Map<String, List<PersonaGestor>> get _grups {
    final g = <String, List<PersonaGestor>>{};
    for (final j in widget.d.fitxes) {
      final k = '${j.nom} ${j.cognoms} ${j.soci}'.toLowerCase();
      if (q.isNotEmpty && !k.contains(q.toLowerCase())) continue;
      if (!_passa(j)) continue;
      (g[j.idSoci] ??= []).add(j);
    }
    return g;
  }

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
            child: Text(t('novaFitxa'), style: TextStyle(fontSize: 13)),
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

  Map<String, List<PersonaGestor>> get _grups {
    final g = <String, List<PersonaGestor>>{};
    for (final a in widget.d.alumnes) {
      final k = '${a.nom} ${a.soci}'.toLowerCase();
      if (q.isNotEmpty && !k.contains(q.toLowerCase())) continue;
      (g[a.idSoci] ??= []).add(a);
    }
    return g;
  }

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
            child: Text(t('nouAlumne'), style: TextStyle(fontSize: 13)),
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
      setState(() { msg = Estat.i.toastMissatge ?? 'Error'; err = true; });
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
      setState(() { msg = Estat.i.toastMissatge ?? 'Error'; err = true; });
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
