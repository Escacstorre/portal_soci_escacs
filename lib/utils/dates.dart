// Centralized date helpers — P1 duplication extraction.
// Extracted from ginys.dart (mostraData, mostraMesDia, FiltreHora,
// normalitzaHora, CampData/CampDataTrim pickers) and models.dart
// (_dataTrim, IniciSoci._avuiYmd).
// Keep this file dependency-light; UI pickers stay in ginys.dart but
// delegate here for parsing/formatting.

import 'package:flutter/services.dart';

// ------------------------------------------------------------------
// Display helpers (thin, pure)
// ------------------------------------------------------------------

/// "2026-08-29" -> "29/08/2026" — ginys.dart:288 original.
String mostraData(String ymd) {
  final p = ymd.split('-');
  if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
  return ymd;
}

/// "08-29" -> "29/08" — ginys.dart:282 original.
String mostraMesDia(String md) {
  final p = md.split('-');
  if (p.length == 2 && p[0].length == 2 && p[1].length == 2) {
    return '${p[1]}/${p[0]}';
  }
  return md;
}

/// Normalizes "1730" / "17:30" / "17-30" -> "17:30" if valid, else returns original.
/// ginys.dart:273 original.
String normalitzaHora(String s) {
  final d = s.replaceAll(RegExp(r'\D'), '');
  if (d.length != 4) return s;
  final h = int.parse(d.substring(0, 2));
  final m = int.parse(d.substring(2));
  if (h > 23 || m > 59) return s;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

// ------------------------------------------------------------------
// Input formatter
// ------------------------------------------------------------------

/// Auto-inserts ":" while typing HHMM -> HH:MM. ginys.dart:258 original.
class FiltreHora extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue vell, TextEditingValue nou) {
    final d = nou.text.replaceAll(RegExp(r'\D'), '');
    final t = d.length > 4 ? d.substring(0, 4) : d;
    final b = StringBuffer();
    for (var i = 0; i < t.length; i++) {
      b.write(t[i]);
      if (i == 1 && t.length > 2) b.write(':');
    }
    final s = b.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

// ------------------------------------------------------------------
// Central utility class — used by models.dart and pickers
// ------------------------------------------------------------------

class DateUtils {
  DateUtils._();

  /// DateTime -> "YYYY-MM-DD"
  static String toYMD(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// DateTime -> "MM-DD"
  static String toMD(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Today as "YYYY-MM-DD" — replaces IniciSoci._avuiYmd (models.dart:147).
  static String avuiYMD() => toYMD(DateTime.now());

  /// Back-compat alias for _avuiYmd.
  static String avuiYmd() => avuiYMD();

  /// Normalizes various backend date representations to "MM-DD".
  /// Original: models.dart _dataTrim (lines 8-24).
  static String dataTrim(dynamic v) {
    if (v == null) return '';
    final s = v == null ? '' : '$v';
    final p = s.split('-');
    if (p.length == 2 && p[0].length == 2 && p[1].length == 2) return s;
    if (p.length == 3 && p[1].length == 2 && p[2].length == 2) {
      return '${p[1]}/${p[2]}';
    }
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    const mesos = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    for (final e in mesos.entries) {
      if (s.contains(e.key)) {
        final d2 =
            RegExp(r'\b(\d{1,2})\b').firstMatch(s.replaceFirst(e.key, ''));
        if (d2 != null) {
          return '${e.value.toString().padLeft(2, '0')}-${d2.group(0)!.padLeft(2, '0')}';
        }
      }
    }
    return s;
  }

  /// Back-compat alias for _dataTrim top-level.
  static String dataTrimD(dynamic v) => dataTrim(v);

  // ----------------------------------------------------------------
  // Picker helpers — extracted duplication between CampData / CampDataTrim
  // ----------------------------------------------------------------

  /// Parses "YYYY-MM-DD" -> DateTime, fallback to now. Used by CampData._inicial.
  static DateTime inicialFromYMD(String valor) {
    final p = valor.split('-');
    if (p.length == 3) {
      return DateTime(
        int.tryParse(p[0]) ?? DateTime.now().year,
        int.tryParse(p[1]) ?? 1,
        int.tryParse(p[2]) ?? 1,
      );
    }
    return DateTime.now();
  }

  /// Parses "MM-DD" -> DateTime with curs logic (Aug-Jul school year).
  /// Used by CampDataTrim._inicial (ginys.dart:300).
  static DateTime inicialFromMD(String valor) {
    final p = valor.split('-');
    if (p.length == 2) {
      final m = int.tryParse(p[0]) ?? 1;
      final d = int.tryParse(p[1]) ?? 1;
      final avui = DateTime.now();
      final curs = avui.month >= 8 ? avui.year : avui.year - 1;
      final any = m >= 8 ? curs : curs + 1;
      final mm = m.clamp(1, 12);
      final ultim = DateTime(any, mm + 1, 0).day;
      return DateTime(any, mm, d.clamp(1, ultim));
    }
    return DateTime.now();
  }

  /// Formats year picker result as "YYYY-MM-DD".
  static String formatYMD(DateTime d) => toYMD(d);

  /// Formats month-day picker result as "MM-DD".
  static String formatMD(DateTime d) => toMD(d);
}

// Top-level aliases so existing `import 'utils/dates.dart'` works
// without requiring `DateUtils.` prefix for the most common helpers.

/// Alias for DateUtils.dataTrim — exposes models.dart _dataTrim publicly.
String dataTrim(dynamic v) => DateUtils.dataTrim(v);

/// Alias for DateUtils.avuiYMD — exposes IniciSoci._avuiYmd publicly.
String avuiYMD() => DateUtils.avuiYMD();

/// Alias with legacy name.
String avuiYmd() => DateUtils.avuiYMD();
