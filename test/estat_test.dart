import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http/src/client.dart' as http_client;
import 'package:portal_soci_escacs/estat.dart';
import 'package:portal_soci_escacs/pont.dart';

void main() {
  group('Estat cache i ocupats', () {
    setUp(() {
      Estat.i.buidaCau();
      Estat.i.ocupats = 0;
      Estat.i.user = null;
      Estat.i.toastMissatge = null;
      Pont.instance.init('http://example.com');
    });

    test('emmagatzema lectures a la cau durant 90s', () async {
      int comptador = 0;
      final client = MockClient((request) async {
        comptador++;
        return http.Response(jsonEncode({'ok': true, 'data': {'valor': 42}}), 200);
      });
      await http_client.runWithClient(() async {
        final r1 = await Estat.i.call('obtenirConfigPublic');
        final r2 = await Estat.i.call('obtenirConfigPublic');
        expect(comptador, 1);
        expect(r1, equals(r2));
      }, () => client);
    });

    test('neteja la cau en escriure', () async {
      int comptadorLectura = 0;
      int comptadorEscriptura = 0;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        final fn = body['fn'] as String;
        if (fn == 'obtenirConfigPublic') {
          comptadorLectura++;
          return http.Response(jsonEncode({'ok': true, 'data': {'n': comptadorLectura}}), 200);
        } else {
          comptadorEscriptura++;
          return http.Response(jsonEncode({'ok': true, 'data': 'ok'}), 200);
        }
      });
      await http_client.runWithClient(() async {
        final r1 = await Estat.i.call('obtenirConfigPublic');
        expect(comptadorLectura, 1);
        // segona crida ha de venir de cau
        final r2 = await Estat.i.call('obtenirConfigPublic');
        expect(comptadorLectura, 1);
        expect(r1, equals(r2));

        // crida d'escriptura (no és lectura) ha de netejar la cau
        await Estat.i.call('guardarSoci', ['dades']);
        expect(comptadorEscriptura, 1);

        // després d'escriure, la lectura ha de tornar a cridar backend
        final r3 = await Estat.i.call('obtenirConfigPublic');
        expect(comptadorLectura, 2);
        expect(r3, isNot(equals(r1)));
      }, () => client);
    });

    test('comptador ocupats incrementa en escriptura', () async {
      final completer = Completer<http.Response>();
      final client = MockClient((request) async {
        return completer.future;
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        // escriptura: no és a la llista lectures
        final future = Estat.i.call('guardarSoci', ['x']);
        // durant l'espera ocupats ha de ser 1
        expect(Estat.i.ocupats, 1);
        completer.complete(http.Response(jsonEncode({'ok': true, 'data': 'ok'}), 200));
        await future;
        expect(Estat.i.ocupats, 0);

        // lectura no ha d'incrementar ocupats
        final client2 = MockClient((_) async => http.Response(jsonEncode({'ok': true, 'data': 'dada'}), 200));
        await http_client.runWithClient(() async {
          Estat.i.buidaCau();
          final fLectura = Estat.i.call('obtenirConfigPublic');
          // lectura no incrementa ocupats (es queda a 0)
          expect(Estat.i.ocupats, 0);
          await fLectura;
          expect(Estat.i.ocupats, 0);
        }, () => client2);
      }, () => client);
    });

    test('buidaCau buida la cau', () async {
      int comptador = 0;
      final client = MockClient((_) async {
        comptador++;
        return http.Response(jsonEncode({'ok': true, 'data': 'v$comptador'}), 200);
      });
      await http_client.runWithClient(() async {
        await Estat.i.call('obtenirConfigPublic');
        expect(comptador, 1);
        await Estat.i.call('obtenirConfigPublic');
        expect(comptador, 1);
        Estat.i.buidaCau();
        await Estat.i.call('obtenirConfigPublic');
        expect(comptador, 2);
      }, () => client);
    });

    test('esAdministrador i esGestor segons rolActiu', () {
      Estat.i.user = {'rolActiu': 'Admin', 'rols': ['Soci', 'Admin']};
      expect(Estat.i.esAdministrador(), isTrue);
      expect(Estat.i.esGestor(), isTrue);

      Estat.i.user = {'rolActiu': 'Junta', 'rols': ['Soci', 'Junta']};
      expect(Estat.i.esAdministrador(), isFalse);
      expect(Estat.i.esGestor(), isTrue);

      Estat.i.user = {'rolActiu': 'Soci', 'rols': ['Soci']};
      expect(Estat.i.esAdministrador(), isFalse);
      expect(Estat.i.esGestor(), isFalse);

      Estat.i.user = null;
      expect(Estat.i.esAdministrador(), isFalse);
      expect(Estat.i.esGestor(), isFalse);
    });

    test('esGestor retorna fals quan rols buits', () {
      Estat.i.user = {'rolActiu': 'Profe'};
      expect(Estat.i.esGestor(), isFalse);
      expect(Estat.i.esAdministrador(), isFalse);
    });
  });
}
