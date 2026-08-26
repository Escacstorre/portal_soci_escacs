import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const pri = Color(0xFF051EF5);
const titol = Color(0xFF060201);
const textCol = Color(0xFF666666);
const suau = Color(0xFFF3F3F3);
const verd = Color(0xFF2E7D32);
const taronja = Color(0xFFF9A825);
const vermell = Color(0xFFC62828);

const TextStyle estilTitol = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titol);
const TextStyle estilSubTitol = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titol);
const TextStyle estilCos = TextStyle(fontSize: 14, color: textCol);
const TextStyle estilXip = TextStyle(fontSize: 12.5);
const TextStyle estilError = TextStyle(fontSize: 13.5, color: vermell);
const TextStyle estilOk = TextStyle(fontSize: 13.5, color: verd);
const TextStyle estilTitolCard = TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titol);
const TextStyle estilBotoGran = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
const TextStyle estilBotoText = TextStyle(fontSize: 15);
const TextStyle estilToast = TextStyle(color: Colors.white, fontSize: 14);

const double radiCard = 12;
const double radiBoto = 10;
const double radiGran = 16;

const double ampleMaxForm = 460;
const double ampleMaxLogin = 480;
const double ampleMaxGestor = 470;
const double ampleMaxAlumne = 440;

const Gradient gradientFons = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [suau, Colors.white],
);

BoxDecoration decoCard({double radi = radiCard, double ombra = .06}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radi),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: ombra),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

BoxDecoration decoCardGran({double radi = radiGran}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radi),
      boxShadow: [
        BoxShadow(
          color: pri.withValues(alpha: .12),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );

BoxDecoration decoXip(Color color) => BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
    );

const InputDecoration decoInput = InputDecoration(
  isDense: true,
  border: OutlineInputBorder(),
);

const double midaIconaClub = 48;

const _svgLogo = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 53.89 31.46">'
    '<path fill="#051EF5" d="m50.39,25v-3.25l-1.25-1.25V0h-2v1.58h-1.75V0h-1.75v1.67l-1.92.08V0h-1.58v1.58l-1.83-.08V0h-1.83v1.67h-1.75V0h-1.67v20.5l-1.58.83v3.67l-3.08.08v6.25h3.26v-2.83h2.83v2.83h3.54v-2.83h2.83v2.83h3.44v-2.83h2.83v2.83h3.67v-2.83h2.83v2.83h.25v-6.33h-3.5Zm-18.92,3.08h-2.83v-2.83h2.83v2.83Zm6.22,0h-2.83v-2.83h2.83v2.83Zm6.25,0h-2.83v-2.83h2.83v2.83Zm6.38,0h-2.83v-2.83h2.83v2.83Z"/>'
    '</svg>';

class IconaClub extends StatelessWidget {
  const IconaClub({super.key, this.mida = midaIconaClub});
  final double mida;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svgLogo,
      width: mida,
      height: mida * 31.46 / 53.89,
      fit: BoxFit.contain,
    );
  }
}

class Carda extends StatelessWidget {
  const Carda({super.key, required this.child, this.margin, this.padding, this.decoracio});
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoracio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: decoracio ?? decoCard(),
      child: child,
    );
  }
}

class BotoGran extends StatelessWidget {
  const BotoGran({super.key, required this.titol, required this.icon, required this.onTap, this.midaIcona = 36});
  final String titol;
  final IconData icon;
  final VoidCallback? onTap;
  final double midaIcona;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 120,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: pri,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiGran)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: midaIcona),
          const SizedBox(height: 8),
          Text(titol, style: estilBotoGran),
        ]),
      ),
    );
  }
}

class BotoPujaFitxer extends StatelessWidget {
  const BotoPujaFitxer({super.key, required this.fitxer, this.etiqueta, required this.onTria});
  final Map<String, dynamic>? fitxer;
  final String? etiqueta;
  final VoidCallback onTria;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(fitxer == null ? Icons.upload_file : Icons.check_circle, color: fitxer == null ? null : verd),
      label: Text(fitxer == null ? (etiqueta ?? '') : '${fitxer?['name'] ?? ''}'),
      onPressed: onTria,
    );
  }
}

class MissatgeEstat extends StatelessWidget {
  const MissatgeEstat({super.key, required this.text, required this.esError});
  final String text;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: esError ? estilError : estilOk),
    );
  }
}

Widget botoPleAmple({required VoidCallback onPressed, required String text}) {
  return SizedBox(
    width: double.infinity,
    height: 44,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: pri,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiBoto)),
      ),
      child: Text(text, style: estilBotoText),
    ),
  );
}

Future<bool?> confirmaEliminacio(BuildContext context, String missatge) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(missatge),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
      ],
    ),
  );
}
