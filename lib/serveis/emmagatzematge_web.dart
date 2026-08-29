// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class EmmagatzematgeImpl {
  EmmagatzematgeImpl._();
  static String? llegeix(String clau) => html.window.localStorage[clau];
  static void desa(String clau, String valor) => html.window.localStorage[clau] = valor;
  static void esborra(String clau) => html.window.localStorage.remove(clau);
}
