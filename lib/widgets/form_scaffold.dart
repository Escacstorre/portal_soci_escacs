import 'package:flutter/material.dart';

import '../estils.dart';

/// Bastida estàndard per a formularis centrats amb scroll.
///
/// Extreu el patró repetit 14× a:
///
/// ```dart
/// Center(
///   child: SingleChildScrollView(
///     padding: EdgeInsets.all(16),
///     child: ConstrainedBox(
///       constraints: BoxConstraints(maxWidth: 460/440/470/480),
///       child: Carda(child: Column(...)),
///     ),
///   ),
/// )
/// ```
///
/// Vist a: [lib/pantalles/soci.dart:204], [lib/pantalles/gestor/pagat.dart],
/// [lib/pantalles/gestor/escola.dart], [lib/pantalles/gestor/fitxa.dart],
/// [lib/pantalles/configuracio.dart:111], [lib/pantalles/gestor/comu.dart],
/// [lib/pantalles/acces.dart], etc.
///
/// Usa [Carda] i [suau] de [estils.dart] per mantenir la decoració
/// coherent. Manté compatibilitat: no esborra codi antic, només centralitza.
class BastidaFormulari extends StatelessWidget {
  const BastidaFormulari({
    super.key,
    required this.child,
    this.ampladaMaxima = 460,
  });

  /// Contingut interior — habitualment un [Column] amb camps.
  /// S'embolica automàticament amb [Carda].
  final Widget child;

  /// Amplada màxima del formulari. Per defecte 460 ([ampleMaxForm]).
  /// Altres valors habituals: 440 ([ampleMaxAlumne]), 470 ([ampleMaxGestor]),
  /// 480 ([ampleMaxLogin]).
  final double ampladaMaxima;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ampladaMaxima),
          child: Carda(
            child: child,
          ),
        ),
      ),
    );
  }
}
