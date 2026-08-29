import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';
import '../../models.dart';
import 'comu.dart';

class EscolaPantalla extends StatefulWidget {
  const EscolaPantalla({super.key});

  @override
  State<EscolaPantalla> createState() => _EscolaPantallaState();
}

class _EscolaPantallaState extends State<EscolaPantalla> with SingleTickerProviderStateMixin {
  late Future<GestorDades> _fut = carregaGestor();
  bool get _admin => Estat.i.esAdministrador();
  List<String> get _nomsTabs => _admin
      ? const ['festius', 'preus', 'trimestres', 'classes']
      : const ['festius', 'trimestres', 'classes'];
  late final TabController _tabs = TabController(length: _nomsTabs.length, vsync: this, initialIndex: _idx0());
  late final TextEditingController _preuDive = TextEditingController();
  String _preuDiveLast = '';

  int _idx0() {
    final i = _nomsTabs.indexOf(Estat.i.escolaTab);
    return i > -1 ? i : 0;
  }

  EscolaConfig? _escola;

  void _tab(int i) {
    Estat.i.escolaTab = _nomsTabs[i];
  }

  void _syncPreuDive() {
    final cur = _escola == null ? '' : '${_escola!.preuDivendres}';
    if (_preuDiveLast != cur) {
      _preuDiveLast = cur;
      _preuDive.text = cur;
    }
  }

  @override
  void didUpdateWidget(covariant EscolaPantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPreuDive();
  }

  @override
  void dispose() {
    _preuDive.dispose();
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
        _syncPreuDive();
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
                label: Text(t('seleccionaData'), style: const TextStyle(fontSize: 14)),
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
                    Estat.i.buidaCau();
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
                    Estat.i.buidaCau();
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: CampText(controller: _preuDive, hint: t('preuDive'), sufix: ' €', teclat: TextInputType.number))
            ]),
            FilledButton(
              onPressed: () async {
                await Estat.i.call('definirPreuDivendres', [Estat.i.token, _preuDive.text]);
                Estat.i.buidaCau();
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
          Estat.i.buidaCau();
          Estat.i.mostraOk();
          setState(() => _fut = carregaGestor());
        },
      );

  Widget _classes() => _TabsClasses(
        hora: _escola?.hora ?? '17:00',
        lloc: _escola?.lloc ?? '',
        onRefresca: () {
          Estat.i.buidaCau();
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
  void didUpdateWidget(covariant _TabsTrims oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trims != widget.trims) {
      valors = {for (final e in widget.trims.entries) e.key: e.value};
    }
  }

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
                  try {
                    await Estat.i.call('definirTrimestres', [Estat.i.token, valors]);
                    widget.onRefresca();
                  } catch (_) {}
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
  void dispose() {
    hora.dispose();
    lloc.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _TabsClasses oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hora != widget.hora) hora.text = widget.hora;
    if (oldWidget.lloc != widget.lloc) lloc.text = widget.lloc;
  }

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
