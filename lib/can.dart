import 'package:flutter/material.dart';
import 'provider.dart';

class Can extends StatelessWidget {
  final String I;
  final String a;
  final Widget child;
  final Widget? fallback;
  final bool not;

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
