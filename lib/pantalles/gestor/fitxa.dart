import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../widgets/form_scaffold.dart';
import '../../widgets/pagament_toggle.dart';

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

  @override
  void dispose() {
    n.dispose();
    dni.dispose();
    tel.dispose();
    em.dispose();
    banc.dispose();
    super.dispose();
  }

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
            Estat.i.buidaCau();
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
              Estat.i.buidaCau();
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titol, letterSpacing: .5)),
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
                  Estat.i.buidaCau();
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
    final rebutUrl = m?['rebut']?['url'] as String?;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(any, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      const SizedBox(width: 2),
      CommutadorPagament(
        validat: validat,
        rebutUrl: rebutUrl,
        enCanviar: (v) async {
          await Estat.i.call('alternarAnyJugador', [Estat.i.token, jugadorId, any, v == true]);
          Estat.i.buidaCau();
          Estat.i.mostraOk();
          _refresca();
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
        Text(t('classes'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titol, letterSpacing: .5)),
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
                _filaTrimestre(trims, n, t),
              IconButton(
                tooltip: t('valida3'),
                icon: const Icon(Icons.done_all, size: 20, color: verd),
                onPressed: () async {
                  await Estat.i.call('validarCursComplet', [Estat.i.token, a['id'], curs.toInt()]);
                  Estat.i.buidaCau();
                  _refresca();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                onPressed: () async {
                  await Estat.i.call('eliminarAlumne', [Estat.i.token, a['id']]);
                  Estat.i.buidaCau();
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

  Widget _filaTrimestre(List<Map<String, dynamic>> trims, int n, String Function(String) t) {
    final tr = trims.firstWhere((x) => x['t'] == n, orElse: () => {});
    final id = tr['id'];
    final rebutUrl = tr['rebut']?['url'] as String?;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$n:', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      const SizedBox(width: 2),
      if (id != null)
        CommutadorPagament(
          validat: tr['estat'] == 'Validat',
          rebutUrl: rebutUrl,
          enCanviar: (v) async {
            await Estat.i.call('alternarPagament', [Estat.i.token, id, v == true]);
            Estat.i.buidaCau();
            Estat.i.mostraOk();
            _refresca();
          },
        )
      else
        Checkbox(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: tr['estat'] == 'Validat',
          onChanged: (v) async {
            await Estat.i.call('alternarPagament', [Estat.i.token, id, v == true]);
            Estat.i.buidaCau();
            Estat.i.mostraOk();
            _refresca();
          },
        ),
    ]);
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
  void dispose() {
    nom.dispose();
    cog.dispose();
    dn.dispose();
    dni.dispose();
    adr.dispose();
    super.dispose();
  }

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
    return BastidaFormulari(
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
          Estat.i.buidaCau();
          Estat.i.mostraOk();
          Estat.i.go('edicioSoci', widget.sociId);
        }, child: Text(t('guardar')))),
      ]),
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
  void dispose() {
    nom.dispose();
    tel.dispose();
    em.dispose();
    super.dispose();
  }

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
    return BastidaFormulari(
      ampladaMaxima: 440,
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
          Estat.i.buidaCau();
          Estat.i.mostraOk();
          Estat.i.back();
        }, child: Text(t('guardar')))),
      ]),
    );
  }
}
