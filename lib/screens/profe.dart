import 'dart:async';

import 'package:flutter/material.dart';

import '../../state.dart';
import '../../widgets.dart';

Map<String, dynamic>? get _ptot => Estat.i.ptot;

Future<void> carregaProfe() async {
  final st = Estat.i;
  if (st.profeTrim <= 0) {
    final d0 = await st.call('getTotProfe', [st.token, null]);
    st.ptot = (d0 as Map).cast<String, dynamic>();
    st.profeTrim = (((st.ptot!['profe'] as Map)['trimestre']) as num).toInt();
  }
  final d = await st.call('getTotProfe', [st.token, st.profeTrim]);
  st.ptot = (d as Map).cast<String, dynamic>();
}

class ProfeScreen extends StatefulWidget {
  const ProfeScreen({super.key});

  @override
  State<ProfeScreen> createState() => _ProfeScreenState();
}

class _ProfeScreenState extends State<ProfeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (_ptot == null) await carregaProfe();
      Estat.i.refres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final p = _ptot;
    if (p == null) return const Center(child: CircularProgressIndicator());
    final profe = (p['profe'] as Map).cast<String, dynamic>();
    final llista =
        ((profe['llista'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final sessions = ((p['sessions'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final bases = ((profe['bases'] as List?) ?? const []).toList();
    String base(int i) => i < bases.length ? '${bases[i]}' : '';
    final formulari = (profe['formulari'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${t('profeBenv')} ${st.user?['nom'] ?? ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 10),
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(t('selectorTrim'), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 10),
              for (var n = 1; n <= 3; n++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$n'),
                    selected: st.profeTrim == n,
                    onSelected: (_) async {
                      st.profeTrim = n;
                      await carregaProfe();
                      st.refres();
                    },
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            if (llista.isEmpty)
              const Text('—')
            else
              ...llista.map((m) => ItemLlista(children: [
                    Expanded(child: Text('${m['alumne'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Text('${m['soci'] ?? ''}', style: const TextStyle(fontSize: 13, color: textCol)),
                  ])),
          ]),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Carda(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('calendari'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...sessions.take(12).map((s) => Row(children: [
                        const Text('✔ ', style: TextStyle(color: Color(0xFF2E7D32))),
                        Expanded(child: Text('${s['data'] ?? ''}', style: const TextStyle(fontSize: 13.5))),
                      ])),
                  Text('… ${sessions.length} ${t('sessioClasse')}',
                      style: const TextStyle(fontSize: 12, color: textCol)),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(t('alCal'), style: const TextStyle(fontSize: 13)),
                    onPressed: () async {
                      final ics = await st.call('descarregarICS', [st.token]);
                      descarregarArxiu(ics as String, 'text/calendar', 'clases.ics');
                    },
                  ),
                ]),
              ),
            ),
            Expanded(
              child: Carda(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('preus'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${t('baseTrim')} ${i + 1}', style: const TextStyle(fontSize: 13.5)),
                        Text('${base(i)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  _preuFila(t('trimJunts'), '${profe['junts'] ?? ''} €'),
                  _preuFila(t('serSoci'), '${profe['serSoci'] ?? ''} €'),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print, size: 18),
                      label: Text(t('imprimir'), style: const TextStyle(fontSize: 13)),
                      onPressed: () => imprimirFormulari(formulari),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.list, size: 18),
                      label: Text(t('alumnes'), style: const TextStyle(fontSize: 13)),
                      onPressed: () => st.go('profeAlumnes'),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _preuFila(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: const TextStyle(fontSize: 13.5)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class ProfeAlumnesScreen extends StatelessWidget {
  const ProfeAlumnesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final alumnes =
        ((_ptot?['alumnes'] as List?) ?? const []).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('alumnes'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 10),
        if (alumnes.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('—'))),
        ...alumnes.map((a) {
          final inici = ((a['inici'] as List?) ?? const [null, null, null]).toList();
          return Carda(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                TextSpan(text: '${a['nom'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' (${a['soci'] ?? ''})', style: const TextStyle(color: textCol, fontSize: 13)),
              ])),
              for (var tr = 1; tr <= 3; tr++)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: DataIniciRow(alumneId: '${a['id']}', trim: tr, inicial: '${inici.length >= tr ? inici[tr - 1] ?? '' : ''}'),
                ),
            ]),
          );
        }),
      ],
    );
  }
}

class DataIniciRow extends StatefulWidget {
  const DataIniciRow({super.key, required this.alumneId, required this.trim, required this.inicial});
  final String alumneId;
  final int trim;
  final String inicial;

  @override
  State<DataIniciRow> createState() => _DataIniciRowState();
}

class _DataIniciRowState extends State<DataIniciRow> {
  late String valor = widget.inicial;

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return Row(children: [
      Expanded(child: Text('${t('dataInici')} ${widget.trim}')),
      OutlinedButton(
        onPressed: () => unawaited(_tria()),
        child: Text(valor.isEmpty ? t('noDefinit') : valor, style: const TextStyle(fontSize: 13.5)),
      ),
    ]);
  }

  Future<void> _tria() async {
    final parts = valor.split('-');
    DateTime ini = DateTime.now();
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? 1;
      final dd = int.tryParse(parts[2]) ?? 1;
      ini = DateTime(y, m, dd);
    }
    final d = await showDatePicker(context: context, initialDate: ini, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final nova = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    setState(() => valor = nova);
    await Estat.i.call('setDataInici', [Estat.i.token, widget.alumneId, widget.trim, nova]);
    await carregaProfe();
    Estat.i.fok();
    Estat.i.refres();
  }
}
