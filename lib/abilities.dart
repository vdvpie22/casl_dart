typedef ConditionsFunction = bool Function(dynamic subject);

class CaslDart {
  final List<Rule> rules;

  CaslDart({List<Map<String, dynamic>> rules = const []})
      : rules = rules.map((r) => Rule.fromMap(r)).toList();

  bool can(String action, dynamic subject) {
    return rules.any((rule) {
      bool subjectMatches =
          rule.subject is List ? rule.subject.contains(subject) : rule.subject == subject;

      bool actionMatches = rule.actions.contains(action);

      return subjectMatches && actionMatches;
    });
  }

  void updateRules(List<Map<String, dynamic>> newRules) {
    rules.clear();
    rules.addAll(newRules.map((r) => Rule.fromMap(r)));
  }

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

class Rule {
  final List<String> actions;
  final List<String> subject;

  const Rule({
    required this.actions,
    required this.subject,
  });

  factory Rule.fromMap(Map<String, dynamic> map) {
    return Rule(
      actions: List<String>.from(map['actions'] ?? []),
      subject: List<String>.from(map['subject'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    return (other is Rule) && other.subject == subject && other.actions == actions;
  }

  @override
  int get hashCode => subject.hashCode ^ actions.hashCode;
}
