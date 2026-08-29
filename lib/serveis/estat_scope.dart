import 'package:flutter/material.dart';

import '../estat.dart';

class EstatScope extends InheritedNotifier<EstatNotifier> {
  const EstatScope({super.key, required EstatNotifier notifier, required super.child}) : super(notifier: notifier);

  static EstatNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EstatScope>();
    assert(scope != null, 'EstatScope no trobat. Embolcalla MaterialApp amb EstatScope.');
    return scope!.notifier!;
  }
}

class EstatNotifier extends ChangeNotifier {
  EstatNotifier(this.estat) {
    estat.onCanvi.listen((_) => notifyListeners());
  }
  final Estat estat;
}
