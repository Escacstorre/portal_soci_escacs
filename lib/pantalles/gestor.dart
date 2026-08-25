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
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${t('benvingut')} ${st.user?['nom'] ?? ''}',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Gran2(titol: t('escola'), icon: Icons.school, onTap: () => st.go('escola')),
          const SizedBox(width: 12),
          _Gran2(titol: t('pagatTab'), icon: Icons.payments, onTap: () => st.go('pagat')),
        ]),
      ]),
    );
  }
}

class _Gran2 extends StatelessWidget {
  const _Gran2({required this.titol, required this.icon, required this.onTap});
  final String titol;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 110,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: pri,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        onPressed: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 32),
          const SizedBox(height: 6),
          Text(titol, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

Future<GestorDades> carregaGestor() async {
  final st = Estat.i;
  if (st.gest != null) return st.gest!;
  st.gest = GestorDades.de(await st.call('getTotGestor', [st.token]));
  return st.gest!;
}

class PagatPantalla extends StatefulWidget {
  const PagatPantalla({super.key});

  @override
  State<PagatPantalla> createState() => _PagatPantallaState();
}

class _PagatPantallaState extends State<PagatPantalla> {
  late Future<GestorDades> _fut = carregaGestor();
  Timer? _deb;

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
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final llista = _filtra(snap.data!.socis);
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
                  ('Pendent', 'Pendent'),
                  ('Actiu', 'Actiu'),
                  ('Rebutjat', 'Rebutjat'),
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
                Checkbox(
                  value: s.estat == 'Actiu',
                  onChanged: (chk) async {
                    if (chk != true) {
                      Estat.i.mostraError(Estat.i.i18n.t('actPend'));
                      return;
                    }
                    await Estat.i.call('decidirAltaSoci', [Estat.i.token, s.id, true]);
                    s.estat = 'Actiu';
                    Estat.i.mostraOk('Actiu ✓');
                    setState(() {});
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Estat.i.go('edicioSoci', s.id),
                    child: Text(s.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Flexible(
                  child: Text(s.email,
                      style: const TextStyle(fontSize: 12, color: textCol), overflow: TextOverflow.ellipsis),
                ),
                if (s.rebutQuota != null)
                  IconButton(icon: const Icon(Icons.attach_file), onPressed: () => obrirUrl(s.rebutQuota!.url)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text('${s.nom} — 🗑?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('🗑')),
                        ],
                      ),
                    );
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
      },
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

  Future<void> _desa() async {
    final st = Estat.i;
    final t = st.i18n.t;
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
              Text(t('formulariRapid'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
              const SizedBox(height: 12),
              CampText(controller: n, hint: t('nom')),
              CampText(controller: dni, hint: t('dni')),
              CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
              CampText(controller: em, hint: t('email'), teclat: TextInputType.emailAddress),
              CampText(controller: banc, hint: t('banc')),
              CampText(controller: pw, hint: t('contra'), obscure: true),
              const SizedBox(height: 4),
              Text(t('alumnesOpt'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              CampText(controller: a1, hint: '${t('alumneU')} 1'),
              CampText(controller: a2, hint: '${t('alumneU')} 2'),
              CampText(controller: a3, hint: '${t('alumneU')} 3'),
              if (msg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(msg!,
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
    final d = ((await Estat.i.call('getEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
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
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
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
        const SizedBox(height: 10),
        CampText(controller: n, hint: t('nom')),
        CampText(controller: dni, hint: t('dni')),
        CampText(controller: tel, hint: t('telefon')),
        CampText(controller: em, hint: t('email')),
        CampText(controller: banc, hint: t('banc')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: Text(t('editaDades'), style: const TextStyle(fontSize: 13)),
            onPressed: () async {
              await Estat.i.call('guardarDadesSoci', [
                Estat.i.token,
                s['id'],
                {'nom': n.text, 'dni': dni.text, 'telefon': tel.text, 'email': em.text, 'numBanc': banc.text},
              ]);
              Estat.i.buidaCachu();
              Estat.i.mostraOk();
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
        if (rebut != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.attach_file, size: 16),
              label: Text(t('rebutAlta'), style: const TextStyle(fontSize: 13)),
              onPressed: () => obrirUrl('${rebut['url']}'),
            ),
          ),
      ]),
    );
  }

  Widget _fitxa(Map<String, dynamic> d) {
    final jugadors = ((d['jugadors'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final anyFed = d['anyFed'] as num;
    return Carda(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('FEDERACIÓ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        if (jugadors.isEmpty) const Text('—'),
        ...jugadors.map((j) => ItemLlista(
              onTap: () => Estat.i.go('jugEdit', {'id': j['id'], 'sociId': widget.sociId}),
              children: [
                Expanded(child: Text('${j['nom'] ?? ''} ${j['cognoms'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                _chkAny(j['anyActual'], '$anyFed'),
                _chkAny(j['anyVinent'], '${anyFed + 1}'),
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

  Widget _chkAny(dynamic info, String etiqueta) {
    if (info == null) {
      return Padding(padding: const EdgeInsets.only(left: 4), child: Text('$etiqueta ○', style: const TextStyle(fontSize: 12, color: textCol)));
    }
    final m = (info as Map).cast<String, dynamic>();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(etiqueta, style: const TextStyle(fontSize: 12.5)),
      Checkbox(
        visualDensity: VisualDensity.compact,
        value: m['estat'] == 'Validat',
        onChanged: (v) async {
          await Estat.i.call('togglePagament', [Estat.i.token, m['id'], v == true]);
          Estat.i.buidaCachu();
          Estat.i.mostraOk();
        },
      ),
    ]);
  }

  Widget _alumnes(Map<String, dynamic> d) {
    final t = Estat.i.i18n.t;
    final alumnes = ((d['alumnes'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final curs = d['curs'] as num;
    return Carda(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CLASSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
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
                  return IconButton(icon: const Icon(Icons.attach_file, size: 18), onPressed: () => obrirUrl('${tr['rebut']['url']}'));
                }),
              ],
            ),
            Wrap(spacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              for (final tr in trims)
                if (tr['id'] != null)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('${tr['t']}:', style: const TextStyle(fontSize: 12.5)),
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      value: tr['estat'] == 'Validat',
                      onChanged: (v) async {
                        await Estat.i.call('togglePagament', [Estat.i.token, tr['id'], v == true]);
                        Estat.i.buidaCachu();
                        Estat.i.mostraOk();
                      },
                    ),
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final d = ((await Estat.i.call('getEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
      for (final x in ((d['jugadors'] as List?) ?? const []).cast<Map>()) {
        if ('${x['id']}' == widget.jugadorId) {
          nom.text = '${x['nom'] ?? ''}';
          cog.text = '${x['cognoms'] ?? ''}';
          dn.text = '${x['dataNaix'] ?? ''}';
          dni.text = '${x['dni'] ?? ''}';
          adr.text = '${x['adreca'] ?? ''}';
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
              CampText(controller: dn, hint: t('dataNaix')),
              CampText(controller: dni, hint: t('dni')),
              CampText(controller: adr, hint: t('adreca')),
              OutlinedButton.icon(
                icon: Icon(fotoNova == null ? Icons.upload_file : Icons.check_circle,
                    color: fotoNova == null ? null : Colors.green),
                label: Text(fotoNova == null ? t('fotoDni') : '${fotoNova!['name'] ?? t('fotoDni')}'),
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
      final d = ((await Estat.i.call('getEdicioSoci', [Estat.i.token, widget.sociId])) as Map).cast<String, dynamic>();
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
  late final TabController _tabs = TabController(length: 4, vsync: this, initialIndex: _idx0());

  int _idx0() {
    switch (Estat.i.escolaTab) {
      case 'preus':
        return 1;
      case 'trimestres':
        return 2;
      case 'classes':
        return 3;
      default:
        return 0;
    }
  }

  EscolaConfig? _escola;

  void _tab(int i) {
    Estat.i.escolaTab = ['festius', 'preus', 'trimestres', 'classes'][i];
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return FutureBuilder<GestorDades>(
      future: _fut,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        _escola = snap.data!.escola;
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
                Tab(text: t('preusTab')),
                Tab(text: t('trimTab')),
                Tab(text: t('classesTab')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_festius(), _preus(), _trims(), _classes()],
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
                label: Text('Selecciona una data', style: const TextStyle(fontSize: 14)),
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
                    await Estat.i.call('setFestiu', [Estat.i.token, data]);
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
                  child: Text(f, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(t('elimina')),
                        content: Text('Eliminar el festiu $f?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('torna'))),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('🗑')),
                        ],
                      ),
                    );
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
        TextEditingController(text: _escola == null ? '' : '${_escola!.preuDivendres}');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: CampText(controller: preuDive, hint: t('preuDive')))]),
            FilledButton(
              onPressed: () async {
                await Estat.i.call('setPreuDivendres', [Estat.i.token, preuDive.text]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
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

  Widget _trims() {
    final trims = _escola?.trimestres ?? const <String, String>{};
    final claus = ['Trim1Inici', 'Trim1Fi', 'Trim2Inici', 'Trim2Fi', 'Trim3Inici', 'Trim3Fi'];
    final ctrls = {for (final k in claus) k: TextEditingController(text: trims[k] ?? '')};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 1; i <= 3; i++) ...[
              Text('${Estat.i.i18n.t('trimestre')} $i', style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                Expanded(child: CampText(controller: ctrls['Trim${i}Inici']!, hint: 'Inici MM-DD')),
                Expanded(child: CampText(controller: ctrls['Trim${i}Fi']!, hint: 'Fi MM-DD')),
              ]),
            ],
            FilledButton(
              onPressed: () async {
                await Estat.i.call('setTrimestres', [
                  Estat.i.token,
                  {for (final k in claus) k: ctrls[k]!.text},
                ]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
              },
              child: Text(Estat.i.i18n.t('guardar')),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _classes() {
    final t = Estat.i.i18n.t;
    final hora = TextEditingController(text: _escola?.hora ?? '');
    final lloc = TextEditingController(text: _escola?.lloc ?? '');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CampText(controller: hora, hint: t('horaInici')),
            CampText(controller: lloc, hint: t('lloc')),
            FilledButton(
              onPressed: () async {
                await Estat.i.call('setClasseConfig', [Estat.i.token, {'hora': hora.text, 'lloc': lloc.text}]);
                Estat.i.buidaCachu();
                Estat.i.mostraOk();
              },
              child: Text(t('guardar')),
            ),
          ]),
        ),
      ],
    );
  }
}
