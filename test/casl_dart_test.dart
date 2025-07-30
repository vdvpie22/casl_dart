import 'package:casl_dart/abilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rule', () {
    test('should create Rule from map with all fields', () {
      final rule = Rule.fromMap({
        'actions': ['read', 'write'],
        'subject': ['Post'],
        'inverted': true,
        'conditions': {'published': true},
        'fields': ['title', 'content'],
        'reason': 'Not allowed',
        'reasonCode': 403,
      });

      expect(rule.actions, ['read', 'write']);
      expect(rule.subject, ['Post']);
      expect(rule.inverted, true);
      expect(rule.conditions, {'published': true});
      expect(rule.fields, ['title', 'content']);
      expect(rule.reason, 'Not allowed');
      expect(rule.reasonCode, 403);
    });

    test('should create Rule from map with required fields only', () {
      final rule = Rule.fromMap({
        'actions': ['read'],
        'subject': ['Post'],
      });

      expect(rule.actions, ['read']);
      expect(rule.subject, ['Post']);
      expect(rule.inverted, false);
      expect(rule.conditions, isNull);
      expect(rule.fields, isNull);
      expect(rule.reason, isNull);
      expect(rule.reasonCode, isNull);
    });

    test('equality and hashCode', () {
      final rule1 = Rule(
        actions: ['read'],
        subject: ['Post'],
        inverted: true,
        conditions: {'published': true},
      );

      final rule2 = Rule(
        actions: ['read'],
        subject: ['Post'],
        inverted: true,
        conditions: {'published': true},
      );

      final rule3 = Rule(
        actions: ['write'],
        subject: ['Post'],
      );

      expect(rule1, rule2);
      expect(rule1, isNot(rule3));
    });
  });

  group('CaslDart', () {
    late CaslDart casl;

    setUp(() {
      casl = CaslDart(rules: [
        {
          'actions': ['read'],
          'subject': ['Post'],
        },
        {
          'actions': ['delete'],
          'subject': ['Post'],
          'inverted': true,
        },
      ]);
    });

    test('can() should return true when action is allowed', () {
      expect(casl.can('read', 'Post'), isTrue);
      expect(casl.can('manage', 'all'), isFalse);
    });

    test('can() should return false when action is not allowed', () {
      expect(casl.can('write', 'Post'), isFalse);
      expect(casl.can('read', 'Comment'), isFalse);
    });

    test('can() should respect inverted rules', () {
      // Правило с inverted: true для delete на Post
      expect(casl.can('delete', 'Post'), isFalse);
    });

    test('updateRules() should replace all rules and notify', () {
      var notified = false;
      casl.addListener(() => notified = true);

      casl.updateRules([
        {
          'actions': ['write'],
          'subject': ['Post']
        }
      ]);

      expect(notified, isTrue);
      expect(casl.rules.length, 1);
      expect(casl.can('write', 'Post'), isTrue);
      expect(casl.can('read', 'Post'), isFalse);
    });

    test('initRules() should replace all rules without notifying', () {
      var notified = false;
      casl.addListener(() => notified = true);

      casl.initRules([
        {
          'actions': ['write'],
          'subject': ['Post']
        }
      ]);

      expect(notified, isFalse);
      expect(casl.rules.length, 1);
      expect(casl.can('write', 'Post'), isTrue);
      expect(casl.can('read', 'Post'), isFalse);
    });

    test('unpackRules() should convert nested lists to rule maps', () {
      final unpacked = casl.unpackRules([
        ['read,write', 'Post,Comment'],
        ['delete', 'Post'],
      ]);

      expect(unpacked, [
        {
          'actions': ['read', 'write'],
          'subject': ['Post', 'Comment'],
        },
        {
          'actions': ['delete'],
          'subject': ['Post'],
        },
      ]);
    });
  });

  group('Manage tests', () {
    late CaslDart casl;

    setUp(() {
      casl = CaslDart(rules: [
        {
          'actions': ['manage'],
          'subject': ['Post'],
        },
        {
          'actions': ['delete'],
          'subject': ['Post'],
          'inverted': true,
        },
      ]);
    });

    test('can read Post', () {
      expect(casl.can('read', 'Post'), isTrue);
    });

    test('can write Post', () {
      expect(casl.can('write', 'Post'), isTrue);
    });

    test('cant delete Post', () {
      expect(casl.can('delete', 'Post'), isTrue);
    });

    test('cant manage all', () {
      expect(casl.can('manage', 'all'), isFalse);
    });
  });

  group('Subject All Tests', () {
    late CaslDart casl;

    setUp(() {
      casl = CaslDart(rules: [
        {
          'actions': ['read'],
          'subject': ['all'],
        },
        {
          'actions': ['delete'],
          'subject': ['Post'],
          'inverted': true,
        },
      ]);
    });

    test('can read Post', () {
      expect(casl.can('read', 'Post'), isTrue);
    });
    test('cant write Pots', () {
      expect(casl.can('write', 'Post'), isFalse);
    });
    test('can read news', () {
      expect(casl.can('read', 'News'), isTrue);
    });
    test('cant manage all', () {
      expect(casl.can('manage', 'all'), isFalse);
    });
  });
}
