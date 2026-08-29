import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';

Future<void> carregaProfe() async {
  final st = Estat.i;
  if (st.profeTrim <= 0) {
    final d0 = await st.call('obtenirTotProfe', [st.token, null]);
    st.dadesProfessor = ProfeDades.de(d0);
    st.profeTrim = st.dadesProfessor?.trimestre ?? 0;
  }
  final d = await st.call('obtenirTotProfe', [st.token, st.profeTrim]);
  st.dadesProfessor = ProfeDades.de(d);
}

class ProfePantalla extends StatefulWidget {
  const ProfePantalla({super.key});

  @override
  State<ProfePantalla> createState() => _ProfePantallaState();
}

class _ProfePantallaState extends State<ProfePantalla> {
  bool _mostraLlista = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (Estat.i.dadesProfessor == null) await carregaProfe();
      Estat.i.refres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final p = st.dadesProfessor;
    if (p == null) return const Center(child: CircularProgressIndicator());
    final llista = p.llista;
    final bases = p.bases;
    String base(int i) => i < bases.length ? '${bases[i]}' : '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${t('profeBenv')} ${st.user?['nom'] ?? ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BotoGran(titol: t('llista'), icon: Icons.receipt_long, onTap: () => setState(() => _mostraLlista = !_mostraLlista)),
            const SizedBox(width: 16),
            BotoGran(titol: t('alumnes'), icon: Icons.school, onTap: () => st.go('profeAlumnes')),
          ],
        ),
        if (_mostraLlista) ...[
          const SizedBox(height: 16),
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
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Carda(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('calendari'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CalendariGraella(
                    sessions: p.sessions,
                    festius: p.festius.toSet(),
                    anyCurs: p.anyCurs != 0 ? p.anyCurs : (DateTime.now().month >= 8 ? DateTime.now().year : DateTime.now().year - 1),
                    mostraHora: true,
                  ),
                  const SizedBox(height: 8),
                  Text('${p.sessions.length} ${t('sessioClasse')}',
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
            const SizedBox(width: 16),
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
                  _preuFila(t('trimJunts'), '${p.junts} €'),
                  _preuFila(t('serSoci'), '${p.serSoci} €'),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 18),
                    label: Text(t('imprimir'), style: const TextStyle(fontSize: 13)),
                    onPressed: () => imprimirFormulari(p.formulari),
                  ),
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

class ProfeAlumnesPantalla extends StatelessWidget {
  const ProfeAlumnesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final alumnes = Estat.i.dadesProfessor?.alumnes ?? const <AlumneProfe>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('alumnes'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
        const SizedBox(height: 10),
        if (alumnes.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('—'))),
        ...alumnes.map((a) => Carda(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                    text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                  TextSpan(text: a.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' (${a.soci})', style: const TextStyle(color: textCol, fontSize: 13)),
                ])),
                for (var tr = 1; tr <= 3; tr++)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: FilaDataInici(alumneId: a.id, trim: tr, inicial: a.inici[tr - 1]),
                  ),
              ]),
            )),
      ],
    );
  }
}

class FilaDataInici extends StatefulWidget {
  const FilaDataInici({super.key, required this.alumneId, required this.trim, required this.inicial});
  final String alumneId;
  final int trim;
  final String inicial;

  @override
  State<FilaDataInici> createState() => _FilaDataIniciState();
}

class _FilaDataIniciState extends State<FilaDataInici> {
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
      ini = DateTime(
        int.tryParse(parts[0]) ?? DateTime.now().year,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[2]) ?? 1,
      );
    }
    final d = await showDatePicker(context: context, initialDate: ini, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final nova = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    setState(() => valor = nova);
    await Estat.i.call('definirDataInici', [Estat.i.token, widget.alumneId, widget.trim, nova]);
    await carregaProfe();
    Estat.i.mostraOk();
    Estat.i.refres();
  }
}
