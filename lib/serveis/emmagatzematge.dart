import 'emmagatzematge_stub.dart'
    if (dart.library.html) 'emmagatzematge_web.dart' as impl;

class Emmagatzematge {
  Emmagatzematge._();
  static String? llegeix(String clau) => impl.EmmagatzematgeImpl.llegeix(clau);
  static void desa(String clau, String valor) => impl.EmmagatzematgeImpl.desa(clau, valor);
  static void esborra(String clau) => impl.EmmagatzematgeImpl.esborra(clau);
}
