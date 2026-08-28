class Traduccions {
  Traduccions._();
  static final Traduccions instance = Traduccions._();

  String lang = 'CA';
  Map<String, dynamic> lx = {};

  static const List<String> baseLangs = ['CA', 'ES'];

  List<String> get langs {
    final lls = <String>[];
    for (final k in baseLangs) {
      final d = lx[k];
      if (d is Map && d.isNotEmpty) lls.add(k);
    }
    for (final k in lx.keys) {
      if (!lls.contains(k)) {
        final d = lx[k];
        if (d is Map && d.isNotEmpty) lls.add(k);
      }
    }
    if (lls.isEmpty) return const ['CA', 'ES'];
    return lls;
  }

  String nomDe(String codi) {
    final d = lx[codi];
    if (d is Map && d['nomIdioma'] != null) return '${d['nomIdioma']}';
    return codi;
  }

  String t(String k, [List<String>? params]) {
    var txt = lx[lang] is Map && (lx[lang] as Map)[k] != null
        ? '${(lx[lang] as Map)[k]}'
        : (lx['CA'] is Map && (lx['CA'] as Map)[k] != null
            ? '${(lx['CA'] as Map)[k]}'
            : k);
    if (params != null) {
      for (var i = 0; i < params.length; i++) {
        txt = txt.replaceAll('{$i}', params[i]);
      }
    }
    return txt;
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
