import 'dart:async';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'estils.dart';
import 'traduccions.dart';
import 'estat.dart';

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
  const Capcalera({super.key, this.torna = false, this.tancaSessio = true});
  final bool torna;
  final bool tancaSessio;

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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: IdiomaMenu(),
        ),
        if (rols.length > 1)
          TextButton(
            onPressed: () => st.go('selector'),
            child: Text(st.i18n.t('canviaRol'), style: const TextStyle(fontSize: 13)),
          ),
        if (tancaSessio)
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
      decoration: decoXip(color),
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
      decoration: decoXip(color),
      child: Text(txt, style: TextStyle(color: color, fontSize: 13)),
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
      decoration: decoCard(radi: 10),
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
  const CampText({
    super.key,
    required this.controller,
    this.hint,
    this.teclat,
    this.obscure = false,
    this.onChanged,
    this.sufix,
    this.linies = 1,
    this.error,
    this.obligatori = false,
  });
  final TextEditingController controller;
  final String? hint;
  final TextInputType? teclat;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final String? sufix;
  final int linies;
  final String? error;
  final bool obligatori;

  @override
  Widget build(BuildContext context) {
    final etiqueta = obligatori && hint != null ? '$hint *' : hint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: teclat,
        maxLines: obscure ? 1 : linies,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixText: sufix,
          isDense: true,
          errorText: error,
        ),
      ),
    );
  }
}

class FiltreHora extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue vell, TextEditingValue nou) {
    final d = nou.text.replaceAll(RegExp(r'\D'), '');
    final t = d.length > 4 ? d.substring(0, 4) : d;
    final b = StringBuffer();
    for (var i = 0; i < t.length; i++) {
      b.write(t[i]);
      if (i == 1 && t.length > 2) b.write(':');
    }
    final s = b.toString();
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

String normalitzaHora(String s) {
  final d = s.replaceAll(RegExp(r'\D'), '');
  if (d.length != 4) return s;
  final h = int.parse(d.substring(0, 2));
  final m = int.parse(d.substring(2));
  if (h > 23 || m > 59) return s;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String mostraMesDia(String md) {
  final p = md.split('-');
  if (p.length == 2 && p[0].length == 2 && p[1].length == 2) return '${p[1]}/${p[0]}';
  return md;
}

String mostraData(String ymd) {
  final p = ymd.split('-');
  if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
  return ymd;
}

class CampDataTrim extends StatelessWidget {
  const CampDataTrim({super.key, required this.valor, required this.etiqueta, required this.onCanvi});
  final String valor;
  final String etiqueta;
  final ValueChanged<String> onCanvi;

  DateTime _inicial() {
    final p = valor.split('-');
    if (p.length == 2) {
      final m = int.tryParse(p[0]) ?? 1;
      final d = int.tryParse(p[1]) ?? 1;
      final avui = DateTime.now();
      final anyCurs = avui.month >= 9 ? avui.year : avui.year - 1;
      return DateTime(anyCurs, m.clamp(1, 12), d.clamp(1, 28));
    }
    return DateTime.now();
  }

  Future<void> _tria(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _inicial(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: Locale(Estat.i.i18n.lang.toLowerCase()),
    );
    if (d != null) {
      onCanvi('${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _tria(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          valor.isEmpty ? '—' : mostraMesDia(valor),
          style: TextStyle(fontSize: 15, color: valor.isEmpty ? textCol : titol),
        ),
      ),
    );
  }
}

class CampData extends StatelessWidget {
  const CampData({super.key, required this.valor, required this.etiqueta, required this.onCanvi, this.error, this.obligatori = false});
  final String valor;
  final String etiqueta;
  final ValueChanged<String> onCanvi;
  final String? error;
  final bool obligatori;

  DateTime _inicial() {
    final p = valor.split('-');
    if (p.length == 3) {
      return DateTime(
        int.tryParse(p[0]) ?? DateTime.now().year,
        int.tryParse(p[1]) ?? 1,
        int.tryParse(p[2]) ?? 1,
      );
    }
    return DateTime.now();
  }

  Future<void> _tria(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _inicial(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: Locale(Estat.i.i18n.lang.toLowerCase()),
    );
    if (d != null) {
      onCanvi('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _tria(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: obligatori ? '$etiqueta *' : etiqueta,
            isDense: true,
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            valor.isEmpty ? '—' : mostraData(valor),
            style: TextStyle(fontSize: 15, color: valor.isEmpty ? textCol : titol),
          ),
        ),
      ),
    );
  }
}

class CampHora extends StatelessWidget {
  const CampHora({super.key, required this.controller, this.hint});
  final TextEditingController controller;
  final String? hint;

  Future<void> _rellotge(BuildContext context) async {
    final parts = controller.text.split(':');
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 17,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (t != null) {
      controller.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FiltreHora()],
        maxLength: 5,
        decoration: InputDecoration(
          labelText: hint ?? 'Hora',
          counterText: '',
          isDense: true,
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time, size: 20),
            onPressed: () => _rellotge(context),
          ),
        ),
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

  final marc = html.IFrameElement()
    ..srcdoc = sb.toString()
    ..style.position = 'fixed'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.width = '0'
    ..style.height = '0'
    ..style.border = 'none';
  html.document.body?.append(marc);
  marc.onLoad.listen((_) {
    final cw = marc.contentWindow;
    if (cw != null) (cw as dynamic).callMethod('print');
    Future.delayed(const Duration(seconds: 10), () => marc.remove());
  });
}
