import 'dart:async';
import 'dart:convert';
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'pont.dart';
import 'traduccions.dart';
import 'models.dart';
import 'pantalles/ruta.dart';

const urlAppsScript =
    'https://script.google.com/macros/s/AKfycbyCxdv7MNxrlqhvLBruDEumwxuWN4piXILygFS_YCptt0YDmRQu2HBKxEMlQtP9-FIoTA/exec';

const lectures = [
  'obtenirConfigPublic', 'obtenirTraduccions', 'obtenirIniciSoci', 'obtenirTotSoci', 'obtenirTotGestor',
  'obtenirTotProfe', 'obtenirEdicioSoci', 'obtenirConfigEscola', 'obtenirConfigBloc', 'obtenirUsuaris',
  'obtenirDadesFormulari', 'descarregarICS',
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
  int pagatTab = 0;
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

  bool _silenciToast = false;

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
      if (!_silenciToast) mostraError(i18n.tradueixError(raw));
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

  // ---------- navegació (rutes reals del Navigator) ----------
  Vista get vistaActual => stack.last;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MaterialPageRoute _ruta(Vista v) =>
      MaterialPageRoute(builder: (_) => PantallaRuta(vista: v));

  void go(String v, [dynamic d]) {
    stack.add(Vista(v, d));
    navigatorKey.currentState?.push(_ruta(Vista(v, d)));
    WidgetsBinding.instance.addPostFrameCallback((_) => refres());
  }

  void back() {
    if (stack.length > 1) {
      stack.removeLast();
      navigatorKey.currentState?.pop();
    }
  }

  void reset(String v, [dynamic d]) {
    stack
      ..clear()
      ..add(Vista(v, d));
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(_ruta(Vista(v, d)), (r) => false);
    }
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
      reset('adminInici');
    } else {
      unawaited(carregaInici());
    }
  }

  Future<void> _carregaTot() async {
    final d = await call('obtenirTotSoci', [token]);
    tot = TotSoci.de(d);
    inici = tot?.inici;
  }

  Future<void> carregaInici() async {
    await _carregaTot();
    reset('iniciSoci', inici);
  }

  Future<void> recarregaTot() => _carregaTot();

  Future<void> refrescaUI() async {
    buidaCachu();
    final v = vistaActual.nom;
    const socil = ['iniciSoci', 'classesInici', 'classesAlta', 'classesAlumnes', 'trimestres', 'fitxaInici', 'jugadorAlta', 'jugadors', 'jugadorAnys'];
    const gestl = ['adminInici', 'escola', 'pagat', 'altaRapida'];
    ocupats++;
    _notificaOcupat();
    try {
      if (socil.contains(v)) {
        await recarregaTot();
      } else if (gestl.contains(v)) {
        gest = GestorDades.de(await call('obtenirTotGestor', [token]));
      } else if (v == 'profe' || v == 'profeAlumnes') {
        ptot = ProfeDades.de(await call('obtenirTotProfe', [token, profeTrim]));
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
    if (tk != null) Pont.instance.call('tancarSessio', [tk]);
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
        final d = await Pont.instance.call('obtenirConfigPublic');
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
      if (Traduccions.instance.langs.contains(idioma)) i18n.lang = idioma;
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
    _silenciToast = true;
    try {
      await _carregaTot();
      _silenciToast = false;
      final ini = inici;
      if (ini == null) throw Exception('Inici null');
      user = {
        'nom': ini.nom,
        'rols': ini.rols,
        'rolActiu': ini.rolActiu,
      };
      entra();
      return true;
    } catch (_) {
      _silenciToast = false;
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
