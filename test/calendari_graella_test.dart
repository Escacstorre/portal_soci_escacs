import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_soci_escacs/ginys.dart';
import 'package:portal_soci_escacs/estils.dart';
import 'package:portal_soci_escacs/traduccions.dart';

const int anyCurs = 2026;
const List<int> mesos = [9, 10, 11, 12, 1, 2, 3, 4, 5];
const Map<int, String> clauMes = {
  1: 'mesGener',
  2: 'mesFebrer',
  3: 'mesMarc',
  4: 'mesAbril',
  5: 'mesMaig',
  6: 'mesJuny',
  7: 'mesJuliol',
  8: 'mesAgost',
  9: 'mesSetembre',
  10: 'mesOctubre',
  11: 'mesNovembre',
  12: 'mesDesembre',
};

const Map<String, String> lx = {
  'mesGener': 'gener',
  'mesFebrer': 'febrer',
  'mesMarc': 'març',
  'mesAbril': 'abril',
  'mesMaig': 'maig',
  'mesJuny': 'juny',
  'mesJuliol': 'juliol',
  'mesAgost': 'agost',
  'mesSetembre': 'setembre',
  'mesOctubre': 'octubre',
  'mesNovembre': 'novembre',
  'mesDesembre': 'desembre',
  'diaDl': 'dl',
  'diaDt': 'dt',
  'diaDc': 'dc',
  'diaDj': 'dj',
  'diaDv': 'dv',
  'diaDs': 'ds',
  'diaDg': 'dg',
  'sessio': 'sessió',
  'festiu': 'festiu',
};

int idxInicial() {
  final avui = DateTime.now();
  for (var i = 0; i < mesos.length; i++) {
    final mm = mesos[i];
    final y = mm >= 8 ? anyCurs : anyCurs + 1;
    if (mm == avui.month && y == avui.year) return i;
  }
  return 0;
}

String capcalera(int idx) {
  final mm = mesos[idx];
  final y = mm >= 8 ? anyCurs : anyCurs + 1;
  return '${lx[clauMes[mm]]} $y';
}

String ymd(int idx, int dia) {
  final mm = mesos[idx];
  final y = mm >= 8 ? anyCurs : anyCurs + 1;
  final m = mm.toString().padLeft(2, '0');
  final d = dia.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Widget graella(List<String> sessions, Set<String> festius) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CalendariGraella(
            sessions: sessions,
            festius: festius,
            anyCurs: anyCurs,
          ),
        ),
      ),
    );

void main() {
  setUp(() {
    Traduccions.instance.setLx({'CA': lx});
  });

  group('CalendariGraella', () {
    testWidgets('mostra capçalera amb sessió i festiu', (tester) async {
      final i0 = idxInicial();
      await tester.pumpWidget(graella([ymd(i0, 5)], {ymd(i0, 4)}));

      expect(find.text(capcalera(i0)), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('✔'), findsOneWidget);
      expect(find.text('✖'), findsOneWidget);

      final text5 = tester.widget<Text>(find.text('5'));
      expect(text5.style?.color, verd);
      final text4 = tester.widget<Text>(find.text('4'));
      expect(text4.style?.color, vermell);
    });

    testWidgets('botons navegació canvien de mes', (tester) async {
      final i0 = idxInicial();
      await tester.pumpWidget(graella([ymd(i0, 5)], {ymd(i0, 4)}));

      expect(find.text(capcalera(i0)), findsOneWidget);

      if (i0 < mesos.length - 1) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
        expect(find.text(capcalera(i0 + 1)), findsOneWidget);
        expect(find.text(capcalera(i0)), findsNothing);

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(find.text(capcalera(i0)), findsOneWidget);
      }

      if (i0 > 0) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(find.text(capcalera(i0 - 1)), findsOneWidget);

        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
        expect(find.text(capcalera(i0)), findsOneWidget);
      }
    });

    testWidgets('sessio verd i festiu vermell amb llegenda', (tester) async {
      final i0 = idxInicial();
      await tester.pumpWidget(graella([ymd(i0, 5)], {ymd(i0, 4)}));

      expect(find.text('sessió'), findsOneWidget);
      expect(find.text('festiu'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
