import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'bridge.dart';
import 'i18n.dart';

const appsScriptUrl =
    'https://script.google.com/macros/s/AKfycbyCxdv7MNxrlqhvLBruDEumwxuWN4piXILygFS_YCptt0YDmRQu2HBKxEMlQtP9-FIoTA/exec';

const reads = [
  'getConfigPublic', 'getTraduccions', 'getIniciSoci', 'getTotSoci', 'getTotGestor',
  'getTotProfe', 'getEdicioSoci', 'getEscolaConfig', 'getConfigBloc', 'getUsuaris',
  'getDadesFormulari', 'descarregarICS',
];

class Vista {
  final String nom;
  final dynamic dades;
  Vista(this.nom, [this.dades]);
}

class Estat {
  Estat._();
  static final Estat i = Estat._();

  final i18n = I18n.instance;

  String? token;
  String club = '';
  Map<String, dynamic>? user;
  Map<String, dynamic>? inici;
  Map<String, dynamic>? tot;
  Map<String, dynamic>? gest;
  Map<String, dynamic>? ptot;

  int profeTrim = 0;
  String escolaTab = 'festius';
  String cfgTab = 'Club';
  String pagatText = '';
  String pagatEstat = '';

  final List<Vista> stack = [Vista('login')];

  final _canvis = StreamController<void>.broadcast();
  Stream<void> get onCanvi => _canvis.stream;
  void refres() => _canvis.add(null);

  int ocupats = 0;
  String? toastMsg;
  bool toastOk = false;
  Timer? _toastTimer;

  final Map<String, ({dynamic v, DateTime t})> _cache = {};
  static const cacheTtl = Duration(seconds: 90);

  void _notificaOcupat() => refres();

  Future<dynamic> call(String fn, [List<Object?> args = const []]) async {
    final esLectura = reads.contains(fn);
    if (esLectura) {
      final k = '$fn|${args.map((a) => a.toString()).join('|')}';
      final c = _cache[k];
      if (c != null && DateTime.now().difference(c.t) < cacheTtl) return c.v;
    } else {
      ocupats++;
      _notificaOcupat();
    }
    try {
      final v = await Bridge.instance.call(fn, args);
      if (esLectura) {
        final k = '$fn|${args.map((a) => a.toString()).join('|')}';
        _cache[k] = (v: v, t: DateTime.now());
      } else {
        _cache.clear();
      }
      return v;
    } catch (e) {
      ferr(i18n.tradueixError(e is PortalException ? e.message : e.toString()));
      rethrow;
    } finally {
      if (!esLectura) {
        ocupats--;
        _notificaOcupat();
      }
    }
  }

  void buidaCache() {
    _cache.clear();
    tot = null;
    gest = null;
    ptot = null;
  }

  void ferr(String msg, {bool ok = false}) {
    toastMsg = msg.isEmpty ? 'Error' : msg;
    toastOk = ok;
    refres();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 5), () {
      toastMsg = null;
      refres();
    });
  }

  void fok([String? msg]) => ferr(msg ?? i18n.t('refrescat'), ok: true);

  // ---------- navegació ----------
  Vista get vistaActual => stack.last;

  void go(String v, [dynamic d]) {
    stack.add(Vista(v, d));
    refres();
  }

  void back() {
    if (stack.length > 1) stack.removeLast();
    refres();
  }

  void reset(String v, [dynamic d]) {
    stack
      ..clear()
      ..add(Vista(v, d));
    refres();
  }

  // ---------- sessió ----------
  String? getTok() => html.window.localStorage['ps_token'];
  void setTok(String? tk) {
    token = tk;
    if (tk == null) {
      html.window.localStorage.remove('ps_token');
    } else {
      html.window.localStorage['ps_token'] = tk;
    }
  }

  bool esGestor() {
    final r = user?['rolActiu'];
    return r == 'Junta' || r == 'Admin';
  }

  bool isAdmin() => user?['rolActiu'] == 'Admin';

  List<String> get rols =>
      ((user?['rols'] as List?) ?? const []).map((e) => e.toString()).toList();

  void entra() {
    final r = user?['rolActiu'];
    if (r == 'Profe') {
      profeTrim = 0;
      reset('profe');
    } else if (r == 'Junta' || r == 'Admin') {
      reset('adminHome');
    } else {
      carregaInici();
    }
  }

  Future<void> carregaInici() async {
    final d = await call('getTotSoci', [token]);
    tot = (d as Map).cast<String, dynamic>();
    inici = tot!['inici'] as Map<String, dynamic>?;
    reset('homeSoci', inici);
  }

  Future<void> refreshTot() async {
    final d = await call('getTotSoci', [token]);
    tot = (d as Map).cast<String, dynamic>();
    inici = tot!['inici'] as Map<String, dynamic>?;
  }

  Future<void> refrescaUI() async {
    buidaCache();
    final v = vistaActual.nom;
    const socil = ['homeSoci', 'classesHome', 'classesAlta', 'classesAlumnes', 'trimestres', 'fitxaHome', 'jugadorAlta', 'jugadors', 'jugadorAnys'];
    const gestl = ['adminHome', 'escola', 'pagat', 'altaRapida'];
    ocupats++;
    _notificaOcupat();
    try {
      if (socil.contains(v)) {
        await refreshTot();
      } else if (gestl.contains(v)) {
        gest = ((await call('getTotGestor', [token])) as Map).cast<String, dynamic>();
      } else if (v == 'profe' || v == 'profeAlumnes') {
        ptot = ((await call('getTotProfe', [token, profeTrim])) as Map).cast<String, dynamic>();
      }
    } catch (_) {}
    ocupats--;
    fok();
    refres();
  }

  void logoutUI() {
    final tk = token;
    setTok(null);
    user = null;
    inici = null;
    buidaCache();
    html.window.localStorage.remove('ps_cfg');
    if (tk != null) Bridge.instance.call('logout', [tk]);
    reset('login');
  }

  Future<bool> arrenca() async {
    Map<String, dynamic>? cfg;
    try {
      final raw = html.window.localStorage['ps_cfg'];
      if (raw != null) {
        cfg = (await Future.value(_parseCfg(raw)));
        final t0 = cfg?['t'];
        if (cfg == null || DateTime.now().millisecondsSinceEpoch - (t0 as num) > 600000) cfg = null;
      }
    } catch (_) {
      cfg = null;
    }
    if (cfg == null) {
      try {
        final d = await Bridge.instance.call('getConfigPublic');
        cfg = (d as Map).cast<String, dynamic>();
        cfg['t'] = DateTime.now().millisecondsSinceEpoch;
        html.window.localStorage['ps_cfg'] = jsonEncode(cfg);
      } catch (_) {
        cfg = null;
      }
    }
    if (cfg != null) {
      club = '${cfg['club'] ?? ''}';
      final idioma = '${cfg['idioma'] ?? 'CA'}'.toUpperCase();
      if (I18n.baseLangs.contains(idioma)) I18n.instance.lang = idioma;
      I18n.instance.setLx((cfg['traduccions'] as Map?)?.cast<String, dynamic>());
    }
    final saved = html.window.localStorage['ps_lang'];
    if (saved != null && saved.isNotEmpty) I18n.instance.lang = saved.toUpperCase();

    final tk = getTok();
    if (tk == null) {
      reset('login');
      return false;
    }
    token = tk;
    try {
      final d = await Bridge.instance.call('getTotSoci', [tk]);
      tot = (d as Map).cast<String, dynamic>();
      inici = tot!['inici'] as Map<String, dynamic>;
      user = {
        'nom': inici!['nom'],
        'rols': inici!['rols'],
        'rolActiu': inici!['rolActiu'],
      };
      entra();
      return true;
    } catch (_) {
      setTok(null);
      reset('login');
      return false;
    }
  }

  static Map<String, dynamic>? _parseCfg(String raw) {
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }
}
