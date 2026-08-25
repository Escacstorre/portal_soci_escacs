List<dynamic> _ll(dynamic v) => v is List ? v : const [];

Map<String, dynamic> _mp(dynamic v) =>
    v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};

String _s(dynamic v) => v == null ? '' : '$v';

class RebutInfo {
  const RebutInfo({required this.url, this.nom = ''});
  final String url;
  final String nom;

  static RebutInfo? de(dynamic m) {
    final d = _mp(m);
    if (d.isEmpty || d['url'] == null) return null;
    return RebutInfo(url: _s(d['url']), nom: _s(d['nom']));
  }
}

class TrimAlumne {
  const TrimAlumne({this.id, required this.t, required this.preu, required this.estat, this.rebut});
  final dynamic id;
  final int t;
  final num preu;
  final String estat;
  final RebutInfo? rebut;

  static TrimAlumne de(dynamic m) {
    final d = _mp(m);
    return TrimAlumne(
      id: d['id'],
      t: (d['t'] is num) ? (d['t'] as num).toInt() : int.tryParse(_s(d['t'])) ?? 0,
      preu: (d['preu'] is num) ? d['preu'] as num : num.tryParse(_s(d['preu'])) ?? 0,
      estat: _s(d['estat']),
      rebut: RebutInfo.de(d['rebut']),
    );
  }
}

class AlumneSoci {
  const AlumneSoci({required this.id, required this.nom, required this.telefon, required this.email, required this.trims});
  final String id;
  final String nom;
  final String telefon;
  final String email;
  final List<TrimAlumne> trims;

  static AlumneSoci de(dynamic m) {
    final d = _mp(m);
    return AlumneSoci(
      id: _s(d['id']),
      nom: _s(d['nom']),
      telefon: _s(d['telefon']),
      email: _s(d['email']),
      trims: _ll(d['trims']).map(TrimAlumne.de).toList(),
    );
  }
}

class AnyJugador {
  const AnyJugador({required this.any, required this.preu, required this.estat, this.rebut});
  final String any;
  final num preu;
  final String estat;
  final RebutInfo? rebut;

  static AnyJugador de(dynamic m) {
    final d = _mp(m);
    return AnyJugador(
      any: _s(d['any']),
      preu: (d['preu'] is num) ? d['preu'] as num : num.tryParse(_s(d['preu'])) ?? 0,
      estat: _s(d['estat']),
      rebut: RebutInfo.de(d['rebut']),
    );
  }
}

class JugadorSoci {
  const JugadorSoci({required this.id, required this.nom, required this.cognoms, required this.dataNaix, required this.anys});
  final String id;
  final String nom;
  final String cognoms;
  final String dataNaix;
  final List<AnyJugador> anys;

  static JugadorSoci de(dynamic m) {
    final d = _mp(m);
    return JugadorSoci(
      id: _s(d['id']),
      nom: _s(d['nom']),
      cognoms: _s(d['cognoms']),
      dataNaix: _s(d['dataNaix']),
      anys: _ll(d['anys']).map(AnyJugador.de).toList(),
    );
  }
}

class IniciSoci {
  const IniciSoci({
    required this.nom,
    required this.club,
    required this.estat,
    required this.quota,
    required this.quotaRebut,
    required this.rols,
    required this.rolActiu,
    required this.any,
    required this.compte,
    this.telefon = '',
    this.email = '',
  });
  final String nom;
  final String club;
  final String estat;
  final String quota;
  final RebutInfo? quotaRebut;
  final List<String> rols;
  final String rolActiu;
  final String any;
  final String compte;
  final String telefon;
  final String email;

  static IniciSoci de(dynamic m) {
    final d = _mp(m);
    return IniciSoci(
      nom: _s(d['nom']),
      club: _s(d['club']),
      estat: _s(d['estat']),
      quota: _s(d['quota']),
      quotaRebut: RebutInfo.de(d['quotaRebut']),
      rols: _ll(d['rols']).map((e) => _s(e)).toList(),
      rolActiu: _s(d['rolActiu']),
      any: _s(d['any']),
      compte: _s(d['compte']),
      telefon: _s(d['telefon']),
      email: _s(d['email']),
    );
  }
}

class TotSoci {
  const TotSoci({required this.inici, required this.alumnes, required this.jugadors});
  final IniciSoci inici;
  final List<AlumneSoci> alumnes;
  final List<JugadorSoci> jugadors;

  static TotSoci de(dynamic m) {
    final d = _mp(m);
    return TotSoci(
      inici: IniciSoci.de(d['inici']),
      alumnes: _ll(d['alumnes']).map(AlumneSoci.de).toList(),
      jugadors: _ll(d['jugadors']).map(JugadorSoci.de).toList(),
    );
  }
}

class SociGestor {
  SociGestor({required this.id, required this.nom, required this.dni, required this.telefon, required this.email, required this.rol, required this.estat, required this.rebutQuota});
  final String id;
  final String nom;
  final String dni;
  final String telefon;
  final String email;
  final String rol;
  String estat;
  final RebutInfo? rebutQuota;

  static SociGestor de(dynamic m) {
    final d = _mp(m);
    return SociGestor(
      id: _s(d['id']),
      nom: _s(d['nom']),
      dni: _s(d['dni']),
      telefon: _s(d['telefon']),
      email: _s(d['email']),
      rol: _s(d['rol']),
      estat: _s(d['estat']),
      rebutQuota: RebutInfo.de(d['rebutQuota']),
    );
  }
}

class EscolaConfig {
  const EscolaConfig({required this.preuDivendres, required this.festius, required this.trimestres, required this.hora, required this.lloc, required this.any});
  final num preuDivendres;
  final List<String> festius;
  final Map<String, String> trimestres;
  final String hora;
  final String lloc;
  final String any;

  static EscolaConfig de(dynamic m) {
    final d = _mp(m);
    final trims = _mp(d['trimestres']).map((k, v) => MapEntry(k, _s(v)));
    return EscolaConfig(
      preuDivendres: (d['preuDivendres'] is num) ? d['preuDivendres'] as num : num.tryParse(_s(d['preuDivendres'])) ?? 0,
      festius: _ll(d['festius']).map((e) => _s(e)).toList()..sort(),
      trimestres: trims,
      hora: _s(d['hora']),
      lloc: _s(d['lloc']),
      any: _s(d['any']),
    );
  }
}

class GestorDades {
  const GestorDades({required this.socis, required this.escola});
  final List<SociGestor> socis;
  final EscolaConfig escola;

  static GestorDades de(dynamic m) {
    final d = _mp(m);
    return GestorDades(
      socis: _ll(d['socis']).map(SociGestor.de).toList(),
      escola: EscolaConfig.de(d['escola']),
    );
  }
}

class AlumneProfe {
  const AlumneProfe({required this.id, required this.nom, required this.soci, required this.telefon, required this.inici});
  final String id;
  final String nom;
  final String soci;
  final String telefon;
  final List<String> inici;

  static AlumneProfe de(dynamic m) {
    final d = _mp(m);
    final ini = _ll(d['inici']).map((e) => _s(e)).toList();
    while (ini.length < 3) {
      ini.add('');
    }
    return AlumneProfe(
      id: _s(d['id']),
      nom: _s(d['nom']),
      soci: _s(d['soci']),
      telefon: _s(d['telefon']),
      inici: ini,
    );
  }
}

class ProfeDades {
  const ProfeDades({required this.profe, required this.sessions, required this.alumnes});
  final Map<String, dynamic> profe;
  final List<String> sessions;
  final List<AlumneProfe> alumnes;

  int get trimestre => (profe['trimestre'] is num) ? (profe['trimestre'] as num).toInt() : 1;
  List<num> get bases => _ll(profe['bases']).map((e) => (e is num) ? e : num.tryParse(_s(e)) ?? 0).toList();
  num get junts => (profe['junts'] is num) ? profe['junts'] as num : 0;
  num get serSoci => (profe['serSoci'] is num) ? profe['serSoci'] as num : 0;
  List<Map<String, dynamic>> get llista => _ll(profe['llista']).map(_mp).toList();
  Map<String, dynamic> get formulari => _mp(profe['formulari']);

  static ProfeDades de(dynamic m) {
    final d = _mp(m);
    return ProfeDades(
      profe: _mp(d['profe']),
      sessions: _ll(d['sessions']).map((e) => _s(_mp(e)['data'])).where((s) => s.isNotEmpty).toList(),
      alumnes: _ll(d['alumnes']).map(AlumneProfe.de).toList(),
    );
  }
}
