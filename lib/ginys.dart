import 'dart:async';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'traduccions.dart';
import 'estat.dart';

const pri = Color(0xFF1A5FB4);
const titol = Color(0xFF1B2733);
const textCol = Color(0xFF3D4A57);
const suau = Color(0xFFF4F6F8);
const verd = Color(0xFF2E7D32);
const taronja = Color(0xFFB36B00);
const vermell = Color(0xFFC62828);

const _nomsIdioma = {'CA': 'Català', 'ES': 'Español'};

String nomIdioma(String codi) => _nomsIdioma[codi] ?? codi;

class IdiomaMenu extends StatelessWidget {
  const IdiomaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = Traduccions.instance;
    return DropdownButton<String>(
      value: i18n.lang,
      underline: const SizedBox.shrink(),
      isDense: true,
      icon: const Icon(Icons.language, size: 18),
      items: [
        for (final l in i18n.langs)
          DropdownMenuItem(value: l, child: Text(nomIdioma(l), style: const TextStyle(fontSize: 14, color: textCol))),
      ],
      onChanged: (l) {
        if (l == null || l == i18n.lang) return;
        setStateIdioma(l);
      },
    );
  }
}

void setStateIdioma(String codi) {
  final i18n = Traduccions.instance;
  if (!i18n.langs.contains(codi)) return;
  i18n.lang = codi;
  html.window.localStorage['ps_lang'] = codi;
  Estat.i.refres();
}

class Capcalera extends StatelessWidget implements PreferredSizeWidget {
  const Capcalera({super.key, this.torna = false});
  final bool torna;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final rols = st.rols;
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: titol,
      surfaceTintColor: Colors.white,
      elevation: 0.5,
      leading: torna
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => st.back())
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: st.i18n.t('refrescat'),
          onPressed: () => st.refrescaUI(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: IdiomaMenu(),
        ),
        if (rols.length > 1)
          TextButton(
            onPressed: () => st.go('selector'),
            child: Text(st.i18n.t('canviaRol'), style: const TextStyle(fontSize: 13)),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => st.tancaSessio(),
            child: Text(st.i18n.t('tanca'), style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class XipEstat extends StatelessWidget {
  const XipEstat({super.key, required this.estat});
  final String estat;

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    Color color; String txt;
    if (estat == 'Validat') {
      color = verd;
      txt = t('pagat').replaceAll('Pagat', 'Validat');
    } else if (estat == 'En revisió') {
      color = taronja;
      txt = t('enRev');
    } else {
      color = Colors.grey.shade600;
      txt = t('pendent');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
      child: Text(txt, style: TextStyle(color: color, fontSize: 12.5)),
    );
  }
}

class XipQuota extends StatelessWidget {
  const XipQuota({super.key, required this.quota});
  final String quota;

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    late Color color; late String txt;
    if (quota == 'pagat') {
      color = verd; txt = t('pagat');
    } else if (quota == 'rebutjat') {
      color = vermell; txt = t('rebujat');
    } else {
      color = taronja; txt = t('enRev');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
      child: Text(txt, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}

class Carda extends StatelessWidget {
  const Carda({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class ItemLlista extends StatelessWidget {
  const ItemLlista({super.key, required this.children, this.onTap});
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(children: [...children]),
        ),
      ),
    );
  }
}

class CampText extends StatelessWidget {
  const CampText({super.key, required this.controller, this.hint, this.teclat, this.obscure = false, this.onChanged});
  final TextEditingController controller;
  final String? hint;
  final TextInputType? teclat;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: teclat,
        onChanged: onChanged,
        decoration: InputDecoration(hintText: hint, isDense: true),
      ),
    );
  }
}

Future<Map<String, dynamic>?> triaArxiu(String accept) async {
  final completer = Completer<Map<String, dynamic>?>();
  final inp = html.InputElement(type: 'file')
    ..accept = accept
    ..style.display = 'none';
  html.document.body?.append(inp);
  inp.onChange.listen((_) async {
    try {
      final f = inp.files?.first;
      if (f == null) {
        completer.complete(null);
        return;
      }
      if (f.size > 5 * 1024 * 1024) {
        Estat.i.mostraError('Màxim 5 MB');
        completer.complete(null);
        return;
      }
      final reader = html.FileReader();
      final done = Completer<String>();
      reader.onLoadEnd.listen((_) => done.complete(reader.result as String));
      reader.readAsDataUrl(f);
      final dataUrl = await done.future;
      completer.complete({'name': f.name, 'mimeType': f.type, 'data': dataUrl.split(',')[1]});
    } catch (_) {
      completer.complete(null);
    }
  });
  inp.click();
  unawaited(completer.future.whenComplete(() => inp.remove()));
  return completer.future;
}

void obrirUrl(String url) {
  html.window.open(url, '_blank');
}

void descarregarArxiu(String contingut, String mime, String nom) {
  final blob = html.Blob([contingut], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final a = html.AnchorElement(href: url)..download = nom;
  html.document.body?.append(a);
  a.click();
  a.remove();
  Future.delayed(const Duration(seconds: 2), () => html.Url.revokeObjectUrl(url));
}

void imprimirFormulari(Map d) async {
  final t = Estat.i.i18n.t;
  final dynamic w = html.window.open('', '_blank');
  if (w == null) return;
  final linia = '<div style="border-bottom:1px solid #333;height:26px;margin:14px 0"></div>';
  final sb = StringBuffer();
  sb.write('<html><head><title>${d['club']}</title>');
  sb.write('<style>body{font-family:sans-serif;padding:24px;color:#222}h1{font-size:20px}h2{font-size:15px;margin-top:18px}.preu td{padding:3px 0;font-size:14px}.preu td:last-child{text-align:right}</style></head><body>');
  sb.write('<h1>${d['club']} — ${t('portalSocis')}</h1>');
  sb.write('<p>${t('compte')} <b>${d['compte']}</b></p>');
  sb.write('<h2>SOCI</h2>');
  for (final camp in ['Nom:', 'DNI:', 'Telèfon:', 'Email:', 'Núm. Banc:', 'Contrasenya:']) {
    sb.write('<p><b>$camp</b>$linia</p>');
  }
  sb.write('<h2>ALUMNES</h2>');
  for (var i = 1; i <= 3; i++) {
    sb.write('<p><b>Alumne $i:</b>$linia</p><p>[ 1r ] &nbsp;[ 2n ] &nbsp;[ 3r ]</p>');
  }
  sb.write('<h2>PREUS</h2><table class="preu">');
  final bases = (d['bases'] as List?) ?? const [];
  for (var i = 0; i < 3 && i < bases.length; i++) {
    sb.write('<tr><td>Base ${i + 1} trim</td><td>${bases[i]} €</td></tr>');
  }
  sb.write('<tr><td>${t('trimJunts')}</td><td>${d['junts']} €</td></tr>');
  sb.write('<tr><td>${t('serSoci')}</td><td>${d['quota']} €</td></tr></table>');
  sb.write('</body></html>');
  w.document?.write(sb.toString());
  w.document?.close();
  w.focus();
  w.print();
}
