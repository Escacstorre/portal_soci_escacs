// Generic Xip widget — P1 duplication extraction.
// Merges ginys.dart:127 XipEstat and ginys.dart:153 XipQuota into a single
// generic Xip. Original classes are kept as thin wrappers for backward compat.

import 'package:flutter/material.dart';
import '../estils.dart';
import '../estat.dart';

/// Variant selector for [Xip].
enum XipTipus { estat, quota }

/// Generic chip used for both estat and quota states.
///
/// Prefer the named constructors for clarity:
///   Xip.estat(estat: 'Validat')
///   Xip.quota(quota: 'pagat')
/// or the generic:
///   Xip(valor: 'Validat', tipus: XipTipus.estat)
class Xip extends StatelessWidget {
  const Xip({
    super.key,
    required this.valor,
    required this.tipus,
    this.compact = false,
  });

  /// Estat variant: 'Validat' | 'En revisió' | other -> Pendent.
  const Xip.estat({
    super.key,
    required String estat,
    this.compact = false,
  })  : valor = estat,
        tipus = XipTipus.estat;

  /// Quota variant: 'pagat' | 'rebutjat' | other -> En revisió.
  const Xip.quota({
    super.key,
    required String quota,
    this.compact = false,
  })  : valor = quota,
        tipus = XipTipus.quota;

  final String valor;
  final XipTipus tipus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    late final Color color;
    late final String txt;

    if (tipus == XipTipus.estat) {
      if (valor == 'Validat') {
        color = verd;
        txt = t('pagat').replaceAll('Pagat', 'Validat');
      } else if (valor == 'En revisió') {
        color = taronja;
        txt = t('enRev');
      } else {
        color = Colors.grey.shade600;
        txt = t('pendent');
      }
    } else {
      // quota
      if (valor == 'pagat') {
        color = verd;
        txt = t('pagat');
      } else if (valor == 'rebutjat') {
        color = vermell;
        txt = t('rebujat');
      } else {
        color = taronja;
        txt = t('enRev');
      }
    }

    // Preserve original paddings: XipEstat 8/3 @12.5, XipQuota 10/4 @13.
    // Generic defaults to quota-like sizing; compact uses estat-like sizing.
    final padding = tipus == XipTipus.estat || compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final fontSize = tipus == XipTipus.estat || compact ? 12.5 : 13.0;

    return Container(
      padding: padding,
      decoration: decoXip(color),
      child: Text(txt, style: TextStyle(color: color, fontSize: fontSize)),
    );
  }
}

// ------------------------------------------------------------------
// Backward-compat wrappers — keep ginys.dart imports working.
// These delegate to [Xip] so existing code needs no changes.
// ------------------------------------------------------------------

/// Wrapper for backward compat — delegates to [Xip.estat].
class XipEstat extends StatelessWidget {
  const XipEstat({super.key, required this.estat});
  final String estat;

  @override
  Widget build(BuildContext context) => Xip.estat(estat: estat);
}

/// Wrapper for backward compat — delegates to [Xip.quota].
class XipQuota extends StatelessWidget {
  const XipQuota({super.key, required this.quota});
  final String quota;

  @override
  Widget build(BuildContext context) => Xip.quota(quota: quota);
}
