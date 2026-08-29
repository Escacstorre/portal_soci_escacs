import 'package:flutter/material.dart';

import '../estils.dart';
import '../estat.dart';
import '../ginys.dart';

/// Commutador de pagament amb Checkbox + indicador de rebut.
///
/// Extreu la lògica duplicada de:
/// - [lib/pantalles/gestor/fitxa.dart] `_filaTrimestre` i `_chkAny`
/// - [lib/pantalles/gestor/pagat.dart] `_chkAny`
/// - [lib/pantalles/soci.dart] `Trimestres` / `JugadorAnys`
///
/// Mostra un [Checkbox] amb estat [validat] i, a la dreta,
/// - si [rebutUrl] és present → [IconButton] amb [Icons.attach_file] que obre l'URL
/// - si no → [Text] amb `t('noRebut')` (estil 10 / [textCol])
///
/// El canvi d'estat es propaga via [enCanviar].
class CommutadorPagament extends StatelessWidget {
  const CommutadorPagament({
    super.key,
    required this.validat,
    this.rebutUrl,
    required this.enCanviar,
  });

  /// Indica si el pagament està validat (`estat == 'Validat'`).
  final bool validat;

  /// URL del rebut associat. Si és `null` o buida es mostra `noRebut`.
  final String? rebutUrl;

  /// Callback quan l'usuari canvia el checkbox.
  final ValueChanged<bool?> enCanviar;

  bool get _teRebut => rebutUrl != null && rebutUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: validat,
          onChanged: enCanviar,
        ),
        if (_teRebut)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.attach_file, size: 18),
            onPressed: () => obrirUrl(rebutUrl!),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 6),
            child: Text(
              Estat.i.i18n.t('noRebut'),
              style: const TextStyle(fontSize: 10, color: textCol),
            ),
          ),
      ],
    );
  }
}
