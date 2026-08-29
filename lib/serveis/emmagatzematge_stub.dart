class EmmagatzematgeImpl {
  EmmagatzematgeImpl._();
  static final Map<String, String> _mem = {};
  static String? llegeix(String clau) => _mem[clau];
  static void desa(String clau, String valor) => _mem[clau] = valor;
  static void esborra(String clau) => _mem.remove(clau);
  // per a tests: neteja tota la memòria
  static void clearAll() => _mem.clear();
}
