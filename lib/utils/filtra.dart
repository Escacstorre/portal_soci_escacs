import '../models.dart';

/// Filtra una llista genèrica per text (cerca insensible a majúscules).
///
/// - [llista]: llista original.
/// - [cerca]: text de cerca (es normalitza amb `trim` + `toLowerCase`).
/// - [text]: funció que extreu el text cercable de cada element.
/// - [filtreAddicional]: predicat opcional addicional (p. ex. filtre per estat).
///
/// Exemple:
/// ```dart
/// final socisFiltrats = filtraPerText<SociGestor>(
///   socis,
///   cerca,
///   (s) => '${s.nom} ${s.email} ${s.dni}',
///   filtreAddicional: (s) => s.estat != 'Rebutjat',
/// );
/// ```
List<T> filtraPerText<T>(
  List<T> llista,
  String cerca,
  String Function(T) text, {
  bool Function(T)? filtreAddicional,
}) {
  final q = cerca.trim().toLowerCase();
  return llista.where((e) {
    if (filtreAddicional != null && !filtreAddicional(e)) return false;
    if (q.isNotEmpty) {
      final camp = text(e).toLowerCase();
      if (!camp.contains(q)) return false;
    }
    return true;
  }).toList();
}

/// Agrupa una llista de [PersonaGestor] per [idSoci] després de filtrar per text.
///
/// Extreu la duplicació de `_TabFitxes._grups` i `_TabAlumnes._grups`
/// a [lib/pantalles/gestor/pagat.dart].
///
/// - [llista]: llista de fitxes o alumnes.
/// - [cerca]: text de cerca.
/// - [filtreAddicional]: predicat opcional (p. ex. `_passa` per estat de pagament).
/// - [text]: extractor de text cercable. Per defecte
///   `'${p.nom} ${p.cognoms} ${p.soci}'.toLowerCase()` per compatibilitat amb fitxes;
///   per alumnes es pot passar `(a) => '${a.nom} ${a.soci}'`.
///
/// Retorna un mapa `idSoci -> List<PersonaGestor>`.
Map<String, List<PersonaGestor>> agrupaPerSoci(
  List<PersonaGestor> llista,
  String cerca, {
  bool Function(PersonaGestor)? filtreAddicional,
  String Function(PersonaGestor)? text,
}) {
  final extractor = text ?? (PersonaGestor p) => '${p.nom} ${p.cognoms} ${p.soci}';
  final filtrats = filtraPerText<PersonaGestor>(
    llista,
    cerca,
    extractor,
    filtreAddicional: filtreAddicional,
  );
  final grups = <String, List<PersonaGestor>>{};
  for (final p in filtrats) {
    (grups[p.idSoci] ??= []).add(p);
  }
  return grups;
}
