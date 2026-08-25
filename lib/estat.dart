import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'pont.dart';
import 'traduccions.dart';
import 'models.dart';

const urlAppsScript =
    'https://script.google.com/macros/s/AKfycbyCxdv7MNxrlqhvLBruDEumwxuWN4piXILygFS_YCptt0YDmRQu2HBKxEMlQtP9-FIoTA/exec';

const lectures = [
  'getConfigPublic', 'getTraduccions', 'getIniciSoci', 'getTotSoci', 'getTotGestor',
  'getTotProfe', 'getEdicioSoci', 'getEscolaConfig', 'getConfigBloc', 'getUsuaris',
  'getDadesFormulari', 'descarregarICS',
];

class Vista {
  final String nom;
  final dynamic dades;
  const Vista(this.nom, [this.dades]);
}

class Estat {
  Estat._();
  static final Estat i = Estat._();

  final i18n = Traduccions.instance;

  String? token;
  String club = '';
  Map<String, dynamic>? user;
  IniciSoci? inici;
  TotSoci? tot;
  GestorDades? gest;
  ProfeDades? ptot;

  int profeTrim = 0;
  String escolaTab = 'festius';
  String cfgTab = 'Club';
  String pagatText = '';
  String pagatEstat = '';

  final List<Vista> stack = [const Vista('login')];

  final _canvis = StreamController<void>.broadcast();
  Stream<void> get onCanvi => _canvis.stream;
  void refres() => _canvis.add(null);

  int ocupats = 0;
  String? toastMissatge;
  bool toastCorrecte = false;
  Timer? _toastTimer;

  final Map<String, ({dynamic v, DateTime t})> _cache = {};
  static const duracioCachu = Duration(seconds: 90);

  void _notificaOcupat() => refres();

  Future<dynamic> call(String fn, [List<Object?> args = const []]) async {
    final esLectura = lectures.contains(fn);
    if (esLectura) {
      final k = '$fn|${args.map((a) => a.toString()).join('|')}';
      final c = _cache[k];
      if (c != null && DateTime.now().difference(c.t) < duracioCachu) return c.v;
    } else {
      ocupats++;
      _notificaOcupat();
    }
    try {
      final v = await Pont.instance.call(fn, args);
      if (esLectura) {
        final k = '$fn|${args.map((a) => a.toString()).join('|')}';
        _cache[k] = (v: v, t: DateTime.now());
      } else {
        _cache.clear();
      }
      return v;
    } catch (e) {
      final raw = e is ExcepcioPortal ? e.message : e.toString();
      mostraError(i18n.tradueixError(raw));
      if (raw.contains('SESSIO_CADUCADA')) sessioCaducada();
      rethrow;
    } finally {
      if (!esLectura) {
        ocupats--;
        _notificaOcupat();
      }
    }
  }

  void sessioCaducada() {
    posaToken(null);
    user = null;
    inici = null;
    buidaCachu();
    reset('login');
  }

  void buidaCachu() {
    _cache.clear();
    tot = null;
    gest = null;
    ptot = null;
  }

  void mostraError(String msg, {bool ok = false}) {
    toastMissatge = msg.isEmpty ? 'Error' : msg;
    toastCorrecte = ok;
    refres();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 5), () {
      toastMissatge = null;
      refres();
    });
  }

  void mostraOk([String? msg]) => mostraError(msg ?? i18n.t('refrescat'), ok: true);

  // ---------- navegació (sincronitzada amb l'historial del navegador) ----------
  Vista get vistaActual => stack.last;

  void go(String v, [dynamic d]) {
    stack.add(Vista(v, d));
    html.window.history.pushState(stack.length, '', '#$v');
    refres();
  }

  void back() {
    if (stack.length > 1) html.window.history.back();
  }

  /// Rep el control quan l'usuari fa enrere/avançant al navegador.
  void onPopState() {
    final prof = html.window.history.state;
    final idx = (prof is num) ? prof.toInt() : null;
    if (idx == null || idx < 1 || idx > stack.length - 1) {
      while (stack.length > 1) {
        stack.removeLast();
      }
    } else {
      while (stack.length > idx) {
        stack.removeLast();
      }
    }
    refres();
  }

  void reset(String v, [dynamic d]) {
    stack
      ..clear()
      ..add(Vista(v, d));
    html.window.history.replaceState(1, '', '#$v');
    refres();
  }

  // ---------- sessió ----------
  String? obteToken() => html.window.localStorage['ps_token'];
  void posaToken(String? tk) {
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
      unawaited(carregaInici());
    }
  }

  Future<void> _carregaTot() async {
    final d = await call('getTotSoci', [token]);
    tot = TotSoci.de(d);
    inici = tot!.inici;
  }

  Future<void> carregaInici() async {
    await _carregaTot();
    reset('homeSoci', inici);
  }

  Future<void> recarregaTot() => _carregaTot();

  Future<void> refrescaUI() async {
    buidaCachu();
    final v = vistaActual.nom;
    const socil = ['homeSoci', 'classesHome', 'classesAlta', 'classesAlumnes', 'trimestres', 'fitxaHome', 'jugadorAlta', 'jugadors', 'jugadorAnys'];
    const gestl = ['adminHome', 'escola', 'pagat', 'altaRapida'];
    ocupats++;
    _notificaOcupat();
    try {
      if (socil.contains(v)) {
        await recarregaTot();
      } else if (gestl.contains(v)) {
        gest = GestorDades.de(await call('getTotGestor', [token]));
      } else if (v == 'profe' || v == 'profeAlumnes') {
        ptot = ProfeDades.de(await call('getTotProfe', [token, profeTrim]));
      }
    } catch (_) {}
    ocupats--;
    mostraOk();
    refres();
  }

  void tancaSessio() {
    final tk = token;
    posaToken(null);
    user = null;
    inici = null;
    buidaCachu();
    html.window.localStorage.remove('ps_cfg');
    if (tk != null) Pont.instance.call('logout', [tk]);
    reset('login');
  }

  Future<bool> arrenca() async {
    Map<String, dynamic>? cfg;
    try {
      final raw = html.window.localStorage['ps_cfg'];
      if (raw != null) cfg = _parseCfg(raw);
      final t0 = cfg?['t'];
      if (cfg == null ||
          DateTime.now().millisecondsSinceEpoch - (t0 as num? ?? 0) > 600000) {
        cfg = null;
      }
    } catch (_) {
      cfg = null;
    }
    if (cfg == null) {
      try {
        final d = await Pont.instance.call('getConfigPublic');
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
      if (Traduccions.baseLangs.contains(idioma)) i18n.lang = idioma;
      i18n.setLx((cfg['traduccions'] as Map?)?.cast<String, dynamic>());
    }
    final saved = html.window.localStorage['ps_lang'];
    if (saved != null && saved.isNotEmpty) i18n.lang = saved.toUpperCase();

    final tk = obteToken();
    if (tk == null) {
      reset('login');
      return false;
    }
    token = tk;
    try {
      await _carregaTot();
      user = {
        'nom': inici!.nom,
        'rols': inici!.rols,
        'rolActiu': inici!.rolActiu,
      };
      entra();
      return true;
    } catch (_) {
      posaToken(null);
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
