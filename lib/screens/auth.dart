import 'package:flutter/material.dart';

import '../../state.dart';
import '../../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final u = TextEditingController();
  final p = TextEditingController();
  String? err;

  Future<void> _ferLogin() async {
    final st = Estat.i;
    setState(() => err = st.i18n.t('enviant'));
    try {
      final d = (await st.call('login', [u.text.trim().toLowerCase(), p.text]) as Map).cast<String, dynamic>();
      st.setTok(d['token'] as String);
      st.user = {'nom': d['nom'], 'rols': d['rols'], 'rolActiu': d['rolActiu']};
      setState(() => err = null);
      st.entra();
    } catch (_) {
      setState(() => err = Estat.i.toastMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: IdiomaMenu(),
                ),
              ),
              const SizedBox(height: 8),
              Carda(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('inicia').toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titol)),
                    const SizedBox(height: 14),
                    CampText(controller: u, hint: t('usuari'), teclat: TextInputType.emailAddress),
                    CampText(controller: p, hint: t('contra'), obscure: true),
                    if (err != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(err!, style: const TextStyle(color: vermell, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(onPressed: _ferLogin, child: Text(t('inicia'))),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Estat.i.reset('registre'),
                        child: Text(t('registrar')),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => err = t('msgOblida')),
                        child: Text(t('oblida'), style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistreScreen extends StatefulWidget {
  const RegistreScreen({super.key});

  @override
  State<RegistreScreen> createState() => _RegistreScreenState();
}

class _RegistreScreenState extends State<RegistreScreen> {
  final n = TextEditingController(), d = TextEditingController(), tel = TextEditingController();
  final e = TextEditingController(), b = TextEditingController(), c = TextEditingController(), c2 = TextEditingController();
  Map<String, dynamic>? rebut;
  String? msg;
  bool msgErr = false;

  Future<void> _ferRegistre() async {
    final st = Estat.i;
    final t = st.i18n.t;
    setState(() { msg = t('enviant'); msgErr = false; });
    if (c.text != c2.text) {
      setState(() { msg = t('confirma'); msgErr = true; });
      return;
    }
    rebut ??= await triaArxiu('.jpg,.jpeg,.png,.pdf');
    if (!mounted) return;
    if (rebut == null) {
      setState(() { msg = '${t('rebutQuota')}: ${t('pujaFitxer')}'; msgErr = true; });
      return;
    }
    try {
      await st.call('registrarSoci', [
        {
          'nom': n.text, 'dni': d.text, 'telefon': tel.text, 'email': e.text,
          'numBanc': b.text, 'contrasenya': c.text,
        },
        rebut,
      ]);
      setState(() { msg = t('enRev'); msgErr = false; });
      Future.delayed(const Duration(seconds: 3), () => st.reset('login'));
    } catch (_) {
      setState(() { msg = st.toastMsg; msgErr = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final compte = Estat.i.inici?.compte ?? (Estat.i.club.isNotEmpty ? Estat.i.club : '');
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Carda(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('altSoci'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol)),
                const SizedBox(height: 12),
                CampText(controller: n, hint: t('nom')),
                CampText(controller: d, hint: t('dni')),
                CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone),
                CampText(controller: e, hint: t('email'), teclat: TextInputType.emailAddress),
                CampText(controller: b, hint: t('banc')),
                CampText(controller: c, hint: t('contra'), obscure: true),
                CampText(controller: c2, hint: t('confirma'), obscure: true),
                Text('${t('compte')} $compte', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(rebut == null ? Icons.upload_file : Icons.check_circle, color: rebut == null ? null : Colors.green),
                  label: Text(rebut == null ? '${t('rebutQuota')} · ${t('rebut')}' : '${rebut!['name'] ?? t('rebut')}'),
                  onPressed: () async {
                    final f = await triaArxiu('.jpg,.jpeg,.png,.pdf');
                    if (mounted) setState(() => rebut = f);
                  },
                ),
                const SizedBox(height: 4),
                Text(t('pujaFitxer'), style: const TextStyle(fontSize: 12, color: textCol)),
                if (msg != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(msg!, style: TextStyle(fontSize: 13.5, color: msgErr ? vermell : verd)),
                  ),
                const SizedBox(height: 4),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _ferRegistre, child: Text(t('registrar')))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectorScreen extends StatelessWidget {
  const SelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final t = st.i18n.t;
    final rols = st.rols;
    return Scaffold(
      backgroundColor: suau,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.refresh), onPressed: () => st.refrescaUI()),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: IdiomaMenu()),
                    TextButton(onPressed: () => st.logoutUI(), child: Text(t('tanca'))),
                  ]),
                ),
                Text('${t('hola')}, ${st.user?['nom'] ?? ''}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titol)),
                const SizedBox(height: 6),
                Text(t('ambFuncio'), textAlign: TextAlign.center),
                const SizedBox(height: 18),
                ...rols.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: 260,
                        height: 54,
                        child: FilledButton(
                          onPressed: () async {
                            await st.call('canviarRol', [st.token, r]);
                            st.user = {...?st.user, 'rolActiu': r};
                            st.entra();
                          },
                          child: Text(r.toUpperCase()),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
