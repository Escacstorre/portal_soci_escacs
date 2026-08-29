import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http/src/client.dart' as http_client;
import 'package:portal_soci_escacs/pont.dart';

void main() {
  group('Pont', () {
    test('retorna data quan ok és true', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'ok': true, 'data': {'foo': 'bar'}}), 200);
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        final data = await Pont.instance.call('provaFn', ['a', 1]);
        expect(data, {'foo': 'bar'});
      }, () => client);
    });

    test('llença ExcepcioPortal quan ok és false', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'ok': false, 'data': 'Error custom'}), 200);
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        expect(
          () => Pont.instance.call('provaFn'),
          throwsA(isA<ExcepcioPortal>().having((e) => e.message, 'message', contains('Error custom'))),
        );
      }, () => client);
    });

    test('llença SESSIO_CADUCADA en timeout', () async {
      final client = MockClient((request) async {
        throw TimeoutException('timeout');
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        expect(
          () => Pont.instance.call('provaFn'),
          throwsA(isA<ExcepcioPortal>().having((e) => e.message, 'message', contains('SESSIO_CADUCADA'))),
        );
      }, () => client);
    });

    test('envia capçalera Content-Type text/plain', () async {
      String? capturedContentType;
      final client = MockClient((request) async {
        capturedContentType = request.headers['Content-Type'];
        return http.Response(jsonEncode({'ok': true, 'data': 'ok'}), 200);
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        await Pont.instance.call('provaFn');
        expect(capturedContentType, isNotNull);
        expect(capturedContentType, contains('text/plain'));
      }, () => client);
    });

    test('llença ExcepcioPortal quan HTTP no és 200', () async {
      final client = MockClient((request) async {
        return http.Response('not found', 404);
      });
      await http_client.runWithClient(() async {
        Pont.instance.init('http://example.com');
        expect(
          () => Pont.instance.call('provaFn'),
          throwsA(isA<ExcepcioPortal>()),
        );
      }, () => client);
    });
  });
}
