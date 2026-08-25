import 'package:flutter/material.dart';

import '../../state.dart';
import '../../widgets.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: _isAdmin() ? 5 : 3, vsync: this);

  bool _isAdmin() => Estat.i.isAdmin();

  void _tab(int i) {
    Estat.i.cfgTab = ['Club', 'Correus', 'Usuaris', 'Sistema', 'Neteja'][i];
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final admin = _isAdmin();
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          labelColor: pri,
          unselectedLabelColor: textCol,
          isScrollable: true,
          onTap: _tab,
          tabs: [
            Tab(text: t('clubBloc')),
            Tab(text: t('correusBloc')),
            if (admin) Tab(text: t('usuarisBloc')),
            if (admin) Tab(text: t('sistemaBloc')),
            if (admin) Tab(text: t('netegaBloc')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              const BlocEditor(bloc: 'Club'),
              const BlocEditor(bloc: 'Correus'),
              if (admin) const UsuarisTab(),
              if (admin) const BlocEditor(bloc: 'Sistema'),
              if (admin) const NetejaTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class BlocEditor extends StatefulWidget {
  const BlocEditor({super.key, required this.bloc});
  final String bloc;

  @override
  State<BlocEditor> createState() => _BlocEditorState();
}

class _BlocEditorState extends State<BlocEditor> {
  late Future<Map<String, dynamic>> _fut = _carrega();
  Map<String, dynamic> valors = {};
  Map<String, TextEditingController> ctrls = {};

  Future<Map<String, dynamic>> _carrega() async {
    final d = await Estat.i.call('getConfigBloc', [Estat.i.token, widget.bloc]);
    return (d as Map).cast<String, dynamic>();
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return FutureBuilder<Map<String, dynamic>>(
      future: _fut,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        if (ctrls.isEmpty) {
          snap.data!.forEach((k, v) {
            ctrls[k] = TextEditingController(text: '$v');
            valors[k] = v;
          });
        }
        final claus = ctrls.keys.toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Carda(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final k in claus)
                  CampText(
                    controller: ctrls[k]!,
                    hint: k,
                    onChanged: (v) => valors[k] = v,
                  ),
                FilledButton(
                  onPressed: () async {
                    await Estat.i.call('setConfigBloc', [Estat.i.token, widget.bloc, valors]);
                    Estat.i.fok();
                    setState(() {
                      for (final c in ctrls.values) {
                        c.dispose();
                      }
                      ctrls = {};
                      valors = {};
                      _fut = _carrega();
                    });
                  },
                  child: Text(t('guardar')),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

class UsuarisTab extends StatefulWidget {
  const UsuarisTab({super.key});

  @override
  State<UsuarisTab> createState() => _UsuarisTabState();
}

class _UsuarisTabState extends State<UsuarisTab> {
  List<Map<String, dynamic>>? usuaris;
  bool nouVisible = false;

  Future<void> _carrega() async {
    final d = ((await Estat.i.call('getUsuaris', [Estat.i.token])) as Map)['usuaris'] as List;
    setState(() => usuaris = d.cast<Map>().map((e) => e.cast<String, dynamic>()).toList());
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_carrega);
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final u = usuaris;
    if (u == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: Text(t('usuarisBloc'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titol))),
          FilledButton.tonal(onPressed: () => setState(() => nouVisible = !nouVisible), child: Text(t('nouUsuari'))),
        ]),
        Text(t('multiRol'), style: const TextStyle(fontSize: 12.5, color: textCol)),
        const SizedBox(height: 10),
        if (nouVisible)
          UsuariForm(onFet: () {
            setState(() => nouVisible = false);
            _carrega();
          }),
        ...u.map((usr) => ItemLlista(children: [
              Expanded(child: Text('${usr['email']}', style: const TextStyle(fontWeight: FontWeight.bold))),
              Flexible(
                child: Text('${usr['rol']}',
                    style: const TextStyle(fontSize: 12.5, color: textCol), overflow: TextOverflow.ellipsis),
              ),
              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () async {
                final fet = await showDialog<bool>(
                  context: context,
                  builder: (_) => Dialog(child: Padding(padding: const EdgeInsets.all(16), child: UsuariForm(existent: usr))),
                );
                if (fet == true) _carrega();
              }),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), onPressed: () async {
                await Estat.i.call('eliminarUsuari', [Estat.i.token, usr['email']]);
                Estat.i.fok();
                _carrega();
              }),
            ])),
      ],
    );
  }
}

class UsuariForm extends StatefulWidget {
  const UsuariForm({super.key, this.existent, this.onFet});
  final Map<String, dynamic>? existent;
  final VoidCallback? onFet;

  @override
  State<UsuariForm> createState() => _UsuariFormState();
}

class _UsuariFormState extends State<UsuariForm> {
  late final nom = TextEditingController(text: '${widget.existent?['nom'] ?? ''}');
  late final email = TextEditingController(text: '${widget.existent?['email'] ?? ''}');
  late final pw = TextEditingController();
  late Set<String> rols =
      '${widget.existent?['rol'] ?? ''}'.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  String? err;

  static const totsRols = ['Admin', 'Junta', 'Profe', 'Soci'];

  Future<void> _desa() async {
    final t = Estat.i.i18n.t;
    if (rols.isEmpty) {
      setState(() => err = t('triaUnRol'));
      return;
    }
    await Estat.i.call('guardarUsuari', [
      Estat.i.token,
      {
        if (widget.existent != null) 'idOriginal': widget.existent!['id'],
        'nom': nom.text,
        'email': email.text,
        'rol': rols.join(','),
        if (pw.text.isNotEmpty) 'contrasenya': pw.text,
      },
    ]);
    Estat.i.fok();
    if (widget.onFet != null) {
      widget.onFet!();
    } else if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampText(controller: nom, hint: t('nom')),
        CampText(controller: email, hint: t('email'), teclat: TextInputType.emailAddress),
        for (final r in totsRols)
          CheckboxListTile(
            dense: true,
            title: Text(r),
            value: rols.contains(r),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() {
              v == true ? rols.add(r) : rols.remove(r);
            }),
          ),
        CampText(controller: pw, hint: t('contrasenyaOpt'), obscure: true),
        if (err != null)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(err!, style: const TextStyle(color: Color(0xFFC62828)))),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('guardar')))),
      ],
    );
  }
}

class NetejaTab extends StatelessWidget {
  const NetejaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('juliol'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.cleaning_services, size: 18),
              label: Text(t('executa')),
              onPressed: () async {
                await Estat.i.call('executarNeteja', [Estat.i.token, 'juliol']);
                Estat.i.fok();
              },
            ),
          ]),
        ),
        Carda(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('capdany'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.event_repeat, size: 18),
              label: Text(t('executa')),
              onPressed: () async {
                await Estat.i.call('executarNeteja', [Estat.i.token, 'capdany']);
                Estat.i.fok();
              },
            ),
          ]),
        ),
      ],
    );
  }
}
