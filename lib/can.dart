import 'package:flutter/material.dart';
import 'provider.dart';

/// A widget that conditionally renders content based on access control.
class Can extends StatelessWidget {
  /// The action being checked for permissions.
  final String I;

  /// The subject being checked for permissions.
  final String a;

  /// The widget to display if permission is granted.
  final Widget child;

  /// The widget to display if permission is denied. Defaults to an empty widget.
  final Widget? fallback;

  /// If `true`, reverses the permission logic (renders [child] if permission is denied).
  final bool not;

  /// Creates a [Can] widget.
  ///
  /// [I] is the subject, [a] is the action, and [child] is the widget displayed if the permission check passes.
  /// If [not] is `true`, the logic is reversed, displaying [child] when the check fails.
  /// An optional [fallback] widget is displayed if the permission check does not pass.
  const Can({
    Key? key,
    required this.I,
    required this.a,
    required this.child,
    this.not = false,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final casl = CaslProvider.of(context);
    bool hasPermission = casl.can(I, a);

    return not
        ? (!hasPermission ? child : (fallback ?? SizedBox.shrink()))
        : (hasPermission ? child : (fallback ?? SizedBox.shrink()));
  }
}
