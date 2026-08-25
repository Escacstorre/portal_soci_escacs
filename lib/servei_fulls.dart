import 'dart:convert';

import 'package:http/http.dart' as http;

/// Servei d'accés directe al Google Sheet via l'API v4.
///
/// Llegeix dades públiques (traduccions, configuració) sense passar per Apps Script.
/// Requereix:
///   1. Un projecte Google Cloud amb Google Sheets API activada
///   2. Una clau d'API (API key)
///   3. El full compartit amb "Tothom que tingui l'enllaç pot veure-ho"
class ServeiFulls {
  /// ID del Google Spreadsheet (treure de la URL del full).
  /// Exemple: si la URL és
  ///   https://docs.google.com/spreadsheets/d/ABC123/edit
  /// llavors l'ID és `ABC123`.
  static const String fullId = 'YOUR_SPREADSHEET_ID';

  /// Clau d'API de Google Cloud (Google Sheets API habilitada).
  static const String clauApi = 'YOUR_API_KEY';

  static const String _base =
      'https://sheets.googleapis.com/v4/spreadsheets';

  static final ServeiFulls _instancia = ServeiFulls._();
  factory ServeiFulls() => _instancia;
  ServeiFulls._();

  final Map<String, dynamic> _memoria = {};

  /// Llegeix un rang del full com a llista de files (cada fila és una llista de strings).
  Future<List<List<String>>> llegeixRang(String rang) async {
    final clau = '$fullId|$rang';
    final cacheat = _memoria[clau];
    if (cacheat != null) return cacheat as List<List<String>>;

    final uri = Uri.parse('$_base/$fullId/values/$rang?key=$clauApi');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Error llegint el full: ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final vals = json['values'] as List<dynamic>? ?? [];
    final resultat = vals
        .map((fila) => (fila as List).map((c) => '$c').toList())
        .toList();

    _memoria[clau] = resultat;
    return resultat;
  }

  /// Neteja la memòria cau.
  void netejaCachu() => _memoria.clear();

  /// Llegeix les traduccions del full `Traduccions`.
  ///
  /// Estructura esperada del full:
  ///   A       | B    | C    | ...
  ///   clauCA  | CA   | ES   | ...
  ///   inicia  | Inicia la sessió | Iniciar sesión | ...
  ///
  /// Retorna: `{ 'CA': { 'inicia': 'Inicia la sessió', ... }, 'ES': { ... } }`
  Future<Map<String, Map<String, String>>> llegeixTraduccions() async {
    const rang = 'Traduccions!A1:Z500';
    final files = await llegeixRang(rang);

    if (files.isEmpty) return {};

    final resultat = <String, Map<String, String>>{};
    final idiomes = <String>[];

    // Primera fila: capçalera (clau, CA, ES, ...)
    if (files.first.isNotEmpty) {
      for (var i = 1; i < files.first.length; i++) {
        idiomes.add(files.first[i].toUpperCase().trim());
        resultat[idiomes.last] = {};
      }
    }

    // Files de dades
    for (var i = 1; i < files.length; i++) {
      final fila = files[i];
      if (fila.isEmpty || fila[0].trim().isEmpty) continue;
      final clau = fila[0].trim();

      for (var j = 1; j < fila.length && j - 1 < idiomes.length; j++) {
        final valor = fila[j].trim();
        if (valor.isNotEmpty) {
          resultat[idiomes[j - 1]]![clau] = valor;
        }
      }
    }

    return resultat;
  }

  /// Llegeix la configuració pública del full `Config`.
  ///
  /// Estructura esperada:
  ///   Clau            | Valor
  ///   NomClub         | Club d'Escacs Torredembarra
  ///   IdiomaPerDefecte| CA
  ///
  /// Retorna: `{ 'NomClub': 'Club d\'Escacs Torredembarra', ... }`
  Future<Map<String, String>> llegeixConfig() async {
    const rang = 'Config!A1:B100';
    final files = await llegeixRang(rang);

    final resultat = <String, String>{};
    for (final fila in files) {
      if (fila.length >= 2 && fila[0].trim().isNotEmpty) {
        resultat[fila[0].trim()] = fila[1].trim();
      }
    }
    return resultat;
  }
}
