import 'dart:async';

import 'package:flutter/material.dart';

import 'estils.dart';
import 'traduccions.dart';
import 'estat.dart';
import 'serveis/emmagatzematge.dart';
import 'utils/dates.dart' as dates;
import 'widgets/xip.dart' as xip;
export 'serveis/fitxers.dart';
export 'utils/dates.dart' hide FiltreHora, mostraData, mostraMesDia, normalitzaHora;
export 'widgets/xip.dart' hide XipEstat, XipQuota;

class IdiomaMenu extends StatefulWidget {
  const IdiomaMenu({super.key, this.onCanvi});
  final ValueChanged<String>? onCanvi;

  @override
  State<IdiomaMenu> createState() => _IdiomaMenuState();
}

class _IdiomaMenuState extends State<IdiomaMenu> {
  late StreamSubscription<void> _sub;

  @override
  void initState() {
    super.initState();
    _sub = Estat.i.onCanvi.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = Traduccions.instance;
    final actiu = i18n.lang;
    return PopupMenuButton<String>(
      tooltip: i18n.nomDe(actiu),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 10),
      position: PopupMenuPosition.under,
      onSelected: (l) {
        if (l == actiu) return;
        if (widget.onCanvi != null) {
          widget.onCanvi!(l);
          return;
        }
        setStateIdioma(l);
      },
      itemBuilder: (ctx) => [
        for (final l in i18n.langs)
          PopupMenuItem(
            value: l,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(l == actiu ? Icons.check : Icons.language, size: 16,
                  color: l == actiu ? pri : null),
              const SizedBox(width: 8),
              Text(i18n.nomDe(l),
                  style: TextStyle(
                      fontSize: 14,
                      color: l == actiu ? pri : textCol,
                      fontWeight: l == actiu ? FontWeight.w700 : FontWeight.w500)),
            ]),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: pri.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: pri.withValues(alpha: .18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(actiu.isNotEmpty ? actiu.substring(0, 1).toUpperCase() : '',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: pri)),
          const SizedBox(width: 6),
          Text(i18n.nomDe(actiu),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titol)),
          const SizedBox(width: 2),
          const Icon(Icons.expand_more, size: 18, color: textCol),
        ]),
      ),
    );
  }
}

void setStateIdiomaLocal(String codi) {
  final i18n = Traduccions.instance;
  if (!i18n.langs.contains(codi)) return;
  i18n.lang = codi;
  Emmagatzematge.desa('ps_lang', codi);
}

void setStateIdioma(String codi) {
  setStateIdiomaLocal(codi);
  Estat.i.refres();
}

class Capcalera extends StatelessWidget implements PreferredSizeWidget {
  const Capcalera({super.key, this.torna = false, this.tancaSessio = true});
  final bool torna;
  final bool tancaSessio;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final st = Estat.i;
    final rols = st.rols;
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: titol,
      surfaceTintColor: Colors.white,
      elevation: 0.5,
      leading: torna
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => st.back())
          : null,
      automaticallyImplyLeading: false,
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: IdiomaMenu(),
        ),
        if (rols.length > 1)
          TextButton(
            onPressed: () => st.go('selector'),
            child: Text(st.i18n.t('canviaRol'), style: const TextStyle(fontSize: 13)),
          ),
        if (tancaSessio)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => st.tancaSessio(),
              child: Text(st.i18n.t('tanca'), style: const TextStyle(fontSize: 13)),
            ),
          ),
      ],
    );
  }
}

// XipEstat/XipQuota now centralized in widgets/xip.dart — thin wrappers for backward compat.
// Real implementation in lib/widgets/xip.dart; re-exported above.
typedef XipEstat = xip.XipEstat;
typedef XipQuota = xip.XipQuota;
// Generic Xip also available via `export 'widgets/xip.dart'`.

class ItemLlista extends StatelessWidget {
  const ItemLlista({super.key, required this.children, this.onTap});
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: decoCard(radi: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(children: [...children]),
        ),
      ),
    );
  }
}

class CampText extends StatefulWidget {
  const CampText({
    super.key,
    required this.controller,
    this.hint,
    this.teclat,
    this.obscure = false,
    this.onChanged,
    this.sufix,
    this.linies = 1,
    this.error,
    this.obligatori = false,
  });
  final TextEditingController controller;
  final String? hint;
  final TextInputType? teclat;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final String? sufix;
  final int linies;
  final String? error;
  final bool obligatori;

  @override
  State<CampText> createState() => _CampTextState();
}

class _CampTextState extends State<CampText> {
  late bool _amaga = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final etiqueta = widget.obligatori && widget.hint != null ? '${widget.hint} *' : widget.hint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: widget.controller,
        obscureText: _amaga,
        keyboardType: widget.teclat,
        maxLines: _amaga ? 1 : widget.linies,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixText: widget.sufix,
          isDense: true,
          errorText: widget.error,
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(_amaga ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: pri),
                  splashRadius: 20,
                  onPressed: () => setState(() => _amaga = !_amaga),
                )
              : null,
        ),
      ),
    );
  }
}

// Date helpers centralized in utils/dates.dart — thin wrappers for backward compat.
// Real implementations in lib/utils/dates.dart; also re-exported above.
class FiltreHora extends dates.FiltreHora {}

String normalitzaHora(String s) => dates.normalitzaHora(s);
String mostraMesDia(String md) => dates.mostraMesDia(md);
String mostraData(String ymd) => dates.mostraData(ymd);

class CampDataTrim extends StatelessWidget {
  const CampDataTrim({super.key, required this.valor, required this.etiqueta, required this.onCanvi});
  final String valor;
  final String etiqueta;
  final ValueChanged<String> onCanvi;

  DateTime _inicial() => dates.DateUtils.inicialFromMD(valor);

  Future<void> _tria(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _inicial(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: Locale(Estat.i.i18n.lang.toLowerCase()),
    );
    if (d != null) {
      onCanvi(dates.DateUtils.formatMD(d));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _tria(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          valor.isEmpty ? '—' : mostraMesDia(valor),
          style: TextStyle(fontSize: 15, color: valor.isEmpty ? textCol : titol),
        ),
      ),
    );
  }
}

class CampData extends StatelessWidget {
  const CampData({super.key, required this.valor, required this.etiqueta, required this.onCanvi, this.error, this.obligatori = false});
  final String valor;
  final String etiqueta;
  final ValueChanged<String> onCanvi;
  final String? error;
  final bool obligatori;

  DateTime _inicial() => dates.DateUtils.inicialFromYMD(valor);

  Future<void> _tria(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _inicial(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: Locale(Estat.i.i18n.lang.toLowerCase()),
    );
    if (d != null) {
      onCanvi(dates.DateUtils.formatYMD(d));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _tria(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: obligatori ? '$etiqueta *' : etiqueta,
            isDense: true,
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            valor.isEmpty ? '—' : mostraData(valor),
            style: TextStyle(fontSize: 15, color: valor.isEmpty ? textCol : titol),
          ),
        ),
      ),
    );
  }
}

class CampHora extends StatelessWidget {
  const CampHora({super.key, required this.controller, this.hint});
  final TextEditingController controller;
  final String? hint;

  Future<void> _rellotge(BuildContext context) async {
    final parts = controller.text.split(':');
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 17,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (t != null) {
      controller.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FiltreHora()],
        maxLength: 5,
        decoration: InputDecoration(
          labelText: hint ?? Estat.i.i18n.t('hora'),
          counterText: '',
          isDense: true,
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time, size: 20),
            onPressed: () => _rellotge(context),
          ),
        ),
      ),
    );
  }
}

class CalendariGraella extends StatefulWidget {
  const CalendariGraella({super.key, required this.sessions, required this.festius, required this.anyCurs, this.mostraHora = true});
  final List<String> sessions;
  final Set<String> festius;
  final int anyCurs;
  final bool mostraHora;

  @override
  State<CalendariGraella> createState() => _CalendariGraellaState();
}

class _CalendariGraellaState extends State<CalendariGraella> {
  late final int _anyCurs;
  late int _idx;
  final _mesos = const [9, 10, 11, 12, 1, 2, 3, 4, 5];
  static const _clauMesos = ['', 'mesGener', 'mesFebrer', 'mesMarc', 'mesAbril', 'mesMaig', 'mesJuny', 'mesJuliol', 'mesAgost', 'mesSetembre', 'mesOctubre', 'mesNovembre', 'mesDesembre'];
  static const _clauDies = ['diaDl', 'diaDt', 'diaDc', 'diaDj', 'diaDv', 'diaDs', 'diaDg'];

  String _ymd(int y, int m, int d) => '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _anyCurs = widget.anyCurs != 0 ? widget.anyCurs : (DateTime.now().month >= 8 ? DateTime.now().year : DateTime.now().year - 1);
    final now = DateTime.now();
    _idx = 0;
    for (var i = 0; i < _mesos.length; i++) {
      final mm = _mesos[i];
      final y = mm >= 8 ? _anyCurs : _anyCurs + 1;
      if (mm == now.month && y == now.year) { _idx = i; break; }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Estat.i.i18n.t;
    final sessSet = widget.sessions.toSet();
    final mm = _mesos[_idx];
    final y = mm >= 8 ? _anyCurs : _anyCurs + 1;
    final diesMes = DateTime(y, mm + 1, 0).day;
    final primer = DateTime(y, mm, 1).weekday;
    return Column(children: [
      Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: _idx > 0 ? () => setState(() => _idx--) : null,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(child: Center(child: Text('${t(_clauMesos[mm])} $y', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titol)))),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: _idx < _mesos.length - 1 ? () => setState(() => _idx++) : null,
          visualDensity: VisualDensity.compact,
        ),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        for (final d in _clauDies)
          Expanded(child: Center(child: Text(t(d), style: const TextStyle(fontSize: 11, color: textCol)))),
      ]),
      const SizedBox(height: 4),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: [
          for (var i = 1; i < primer; i++) const SizedBox.shrink(),
          for (var d = 1; d <= diesMes; d++) Builder(builder: (_) {
            final ymd = _ymd(y, mm, d);
            final esFestiu = widget.festius.contains(ymd);
            final esSessio = sessSet.contains(ymd);
            Color bg = Colors.transparent;
            Color fg = titol;
            String marca = '';
            if (esFestiu) { bg = vermell.withValues(alpha: .12); fg = vermell; marca = '✖'; }
            else if (esSessio) { bg = verd.withValues(alpha: .12); fg = verd; marca = '✔'; }
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
              child: Stack(alignment: Alignment.center, children: [
                Text('$d', style: TextStyle(fontSize: 12, color: fg, fontWeight: esSessio || esFestiu ? FontWeight.bold : FontWeight.normal)),
                if (marca.isNotEmpty) Positioned(top: 1, right: 2, child: Text(marca, style: TextStyle(fontSize: 8, color: fg))),
              ]),
            );
          }),
        ],
      ),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.check, size: 12, color: verd), const SizedBox(width: 4), Text(t('sessio'), style: const TextStyle(fontSize: 11, color: textCol)),
        const SizedBox(width: 12), const Icon(Icons.close, size: 12, color: vermell), const SizedBox(width: 4), Text(t('festiu'), style: const TextStyle(fontSize: 11, color: textCol)),
      ]),
    ]);
  }
}
