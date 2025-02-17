import 'package:flutter/material.dart';
import 'provider.dart';

/// A widget that conditionally renders content based on access control.
class Can extends StatelessWidget {
  /// The action being checked for permissions.
  final String I;

  /// The subject being checked for permissions.
  final String a;

  /// The widget to display if permission is granted.
  final Widget? child;

  /// The widget to display if permission is denied. Defaults to an empty widget.
  final Widget? fallback;

  /// If `true`, reverses the permission logic (renders [child] if permission is denied).
  final bool not;

  /// A builder function that receives the permission result and returns a widget dynamically.
  ///
  /// This is useful when the UI needs to respond to the permission result dynamically rather than
  /// just showing a predefined [child].
  final Widget Function(bool hasPermission)? abilityBuilder;

  /// Creates a [Can] widget that displays [child] if permission is granted.
  ///
  /// - [I] represents the action being checked.
  /// - [a] represents the subject being checked.
  /// - [child] is displayed if permission is granted.
  /// - [fallback] is displayed if permission is denied (defaults to an empty widget).
  /// - If [not] is `true`, the logic is reversed, displaying [child] when permission is denied.
  const Can({
    Key? key,
    required this.I,
    required this.a,
    required this.child,
    this.not = false,
    this.fallback,
  })  : abilityBuilder = null,
        super(key: key);

  /// Creates a [Can] widget using a builder function to dynamically generate the widget based on permissions.
  ///
  /// - [I] represents the action being checked.
  /// - [a] represents the subject being checked.
  /// - [abilityBuilder] is called with the permission result (`true` if allowed, `false` otherwise).
  /// - If [not] is `true`, the logic is reversed.
  const Can.builder({
    Key? key,
    required this.I,
    required this.a,
    required this.abilityBuilder,
    this.not = false,
  })  : child = null,fallback= null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final casl = CaslProvider.of(context);
    bool hasPermission = casl.can(I, a);

    if (child != null) {
      return not
          ? (!hasPermission ? child! : (fallback ?? SizedBox.shrink()))
          : (hasPermission ? child! : (fallback ?? SizedBox.shrink()));
    } else {
      return abilityBuilder!(hasPermission);
    }
  }
}
