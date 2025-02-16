import 'package:flutter/material.dart';

import 'abilities.dart';

/// A provider for managing access control using [CaslDart].
///
/// This widget allows descendant widgets to access the [CaslDart] instance
/// for permission checks.
class CaslProvider extends InheritedNotifier<CaslDart> {
  /// Creates a [CaslProvider] widget.
  ///
  /// The [casl] parameter is required and provides access control rules.
  /// The [child] parameter is the widget subtree that can access [CaslDart].
  const CaslProvider({
    Key? key,
    required CaslDart casl,
    required Widget child,
  }) : super(key: key, child: child, notifier: casl);

  /// Retrieves the nearest [CaslProvider] instance in the widget tree.
  ///
  /// Throws an assertion error if no [CaslProvider] is found in the context.
  static CaslDart of(BuildContext context) {
    final CaslProvider? provider =
        context.dependOnInheritedWidgetOfExactType<CaslProvider>();
    assert(provider != null, 'No CaslProvider found in context');
    return provider!.notifier!;
  }

  @override
  bool updateShouldNotify(InheritedNotifier<CaslDart> oldWidget) {
    return oldWidget.notifier!.rules != notifier!.rules;
  }
}
