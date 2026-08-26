// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';

class ConfiguracioPantalla extends StatefulWidget {
  const ConfiguracioPantalla({super.key});

  @override
  State<ConfiguracioPantalla> createState() => _ConfiguracioPantallaState();
}

class _ConfiguracioPantallaState extends State<ConfiguracioPantalla> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: _isAdmin() ? 5 : 3, vsync: this);

  bool _isAdmin() => Estat.i.isAdmin();

  void _tab(int i) {
    Estat.i.cfgTab = ['Club', 'Correus', 'Usuaris', 'Sistema', 'Neteja'][i];
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
            Tab(icon: Icon(Icons.tune, size: 20), text: t('clubBloc')),
            Tab(icon: Icon(Icons.email, size: 20), text: t('correusBloc')),
            if (admin) Tab(icon: Icon(Icons.people, size: 20), text: t('usuarisBloc')),
            if (admin) Tab(icon: Icon(Icons.build, size: 20), text: t('sistemaBloc')),
            if (admin) Tab(icon: Icon(Icons.delete_sweep, size: 20), text: t('netegaBloc')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              const EditorBloc(bloc: 'Club'),
              const EditorBloc(bloc: 'Correus'),
              if (admin) const PestanyaUsuaris(),
              if (admin) const EditorBloc(bloc: 'Sistema'),
              if (admin) const PestanyaNeteja(),
            ],
          ),
        ),
      ],
    );
  }
}

const _etiquetesConfig = <String, (String, String)>{
  'NomClub': ('Nom del club', ''),
  'CompteClub': ('Compte bancari del club', ''),
  'QuotaSoci': ("Preu alta soci (quota anual)", ' €'),
  'PreuFederacio': ('Preu federació anual', ' €'),
  'CorreuClub': ('Correu del club (avisos)', ''),
  'DuradaSessioMinuts': ('Durada de la sessió (minuts)', ''),
  'IdiomaPerDefecte': ('Idioma per defecte (CA/ES)', ''),
  'FolderDrive': ('ID carpeta Drive (buit = per defecte)', ''),
};

class EditorBloc extends StatefulWidget {
  const EditorBloc({super.key, required this.bloc});
  final String bloc;

  @override
  State<EditorBloc> createState() => _EditorBlocState();
}

class _EditorBlocState extends State<EditorBloc> {
  late Future<Map<String, dynamic>> _fut = _carrega();
  Map<String, dynamic> valors = {};
  Map<String, TextEditingController> ctrls = {};

  Future<Map<String, dynamic>> _carrega() async {
    final d = await Estat.i.call('obtenirConfigBloc', [Estat.i.token, widget.bloc]);
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
                    hint: _etiquetesConfig[k]?.$1 ?? k,
                    sufix: _etiquetesConfig[k]?.$2.isEmpty == true ? null : _etiquetesConfig[k]?.$2,
                    linies: k.startsWith('Correu') ? 4 : 1,
                    onChanged: (v) => valors[k] = v,
                  ),
                FilledButton(
                  onPressed: () async {
                    await Estat.i.call('definirConfigBloc', [Estat.i.token, widget.bloc, valors]);
                    Estat.i.mostraOk();
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

class PestanyaUsuaris extends StatefulWidget {
  const PestanyaUsuaris({super.key});

  @override
  State<PestanyaUsuaris> createState() => _PestanyaUsuarisState();
}

class _PestanyaUsuarisState extends State<PestanyaUsuaris> {
  List<Map<String, dynamic>>? usuaris;
  bool nouVisible = false;

  Future<void> _carrega() async {
    final d = ((await Estat.i.call('obtenirUsuaris', [Estat.i.token])) as Map)['usuaris'] as List;
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
          FormulariUsuari(onFet: () {
            setState(() => nouVisible = false);
            _carrega();
          }),
        ...u.map((usr) => Carda(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${usr['email']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pri.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${usr['rol']}', style: const TextStyle(fontSize: 11.5, color: pri)),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: t('modifica'),
                  icon: const Icon(Icons.edit_outlined, size: 20, color: pri),
                  onPressed: () async {
                    final fet = await showDialog<bool>(
                      context: context,
                      builder: (ctx2) => Dialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(t('edicio'), style: const TextStyle(fontWeight: FontWeight.bold, color: titol))),
                              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx2)),
                            ]),
                            const SizedBox(height: 8),
                            FormulariUsuari(existent: usr),
                          ]),
                        ),
                      ),
                    );
                    if (fet == true) _carrega();
                  },
                ),
                IconButton(
                  tooltip: t('elimina'),
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade400),
                  onPressed: () async {
                    final ok = await confirmaEliminacio(context, '${usr['email']} — eliminar?');
                    if (ok != true) return;
                    await Estat.i.call('eliminarUsuari', [Estat.i.token, usr['email']]);
                    Estat.i.mostraOk();
                    _carrega();
                  },
                ),
              ]),
            )),
      ],
    );
  }
}

class FormulariUsuari extends StatefulWidget {
  const FormulariUsuari({super.key, this.existent, this.onFet});
  final Map<String, dynamic>? existent;
  final VoidCallback? onFet;

  @override
  State<FormulariUsuari> createState() => _FormulariUsuariState();
}

class _FormulariUsuariState extends State<FormulariUsuari> {
  late final nom = TextEditingController(text: '${widget.existent?['nom'] ?? ''}');
  late final email = TextEditingController(text: '${widget.existent?['email'] ?? ''}');
  late final pw = TextEditingController();
  late Set<String> rols =
      '${widget.existent?['rol'] ?? ''}'.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  String? err;
  bool intentat = false;

  static const totsRols = ['Admin', 'Junta', 'Profe', 'Soci'];

  Future<void> _desa() async {
    setState(() => intentat = true);
    if (nom.text.trim().isEmpty || email.text.trim().isEmpty || rols.isEmpty) return;
    await Estat.i.call('desarUsuari', [
      Estat.i.token,
      {
        if (widget.existent != null) 'idOriginal': widget.existent!['id'],
        'nom': nom.text,
        'email': email.text,
        'rol': rols.join(','),
        if (pw.text.isNotEmpty) 'contrasenya': pw.text,
      },
    ]);
    Estat.i.mostraOk();
    if (widget.onFet != null) {
      widget.onFet!();
    } else if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final eCamp = t('campObligatori');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampText(controller: nom, hint: t('nom'), obligatori: true, error: (intentat && nom.text.trim().isEmpty) ? eCamp : null),
        CampText(
          controller: email,
          hint: t('email'),
          teclat: TextInputType.emailAddress,
          obligatori: true,
          error: (intentat && email.text.trim().isEmpty) ? eCamp : null,
        ),
        for (final r in totsRols)
          CheckboxListTile(
            dense: true,
            title: Text(r),
            value: rols.contains(r),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() {
              v == true ? rols.add(r) : rols.remove(r);
              err = rols.isEmpty ? t('triaUnRol') : null;
            }),
          ),
        if (intentat && rols.isEmpty)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t('triaUnRol'), style: const TextStyle(color: vermell))),
        CampText(controller: pw, hint: t('contrasenyaOpt'), obscure: true),
        if (err != null)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(err!, style: const TextStyle(color: vermell))),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _desa, child: Text(t('guardar')))),
      ],
    );
  }
}

class PestanyaNeteja extends StatelessWidget {
  const PestanyaNeteja({super.key});

  static const _accions = [
    ('juliol', Icons.cleaning_services),
    ('capdany', Icons.event_repeat),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _accions.map((a) => Carda(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t(a.$1), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: Icon(a.$2, size: 18),
            label: Text(t('executa')),
            onPressed: () async {
              await Estat.i.call('executarNeteja', [Estat.i.token, a.$1]);
              Estat.i.mostraOk();
            },
          ),
        ]),
      )).toList(),
    );
  }
}
