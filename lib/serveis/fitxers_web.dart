// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

import '../estat.dart';

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
        Estat.i.mostraError(Estat.i.i18n.t('maxim5MB'));
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
  sb.write('<h2>${t('soci')}</h2><div class="grid2">');
  for (final camp in [t('nom'), t('dni'), t('telefon'), t('email'), t('banc'), t('contra')]) {
    sb.write('<div class="camp"><b>$camp</b>$linia</div>');
  }
  sb.write('</div>');
  sb.write('<h2>${t('alumnes')}</h2>');
  for (var i = 1; i <= 3; i++) {
    sb.write('<p><b>${t('alumneU')} $i</b>$linia</p><p style="font-size:13px;color:#36424E">[ 1r ] &nbsp; [ 2n ] &nbsp; [ 3r ] &nbsp; <span style="color:#999">${t('marqueuTrimestres')}</span></p>');
  }
  sb.write('<h2>${t('preus')} ${DateTime.now().year}/${DateTime.now().year + 1}</h2><table class="preu">');
  final bases = (d['bases'] as List?) ?? const [];
  for (var i = 0; i < 3 && i < bases.length; i++) {
    sb.write('<tr><td>${t('baseTrim')} ${i + 1}${i == 0 ? 'r' : i == 1 ? 'n' : 'r'} ${t('trimestre')}</td><td>${bases[i]} €</td></tr>');
  }
  sb.write('<tr><td>${t('trimJunts')}</td><td>${d['junts']} €</td></tr>');
  sb.write('<tr><td>${t('serSoci')}</td><td>${d['quota']} €</td></tr></table>');
  sb.write('<p style="margin-top:22px;font-size:11px;color:#999;text-align:center">${t('documentGenerat')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} — ${d['club']}</p>');
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
