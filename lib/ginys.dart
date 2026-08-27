import 'dart:async';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'estils.dart';
import 'traduccions.dart';
import 'estat.dart';

class IdiomaMenu extends StatelessWidget {
  const IdiomaMenu({super.key, this.onCanvi});
  final ValueChanged<String>? onCanvi;

  @override
  Widget build(BuildContext context) {
    final i18n = Traduccions.instance;
    final actiu = i18n.lang;
    return PopupMenuButton<String>(
      tooltip: i18n.nomDe(actiu),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 10),
      position: PopupMenuPosition.under,
      onSelected: (l) {
        if (l == actiu) return;
        if (onCanvi != null) {
          onCanvi!(l);
          return;
        }
        setStateIdioma(l);
      },
      itemBuilder: (ctx) => [
        for (final l in i18n.langs)
          PopupMenuItem(
            value: l,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(l == actiu ? Icons.check : Icons.language, size: 16,
                  color: l == actiu ? pri : null),
              const SizedBox(width: 8),
              Text(i18n.nomDe(l),
                  style: TextStyle(
                      fontSize: 14,
                      color: l == actiu ? pri : textCol,
                      fontWeight: l == actiu ? FontWeight.w700 : FontWeight.w500)),
            ]),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: pri.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: pri.withValues(alpha: .18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(actiu.isNotEmpty ? actiu.substring(0, 1).toUpperCase() : '',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: pri)),
          const SizedBox(width: 6),
          Text(i18n.nomDe(actiu),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titol)),
          const SizedBox(width: 2),
          const Icon(Icons.expand_more, size: 18, color: textCol),
        ]),
      ),
    );
  }
}

void setStateIdiomaLocal(String codi) {
  final i18n = Traduccions.instance;
  if (!i18n.langs.contains(codi)) return;
  i18n.lang = codi;
  html.window.localStorage['ps_lang'] = codi;
}

void setStateIdioma(String codi) {
  setStateIdiomaLocal(codi);
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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

class CampText extends StatefulWidget {
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
  State<CampText> createState() => _CampTextState();
}

class _CampTextState extends State<CampText> {
  late bool _amaga = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final etiqueta = widget.obligatori && widget.hint != null ? '${widget.hint} *' : widget.hint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: widget.controller,
        obscureText: _amaga,
        keyboardType: widget.teclat,
        maxLines: _amaga ? 1 : widget.linies,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixText: widget.sufix,
          isDense: true,
          errorText: widget.error,
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(_amaga ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: pri),
                  splashRadius: 20,
                  onPressed: () => setState(() => _amaga = !_amaga),
                )
              : null,
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

void imprimirFormulari(Map d) {
  final t = Estat.i.i18n.t;
  final linia = '<div style="border-bottom:1px solid #c9c9c9;height:30px;margin:14px 0"></div>';
  final sb = StringBuffer();
  sb.write('<!DOCTYPE html><html><head><meta charset="utf-8"><title>${d['club']}</title>');
  sb.write('<style>');
  sb.write('@page{size:A4;margin:18mm 16mm}');
  sb.write('body{font-family:"Open Sans",system-ui,sans-serif;padding:0;color:#222;line-height:1.5}');
  sb.write('.cap{border-bottom:3px solid #051EF5;padding-bottom:14px;margin-bottom:18px;display:flex;align-items:center;gap:14px}');
  sb.write('.cap h1{margin:0;font-size:22px;color:#060201}');
  sb.write('.cap p{margin:2px 0 0;color:#666;font-size:13px}');
  sb.write('.logo{width:54px;height:31px;flex-shrink:0}');
  sb.write('h2{font-size:15px;color:#051EF5;border-bottom:1px solid #e6e6e6;padding-bottom:6px;margin-top:22px}');
  sb.write('.grid2{display:grid;grid-template-columns:1fr 1fr;gap:0 18px}');
  sb.write('.camp{margin:10px 0 0}');
  sb.write('.camp b{font-size:13px;color:#36424E}');
  sb.write('.preu{width:100%;border-collapse:collapse;font-size:14px;margin-top:8px}');
  sb.write('.preu td{padding:6px 4px;border-bottom:1px solid #efefef}');
  sb.write('.preu td:last-child{text-align:right;font-weight:700;color:#060201}');
  sb.write('@media print{body{padding:0}}');
  sb.write('</style></head><body>');

  const logoSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 53.89 31.46" class="logo"><path fill="#051EF5" d="m50.39,25v-3.25l-1.25-1.25V0h-2v1.58h-1.75V0h-1.75v1.67l-1.92.08V0h-1.58v1.58l-1.83-.08V0h-1.83v1.67h-1.75V0h-1.67v20.5l-1.58.83v3.67l-3.08.08v6.25h3.26v-2.83h2.83v2.83h3.54v-2.83h2.83v2.83h3.44v-2.83h2.83v2.83h3.67v-2.83h2.83v2.83h.25v-6.33h-3.5Zm-18.92,3.08h-2.83v-2.83h2.83v2.83Zm6.22,0h-2.83v-2.83h2.83v2.83Zm6.25,0h-2.83v-2.83h2.83v2.83Zm6.38,0h-2.83v-2.83h2.83v2.83Z"/></svg>';

  sb.write('<div class="cap">$logoSvg<div><h1>${d['club']} — ${t('portalSocis')}</h1><p>${t('compte')} <b>${d['compte']}</b></p></div></div>');
  sb.write('<h2>SOCI</h2><div class="grid2">');
  for (final camp in ['Nom', 'DNI', 'Telèfon', 'Email', 'Núm. Banc', 'Contrasenya']) {
    sb.write('<div class="camp"><b>$camp</b>$linia</div>');
  }
  sb.write('</div>');
  sb.write('<h2>ALUMNES</h2>');
  for (var i = 1; i <= 3; i++) {
    sb.write('<p><b>Alumne $i</b>$linia</p><p style="font-size:13px;color:#36424E">[ 1r ] &nbsp; [ 2n ] &nbsp; [ 3r ] &nbsp; <span style="color:#999">marqueu els trimestres pagats</span></p>');
  }
  sb.write('<h2>PREUS ${DateTime.now().year}/${DateTime.now().year + 1}</h2><table class="preu">');
  final bases = (d['bases'] as List?) ?? const [];
  for (var i = 0; i < 3 && i < bases.length; i++) {
    sb.write('<tr><td>Base ${i + 1}${i == 0 ? 'r' : i == 1 ? 'n' : 'r'} trimestre</td><td>${bases[i]} €</td></tr>');
  }
  sb.write('<tr><td>${t('trimJunts')}</td><td>${d['junts']} €</td></tr>');
  sb.write('<tr><td>${t('serSoci')}</td><td>${d['quota']} €</td></tr></table>');
  sb.write('<p style="margin-top:22px;font-size:11px;color:#999;text-align:center">Document generat el ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} — ${d['club']}</p>');
  sb.write('<script>window.onload=function(){setTimeout(function(){window.print()},300)}</script>');
  sb.write('</body></html>');

  final blob = html.Blob([sb.toString()], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  dynamic win;
  try {
    win = html.window.open(url, '_blank');
  } catch (_) {
    win = null;
  }
  if (win != null) {
    Future.delayed(const Duration(seconds: 60), () => html.Url.revokeObjectUrl(url));
    return;
  }
  final marc = html.IFrameElement()
    ..src = url
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0'
    ..style.width = '1px'
    ..style.height = '1px'
    ..style.border = 'none';
  html.document.body?.append(marc);
  marc.onLoad.listen((_) {
    try {
      final cw = marc.contentWindow;
      if (cw != null) (cw as dynamic).callMethod('print');
    } catch (_) {}
  });
  Future.delayed(const Duration(seconds: 60), () {
    marc.remove();
    html.Url.revokeObjectUrl(url);
  });
}
