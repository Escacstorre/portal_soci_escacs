// Centralized form validation helpers — P1 duplication extraction.
// Replaces repeated patterns like:
//   (intentat && c.text.trim().isEmpty) ? Estat.i.i18n.t('campObligatori') : null
// found in gestor.dart, soci.dart, acces.dart, configuracio.dart.

import 'package:flutter/material.dart';
import '../estat.dart';

/// Mixin for StatefulWidgets that need required-field validation.
///
/// Usage:
/// ```dart
/// class _MyState extends State<MyWidget> with ValidacioForm {
///   bool intentat = false;
///   final nom = TextEditingController();
///   @override Widget build(BuildContext context) {
///     return CampText(
///       controller: nom,
///       error: requisit(nom, intentat),
///     );
///   }
/// }
/// ```
mixin ValidacioForm<T extends StatefulWidget> on State<T> {
  /// Returns translated 'campObligatori' if [intentat] and controller is empty, else null.
  String? requisit(TextEditingController c, bool intentat) =>
      intentat && c.text.trim().isEmpty
          ? Estat.i.i18n.t('campObligatori')
          : null;

  /// Shorthand for validating multiple controllers at once.
  bool hiHaBuits(List<TextEditingController> cs) =>
      cs.any((c) => c.text.trim().isEmpty);

  /// Returns true if any of [cs] is empty after trim.
  bool teBuits(List<TextEditingController> cs) => hiHaBuits(cs);
}

/// Extension on TextEditingController for inline validation.
///
/// Usage:
/// ```dart
/// error: controller.requisit(intentat)
/// // or
/// if (controller.esBuit) ...
/// ```
extension ValidacioCtrl on TextEditingController {
  /// Returns 'campObligatori' message if [intentat] && empty, else null.
  String? requisit(bool intentat) =>
      intentat && text.trim().isEmpty
          ? Estat.i.i18n.t('campObligatori')
          : null;

  /// True if trimmed text is empty.
  bool get esBuit => text.trim().isEmpty;

  /// True if trimmed text is not empty.
  bool get noEsBuit => text.trim().isNotEmpty;

  /// Shorthand: null if not empty, else 'campObligatori' when [intentat].
  String? errorSiBuit(bool intentat) => requisit(intentat);
}

/// Standalone helper for stateless contexts where mixin is not available.
String? requisitCamp(TextEditingController c, bool intentat) =>
    intentat && c.text.trim().isEmpty
        ? Estat.i.i18n.t('campObligatori')
        : null;
