import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class PortalException implements Exception {
  final String message;
  PortalException(this.message);
  @override
  String toString() => message;
}

class Bridge {
  Bridge._();
  static final Bridge instance = Bridge._();

  html.IFrameElement? _frame;
  final Map<String, Completer<dynamic>> _pendents = {};
  int _seq = 0;

  void init(String url) {
    _frame = html.IFrameElement()
      ..src = url
      ..style.position = 'absolute'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.border = 'none'
      ..style.opacity = '0';
    html.document.body?.append(_frame!);
    html.window.onMessage.listen(_onMessage);
  }

  void _onMessage(html.MessageEvent ev) {
    final d = ev.data;
    if (d is! String) return;
    Map<String, dynamic> m;
    try {
      m = jsonDecode(d) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (m['tipo'] != 'ps-resp') return;
    final c = _pendents.remove(m['id']);
    if (c == null || c.isCompleted) return;
    if (m['ok'] == true) {
      c.complete(m['data']);
    } else {
      c.completeError(PortalException('${m['data'] ?? 'Error'}'));
    }
  }

  Future<dynamic> call(String fn, [List<Object?> args = const []]) {
    final id = 'c${_seq++}';
    final c = Completer<dynamic>();
    _pendents[id] = c;
    final msg = jsonEncode({'tipo': 'ps-call', 'id': id, 'fn': fn, 'args': args});
    _frame?.contentWindow?.postMessage(msg, '*');
    return c.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () {
        _pendents.remove(id);
        throw PortalException('#SESSIO_CADUCADA#');
      },
    );
  }
}
