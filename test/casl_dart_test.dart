import 'package:casl_dart/abilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockReason class', () {
    test('creates instance with both text and code', () {
      final blockReason = BlockReason(text: 'Access denied', code: 403);
      
      expect(blockReason.text, 'Access denied');
      expect(blockReason.code, 403);
    });

    test('creates instance with text only', () {
      final blockReason = BlockReason(text: 'Not authorized');
      
      expect(blockReason.text, 'Not authorized');
      expect(blockReason.code, isNull);
    });

    test('creates instance with code only', () {
      final blockReason = BlockReason(code: 401);
      
      expect(blockReason.text, isNull);
      expect(blockReason.code, 401);
    });

    test('creates instance from Rule using fromRule factory', () {
      final rule = Rule(
        actions: ['read'],
        subject: ['Post'],
        inverted: true,
        reason: 'Insufficient permissions',
        reasonCode: 403,
      );
      
      final blockReason = BlockReason.fromRule(rule);
      
      expect(blockReason.text, 'Insufficient permissions');
      expect(blockReason.code, 403);
    });

    test('implements equality and hashCode correctly', () {
      final blockReason1 = BlockReason(text: 'Access denied', code: 403);
      final blockReason2 = BlockReason(text: 'Access denied', code: 403);
      final blockReason3 = BlockReason(text: 'Access denied', code: 401);

      expect(blockReason1, blockReason2);
      expect(blockReason1, isNot(blockReason3));
    });

    test('provides meaningful toString representation', () {
      final blockReason = BlockReason(text: 'Access denied', code: 403);
      
      expect(blockReason.toString(), 'BlockReason(text: Access denied, code: 403)');
    });
  });

  group('Rule class', () {
    test('creates Rule from map with all fields', () {
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

    test('creates Rule from map with required fields only', () {
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

    test('implements equality and hashCode correctly', () {
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

  group('CaslDart basic functionality', () {
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

    test('allows access when action is permitted', () {
      expect(casl.can('read', 'Post'), isTrue);
      expect(casl.can('manage', 'all'), isFalse);
    });

    test('denies access when action is not permitted', () {
      expect(casl.can('write', 'Post'), isFalse);
      expect(casl.can('read', 'Comment'), isFalse);
    });

    test('respects inverted rules correctly', () {
      // Rule with inverted: true for delete on Post
      expect(casl.can('delete', 'Post'), isFalse);
    });

    test('updates rules and notifies listeners', () {
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

    test('initializes rules without notifying listeners', () {
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

    test('converts nested lists to rule maps', () {
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

  group('CaslDart block reason functionality', () {
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
          'reason': 'Insufficient permissions',
          'reasonCode': 403,
        },
        {
          'actions': ['write'],
          'subject': ['Post'],
          'inverted': true,
          'reason': 'Post is locked',
          'reasonCode': 423,
        },
      ]);
    });

    test('returns null when access is allowed', () {
      final reason = casl.getBlockReason('read', 'Post');
      
      expect(reason, isNull);
    });

    test('returns block reason when access is denied', () {
      final reason = casl.getBlockReason('delete', 'Post');
      
      expect(reason, isNotNull);
      expect(reason!.text, 'Insufficient permissions');
      expect(reason.code, 403);
    });

    test('caches block reason results for performance', () {
      // First call should compute the reason
      final reason1 = casl.getBlockReason('delete', 'Post');
      
      // Second call should return from cache
      final reason2 = casl.getBlockReason('delete', 'Post');
      
      expect(reason1, reason2);
      expect(reason1!.text, 'Insufficient permissions');
    });

    test('returns different reasons for different blocked actions', () {
      final deleteReason = casl.getBlockReason('delete', 'Post');
      final writeReason = casl.getBlockReason('write', 'Post');
      
      expect(deleteReason!.text, 'Insufficient permissions');
      expect(writeReason!.text, 'Post is locked');
      expect(deleteReason.code, 403);
      expect(writeReason.code, 423);
    });

    test('returns null for non-existent subject', () {
      final reason = casl.getBlockReason('read', 'NonExistent');
      
      expect(reason, isNull);
    });

    test('saves block reason when can() denies access', () {
      // Check that the reason is saved when can is called
      expect(casl.can('delete', 'Post'), isFalse);
      
      final reason = casl.getBlockReason('delete', 'Post');
      expect(reason, isNotNull);
      expect(reason!.text, 'Insufficient permissions');
    });

    test('clears block reason when access becomes allowed', () {
      // First call can for forbidden action
      expect(casl.can('delete', 'Post'), isFalse);
      
      // Check that the reason was saved
      expect(casl.getBlockReason('delete', 'Post'), isNotNull);
      
      // Update rules to allow access
      casl.updateRules([
        {
          'actions': ['delete'],
          'subject': ['Post'],
        },
      ]);
      
      // Now access is allowed
      expect(casl.can('delete', 'Post'), isTrue);
      
      // Reason should be cleared
      expect(casl.getBlockReason('delete', 'Post'), isNull);
    });

    test('works with manage action and block reason', () {
      casl = CaslDart(rules: [
        {
          'actions': ['manage'],
          'subject': ['Post'],
          'inverted': true,
          'reason': 'Admin access required',
          'reasonCode': 401,
        },
      ]);
      
      final reason = casl.getBlockReason('manage', 'Post');
      
      expect(reason, isNotNull);
      expect(reason!.text, 'Admin access required');
      expect(reason.code, 401);
    });

    test('works with all subject and block reason', () {
      casl = CaslDart(rules: [
        {
          'actions': ['read'],
          'subject': ['all'],
          'inverted': true,
          'reason': 'System maintenance',
          'reasonCode': 503,
        },
      ]);
      
      final reason = casl.getBlockReason('read', 'Post');
      
      expect(reason, isNotNull);
      expect(reason!.text, 'System maintenance');
      expect(reason.code, 503);
    });

    test('returns null when no reason is specified in rule', () {
      casl = CaslDart(rules: [
        {
          'actions': ['delete'],
          'subject': ['Post'],
          'inverted': true,
          // reason and reasonCode are not specified
        },
      ]);
      
      final reason = casl.getBlockReason('delete', 'Post');
      
      expect(reason, isNull);
    });
  });

  group('CaslDart manage action functionality', () {
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

    test('allows read action on managed subject', () {
      expect(casl.can('read', 'Post'), isTrue);
    });

    test('allows write action on managed subject', () {
      expect(casl.can('write', 'Post'), isTrue);
    });

    test('allows delete action on managed subject', () {
      expect(casl.can('delete', 'Post'), isTrue);
    });

    test('denies manage action on all subject', () {
      expect(casl.can('manage', 'all'), isFalse);
    });
  });

  group('CaslDart all subject functionality', () {
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

    test('allows read action on any subject', () {
      expect(casl.can('read', 'Post'), isTrue);
    });
    
    test('denies write action on any subject', () {
      expect(casl.can('write', 'Post'), isFalse);
    });
    
    test('allows read action on different subject', () {
      expect(casl.can('read', 'News'), isTrue);
    });
    
    test('denies manage action on all subject', () {
      expect(casl.can('manage', 'all'), isFalse);
    });
  });
}
