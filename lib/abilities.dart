import 'package:flutter/material.dart';

/// A function type that defines conditions for access control.
typedef ConditionsFunction = bool Function(dynamic subject);

/// A class representing the main access control logic.
class CaslDart extends ChangeNotifier {
  /// The list of access control rules.
  final List<Rule> rules;

  /// Creates a new instance of [CaslDart] with an optional list of rules.
  ///
  /// [rules] is a list of maps where each map defines an access rule.
  CaslDart({List<Map<String, dynamic>> rules = const []})
      : rules = rules.map((r) => Rule.fromMap(r)).toList();

  /// Checks if a given [action] is allowed on a given [subject].
  ///
  /// Returns `true` if an access rule allows the action, otherwise `false`.
  bool can(String action, dynamic subject) {
    return rules.any((rule) {
      bool subjectMatches = rule.subject.contains(subject);

      bool actionMatches = rule.actions.contains(action);

      return subjectMatches && actionMatches;
    });
  }

  /// Updates the existing rules with a new set of [newRules].
  void updateRules(List<Map<String, dynamic>> newRules) {
    rules.clear();
    rules.addAll(newRules.map((r) => Rule.fromMap(r)));
    notifyListeners();
  }

  void initRules(List<Map<String, dynamic>> newRules) {
    rules.clear();
    rules.addAll(newRules.map((r) => Rule.fromMap(r)));
  }

  /// Converts a nested list of rules into a structured list of maps.
  ///
  /// Each rule is expected to be in the format `[actions, subject]`,
  /// where `actions` and `subject` are comma-separated strings.
  List<Map<String, dynamic>> unpackRules(List<List<dynamic>> rules) {
    return rules.map((rule) {
      return {
        'actions': rule[0].split(','),
        'subject': rule[1].split(','),
      };
    }).toList();
  }

  @override
  bool operator ==(Object other) {
    return (other is CaslDart) && other.rules == rules;
  }

  @override
  int get hashCode => rules.hashCode;
}

/// Represents a single access control rule.
class Rule {
  /// The list of allowed actions.
  final List<String> actions;

  /// The list of subjects to which the actions apply.
  final List<String> subject;

  /// Creates a new [Rule] instance.
  const Rule({
    required this.actions,
    required this.subject,
  });

  /// Creates a [Rule] instance from a map.
  ///
  /// The map should contain `actions` and `subject` keys,
  /// each mapping to a list of strings.
  factory Rule.fromMap(Map<String, dynamic> map) {
    return Rule(
      actions: List<String>.from(map['actions'] ?? []),
      subject: List<String>.from(map['subject'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    return (other is Rule) &&
        other.subject == subject &&
        other.actions == actions;
  }

  @override
  int get hashCode => subject.hashCode ^ actions.hashCode;
}
