import 'package:flutter/material.dart';

import 'abilities.dart';

class CaslProvider extends InheritedWidget {
  final CaslDart casl;

  const CaslProvider({
    Key? key,
    required this.casl,
    required Widget child,
  }) : super(key: key, child: child);

  static CaslDart of(BuildContext context) {
    final CaslProvider? provider = context.dependOnInheritedWidgetOfExactType<CaslProvider>();
    assert(provider != null, 'No CaslProvider found in context');
    return provider!.casl;
  }

  @override
  bool updateShouldNotify(CaslProvider oldWidget) => oldWidget.casl.rules != casl.rules;
}
