import 'package:flutter/foundation.dart';

/// A function type that defines conditions for access control.
typedef ConditionsFunction = bool Function(dynamic subject);

/// Represents a block reason with both text and code.
class BlockReason {
  /// The text description of the block reason.
  final String? text;

  /// The numeric code of the block reason.
  final int? code;

  /// Creates a new [BlockReason] instance.
  const BlockReason({this.text, this.code});

  /// Creates a [BlockReason] from a [Rule].
  factory BlockReason.fromRule(Rule rule) {
    return BlockReason(text: rule.reason, code: rule.reasonCode);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlockReason &&
        other.text == text &&
        other.code == code;
  }

  @override
  int get hashCode => text.hashCode ^ code.hashCode;

  @override
  String toString() => 'BlockReason(text: $text, code: $code)';
}

/// A class representing the main access control logic.
class CaslDart extends ChangeNotifier {
  /// The list of access control rules.
  final List<Rule> rules;

  /// Map of block reasons for action+subject combinations.
  final Map<String, BlockReason?> blockReasons = {};

  /// Creates a new instance of [CaslDart] with an optional list of rules.
  ///
  /// [rules] is a list of maps where each map defines an access rule.
  CaslDart({List<Map<String, dynamic>> rules = const []}) : rules = rules.map((r) => Rule.fromMap(r)).toList();

  /// Returns the reason for blocking access to [action] on [subject].
  /// If the reason is already cached, returns it. Otherwise, computes it via [can] and caches the result.
  BlockReason? getBlockReason(String action, String subject) {
    final key = _blockKey(action, subject);
    if (blockReasons.containsKey(key)) {
      return blockReasons[key];
    }
    // Call can to compute and save the block reason
    can(action, subject);
    return blockReasons[key];
  }

  /// Internal helper to generate a unique key for action+subject.
  String _blockKey(String action, String subject) => '${action}_$subject';

  /// Checks if a given [action] is allowed on a given [subject].
  ///
  /// Returns `true` if an access rule allows the action, otherwise `false`.
  /// If access is denied, saves the block reason (if any) in [blockReasons].
  bool can(String action, String subject) {
    final List<String> allSubjectOperations = [];
    final List<String> manageActionSubjects = [];
    bool allowAll = false;
    BlockReason? blockReason;
    for (var rule in rules) {
      if (rule.subject.contains('all')) {
        allSubjectOperations.addAll(rule.actions);
      }
      if (rule.actions.contains('manage')) {
        manageActionSubjects.addAll(rule.subject);
      }
      if (rule.subject.contains('all') && rule.actions.contains('manage')) {
        allowAll = true;
      }
    }

    bool allowed = rules.any((rule) {
      if (allowAll) {
        return true;
      }
      bool subjectMatches = allSubjectOperations.contains(action) || rule.subject.contains(subject);
      bool actionMatches = manageActionSubjects.contains(subject) || rule.actions.contains(action);
      if (!subjectMatches) {
        return false;
      }
      bool isAllowed = subjectMatches && actionMatches;
      // If the rule is inverted and matches, then it denies access
      if (rule.inverted && isAllowed) {
        if ((rule.reason != null || rule.reasonCode != null) && blockReason == null) {
          blockReason = BlockReason.fromRule(rule);
        }
        return !isAllowed;
      }
      return isAllowed;
    });

    // Save the block reason if access is denied
    final key = _blockKey(action, subject);
    if (!allowed) {
      // If we didn't find a reason, look for the first reason among inverted rules
      if (blockReason == null) {
        final firstBlockRule = rules.firstWhere(
          (rule) {
            bool subjectMatches = allSubjectOperations.contains(action) || rule.subject.contains(subject);
            bool actionMatches = manageActionSubjects.contains(subject) || rule.actions.contains(action);
            bool isAllowed = subjectMatches && actionMatches;
            return rule.inverted && isAllowed && (rule.reason != null || rule.reasonCode != null);
          },
          orElse: () => Rule(actions: [], subject: [], inverted: false),
        );
        if (firstBlockRule.reason != null || firstBlockRule.reasonCode != null) {
          blockReason = BlockReason.fromRule(firstBlockRule);
        }
      }
      blockReasons[key] = blockReason;
    } else {
      // If access is allowed, clear the reason
      blockReasons.remove(key);
    }
    return allowed;
  }

  /// Updates the existing rules with a new set of [newRules].
  ///
  /// This method clears the current rules and replaces them with the provided [newRules],
  /// converting each map into a `Rule` object. After updating, it notifies listeners
  /// to rebuild the `Can` widget or any widget that calls `CaslProvider.of(context)`.
  ///
  /// **Note:** Do not call this method inside `initState` or during the screen build process,
  /// as it may cause unnecessary widget rebuilds or unexpected behavior.
  /// Instead, use `initRules` to initialize rules properly.
  void updateRules(List<Map<String, dynamic>> newRules) {
    rules.clear();
    rules.addAll(newRules.map((r) => Rule.fromMap(r)));
    notifyListeners();
  }

  /// Initializes the rules with a new set of [newRules].
  ///
  /// This method clears the current rules and replaces them with the provided [newRules],
  /// converting each map into a `Rule` object. Unlike `updateRules`, this method
  /// does not notify listeners, so it will not trigger a rebuild for the `Can` widget
  /// or any widget that calls `CaslProvider.of(context)`.
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

  /// The map of conditions to which the actions apply.
  final Map<String, dynamic>? conditions;

  /// The list of fields to which the actions apply.
  final List<String>? fields;

  /// Invert rule.
  final bool inverted;

  /// Reason to block access.
  final String? reason;

  /// Reason code to block access.
  final int? reasonCode;

  /// Creates a new [Rule] instance.
  const Rule({
    required this.actions,
    required this.subject,
    this.inverted = false,
    this.conditions,
    this.fields,
    this.reason,
    this.reasonCode,
  });

  /// Creates a [Rule] instance from a map.
  ///
  /// The map should contain `actions` and `subject` keys,
  /// each mapping to a list of strings.
  factory Rule.fromMap(Map<String, dynamic> map) {
    return Rule(
      actions: List<String>.from(map['actions'] ?? []),
      subject: List<String>.from(map['subject'] ?? []),
      inverted: map['inverted'] ?? false,
      conditions: map['conditions'] != null ? Map<String, dynamic>.from(map['conditions']) : null,
      fields: map['fields'] != null ? List<String>.from(map['fields']) : null,
      reason: map['reason'],
      reasonCode: map['reasonCode'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rule &&
        listEquals(other.actions, actions) &&
        listEquals(other.subject, subject) &&
        mapEquals(other.conditions, conditions) &&
        listEquals(other.fields, fields) &&
        other.inverted == inverted &&
        other.reason == reason &&
        other.reasonCode == reasonCode;
  }

  @override
  int get hashCode {
    return actions.hashCode ^
        subject.hashCode ^
        conditions.hashCode ^
        fields.hashCode ^
        inverted.hashCode ^
        reason.hashCode ^
        reasonCode.hashCode;
  }
}
