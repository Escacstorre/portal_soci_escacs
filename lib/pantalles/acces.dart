import 'package:flutter/material.dart';

import '../../estils.dart';
import '../../estat.dart';
import '../../ginys.dart';

class IniciSessioPantalla extends StatefulWidget {
  const IniciSessioPantalla({super.key});

  @override
  State<IniciSessioPantalla> createState() => _IniciSessioPantallaState();
}

class _IniciSessioPantallaState extends State<IniciSessioPantalla> {
  final u = TextEditingController();
  final p = TextEditingController();
  String? err;
  bool _veuContra = false;

  Future<void> _ferLogin() async {
    final st = Estat.i;
    setState(() => err = st.i18n.t('enviant'));
    try {
      final d = (await st.call('iniciarSessio', [u.text.trim().toLowerCase(), p.text]) as Map).cast<String, dynamic>();
      st.posaToken(d['token'] as String);
      st.user = {'nom': d['nom'], 'rols': d['rols'], 'rolActiu': d['rolActiu']};
      if (!mounted) return;
      setState(() => err = null);
      st.entra();
    } catch (_) {
      if (!mounted) return;
      setState(() => err = Estat.i.toastMissatge ?? Estat.i.i18n.t('error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    return Container(
      decoration: const BoxDecoration(gradient: gradientFons),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: ampleMaxLogin),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: decoCardGran(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IdiomaMenu(
                            onCanvi: (c) {
                              if (mounted) setState(() => setStateIdiomaLocal(c));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            const IconaClub(mida: 96),
                            const SizedBox(height: 14),
                            Text(
                              Estat.i.club.isNotEmpty ? Estat.i.club : 'Portal Socis',
                              style: estilTitol,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(t('inicia'), style: estilSubTitol),
                      const SizedBox(height: 14),
                      TextField(
                        controller: u,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                          labelText: t('usuari'),
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiBoto)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: p,
                        obscureText: !_veuContra,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _ferLogin(),
                        decoration: InputDecoration(
                          labelText: t('contra'),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_veuContra ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: pri),
                            splashRadius: 20,
                            onPressed: () => setState(() => _veuContra = !_veuContra),
                          ),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiBoto)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (err != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(err ?? '', style: estilError),
                        ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _ferLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: pri,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiBoto)),
                          ),
                          child: Text(t('inicia'), style: estilBotoText),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Estat.i.go('registre'),
                          child: Text(t('registrar'), style: TextStyle(color: pri, fontSize: 14)),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => err = t('msgOblida')),
                          child: Text(t('oblida'), style: const TextStyle(fontSize: 13, color: textCol)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrePantalla extends StatefulWidget {
  const RegistrePantalla({super.key});

  @override
  State<RegistrePantalla> createState() => _RegistrePantallaState();
}

class _RegistrePantallaState extends State<RegistrePantalla> {
  final n = TextEditingController(), d = TextEditingController(), tel = TextEditingController();
  final e = TextEditingController(), b = TextEditingController(), c = TextEditingController(), c2 = TextEditingController();
  Map<String, dynamic>? rebut;
  String? msg;
  bool msgErr = false;
  bool intentat = false;

  String? errDe(TextEditingController x) =>
      (intentat && x.text.trim().isEmpty) ? Estat.i.i18n.t('campObligatori') : null;

  Future<void> _ferRegistre() async {
    final st = Estat.i;
    final t = st.i18n.t;
    setState(() => intentat = true);
    final buit = [n, d, tel, e, b, c].any((x) => x.text.trim().isEmpty);
    if (buit || c.text != c2.text) {
      setState(() { msg = null; msgErr = true; });
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
      if (!mounted) return;
      setState(() { msg = st.toastMissatge ?? st.i18n.t('error'); msgErr = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final compte = Estat.i.inici?.compte ?? (Estat.i.club.isNotEmpty ? Estat.i.club : '');
    return Container(
      decoration: const BoxDecoration(gradient: gradientFons),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: ampleMaxLogin),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: decoCardGran(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            const IconaClub(mida: 84),
                            const SizedBox(height: 12),
                            Text(t('altSoci'), style: estilTitol, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      CampText(controller: n, hint: t('nom'), obligatori: true, error: errDe(n)),
                      CampText(controller: d, hint: t('dni'), obligatori: true, error: errDe(d)),
                      CampText(controller: tel, hint: t('telefon'), teclat: TextInputType.phone, obligatori: true, error: errDe(tel)),
                      CampText(controller: e, hint: t('email'), teclat: TextInputType.emailAddress, obligatori: true, error: errDe(e)),
                      CampText(controller: b, hint: t('banc'), obligatori: true, error: errDe(b)),
                      CampText(controller: c, hint: t('contra'), obscure: true, obligatori: true, error: errDe(c)),
                      CampText(
                        controller: c2,
                        hint: t('confirma'),
                        obscure: true,
                        obligatori: true,
                        error: (intentat && c.text != c2.text) ? t('confirma') : errDe(c2),
                      ),
                      Text('${t('compte')} $compte', style: const TextStyle(fontSize: 13, color: textCol)),
                      const SizedBox(height: 4),
                      Text('${t('rebutQuota')} ${Estat.i.quota}€', style: const TextStyle(fontSize: 13, color: textCol)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: Icon(rebut == null ? Icons.upload_file : Icons.check_circle,
                            color: rebut == null ? null : verd),
                        label: Text(rebut == null ? '${t('rebutQuota')} · ${t('rebut')}' : '${rebut?['name'] ?? t('rebut')}'),
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
                          child: Text(msg ?? '', style: msgErr ? estilError : estilOk),
                        ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _ferRegistre,
                          style: FilledButton.styleFrom(
                            backgroundColor: pri,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiBoto)),
                          ),
                          child: Text(t('altSoci'), style: estilBotoText),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Estat.i.reset('login'),
                          child: Text(t('inicia'), style: TextStyle(color: pri, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectorPantalla extends StatelessWidget {
  const SelectorPantalla({super.key});

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IdiomaMenu(),
                    ),
                    TextButton(onPressed: () => st.tancaSessio(), child: Text(t('tanca'))),
                  ]),
                ),
                Text('${t('hola')}, ${st.user?['nom'] ?? ''}',
                    style: estilTitol),
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
