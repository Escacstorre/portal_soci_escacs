class Traduccions {
  Traduccions._();
  static final Traduccions instance = Traduccions._();

  String lang = 'CA';
  Map<String, dynamic> lx = {};

  static const List<String> baseLangs = ['CA', 'ES'];

  List<String> get langs {
    final lls = [...baseLangs];
    for (final k in lx.keys) {
      if (!lls.contains(k)) lls.add(k);
    }
    return lls;
  }

  String t(String k) {
    final dLx = lx[lang];
    if (dLx is Map && dLx[k] != null) return '${dLx[k]}';
    final caLx = lx['CA'];
    if (caLx is Map && caLx[k] != null) return '${caLx[k]}';
    return k;
  }

  String tradueixError(String msg) {
    final s = msg.trim();
    if (!s.startsWith('#') || !s.endsWith('#') || s.length < 3) return s;
    final parts = s.substring(1, s.length - 1).split('|');
    final dic = (lx[lang] ?? lx['CA'] ?? {}) as Map?;
    var txt = (dic?[parts[0]] ?? (lx['CA'] as Map?)?[parts[0]] ?? parts[0]) as String;
    for (var i = 1; i < parts.length; i++) {
      txt = txt.replaceAll('{${i - 1}}', parts[i]);
    }
    return txt;
  }

  void setLx(Map<String, dynamic>? m) {
    lx = m ?? {};
  }
}
