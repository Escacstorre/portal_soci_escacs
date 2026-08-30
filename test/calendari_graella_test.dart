import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_soci_escacs/ginys.dart';
import 'package:portal_soci_escacs/estils.dart';
import 'package:portal_soci_escacs/traduccions.dart';

void main() {
  setUp(() {
    Traduccions.instance.setLx({
      'CA': {
        'mesSetembre': 'setembre',
        'mesOctubre': 'octubre',
        'mesNovembre': 'novembre',
        'diaDl': 'dl',
        'diaDt': 'dt',
        'diaDc': 'dc',
        'diaDj': 'dj',
        'diaDv': 'dv',
        'diaDs': 'ds',
        'diaDg': 'dg',
        'sessio': 'sessió',
        'festiu': 'festiu',
      },
    });
  });

  group('CalendariGraella', () {
    testWidgets('mostra capçalera setembre 2026 amb sessió i festiu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CalendariGraella(
                sessions: ['2026-09-05'],
                festius: {'2026-09-04'},
                anyCurs: 2026,
              ),
            ),
          ),
        ),
      );

      expect(find.text('setembre 2026'), findsOneWidget);
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
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CalendariGraella(
                sessions: ['2026-09-05'],
                festius: {'2026-09-04'},
                anyCurs: 2026,
              ),
            ),
          ),
        ),
      );

      expect(find.text('setembre 2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('octubre 2026'), findsOneWidget);
      expect(find.text('setembre 2026'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('novembre 2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('octubre 2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('setembre 2026'), findsOneWidget);
    });

    testWidgets('sessio verd i festiu vermell amb llegenda', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CalendariGraella(
                sessions: ['2026-09-05'],
                festius: {'2026-09-04'},
                anyCurs: 2026,
              ),
            ),
          ),
        ),
      );

      expect(find.text('sessió'), findsOneWidget);
      expect(find.text('festiu'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
