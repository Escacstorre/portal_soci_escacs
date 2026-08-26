import 'package:flutter_test/flutter_test.dart';
import 'package:portal_soci_escacs/traduccions.dart';
import 'package:portal_soci_escacs/models.dart';

void main() {
  test('t() retorna la clau si no hi ha lx', () {
    final i = Traduccions.instance;
    i.setLx({});
    i.lang = 'CA';
    expect(i.t('guardar'), 'guardar');
  });

  test('t() retorna la traduccio del Sheet segons idioma', () {
    final i = Traduccions.instance;
    i.setLx({
      'CA': {'guardar': 'Guardar CA'},
      'ES': {'guardar': 'Guardar ES'},
    });
    i.lang = 'CA';
    expect(i.t('guardar'), 'Guardar CA');
    i.lang = 'ES';
    expect(i.t('guardar'), 'Guardar ES');
    i.setLx({});
    i.lang = 'CA';
  });

  test('tradueixError parseja #CLAU|p0# amb parametres', () {
    final i = Traduccions.instance;
    i.lang = 'CA';
    i.setLx({'CA': {'SOCI_JA_EXISTEIX': 'El soci {0} ja existeix'}});
    expect(i.tradueixError('#SOCI_JA_EXISTEIX|Pere#'), 'El soci Pere ja existeix');
    expect(i.tradueixError('error sense format'), 'error sense format');
    i.setLx({});
  });

  test('TotSoci.de mapeja el JSON del backend', () {
    final tot = TotSoci.de({
      'inici': {
        'nom': 'Pere',
        'club': 'Escac Torredembarra',
        'estat': 'Actiu',
        'quota': 'pagat',
        'quotaRebut': {'url': 'https://x.y/r.pdf', 'nom': 'r.pdf'},
        'rols': ['Soci'],
        'rolActiu': 'Soci',
        'any': '2026',
        'compte': 'ES12 3456',
        'telefon': '600111222',
      },
      'alumnes': [
        {
          'id': 'A1',
          'nom': 'Anna',
          'trims': [
            {'id': 'P1', 't': 1, 'preu': 90, 'estat': 'Validat', 'rebut': {'url': 'u', 'nom': 'n'}},
            {'t': 2, 'preu': 90, 'estat': 'Pendent'},
            {'t': 3, 'preu': 90, 'estat': 'En revisió'},
          ],
        },
      ],
      'jugadors': [],
    });
    expect(tot.inici.nom, 'Pere');
    expect(tot.inici.quotaRebut!.url, 'https://x.y/r.pdf');
    expect(tot.alumnes.single.nom, 'Anna');
    expect(tot.alumnes.single.trims[0].rebut!.nom, 'n');
    expect(tot.alumnes.single.trims[1].id, isNull);
    expect(tot.jugadors, isEmpty);
  });

  test('GestorDades.de ordena festius i tolera absencies', () {
    final g = GestorDades.de({
      'socis': [
        {'id': 'S1', 'nom': 'Pere', 'email': 'p@x.cat', 'estat': 'Actiu'},
      ],
      'escola': {
        'preuDivendres': '8',
        'festius': ['2026-12-25', '2026-01-06'],
        'trimestres': {'Trim1Inici': '09-15'},
      },
    });
    expect(g.socis.single.estat, 'Actiu');
    expect(g.escola.festius.first, '2026-01-06');
    expect(g.escola.preuDivendres, 8);
    expect(g.escola.trimestres['Trim1Inici'], '09-15');
    expect(g.escola.trimestres['Trim1Fi'], isNull);
  });

  test('ProfeDades.de normalitza sessions i inici', () {
    final p = ProfeDades.de({
      'profe': {'trimestre': 2, 'bases': [80, '85', 90], 'junts': 240, 'serSoci': 30, 'llista': [], 'formulari': {'club': 'X'}},
      'sessions': [
        {'data': '2026-10-02'},
        {},
      ],
      'alumnes': [
        {'id': 'A1', 'nom': 'Anna', 'soci': 'Pere', 'inici': ['2026-09-18']},
      ],
    });
    expect(p.trimestre, 2);
    expect(p.bases[1], 85);
    expect(p.sessions, ['2026-10-02']);
    expect(p.alumnes.single.inici.length, 3);
    expect(p.alumnes.single.inici[1], '');
    expect(p.formulari['club'], 'X');
  });
}
