import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ExcepcioPortal implements Exception {
  final String message;
  ExcepcioPortal(this.message);
  @override
  String toString() => message;
}

class Pont {
  Pont._();
  static final Pont instance = Pont._();

  late String _url;

  void init(String url) => _url = url;

  Future<dynamic> call(String fn, [List<Object?> args = const []]) async {
    http.Response resp;
    try {
      resp = await http
          .post(
            Uri.parse(_url),
            headers: {'Content-Type': 'text/plain;charset=utf-8'},
            body: jsonEncode({'fn': fn, 'args': args}),
          )
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw ExcepcioPortal('#SESSIO_CADUCADA#');
    }
    if (resp.statusCode != 200) {
      throw ExcepcioPortal('HTTP ${resp.statusCode}');
    }
    Map<String, dynamic> m;
    try {
      m = (jsonDecode(resp.body) as Map).cast<String, dynamic>();
    } catch (_) {
      throw ExcepcioPortal('#SESSIO_CADUCADA#');
    }
    if (m['ok'] == true) return m['data'];
    throw ExcepcioPortal('${m['data'] ?? 'Error'}');
  }
}
