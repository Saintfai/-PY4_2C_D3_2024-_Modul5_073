import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_073/services/access_policy.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';

void main() {
  group('AccessPolicy Tests', () {
    test('canEdit returns true only if userId matches logAuthorId', () {
      expect(AccessPolicy.canEdit(userId: 'user1', logAuthorId: 'user1'), isTrue);
      expect(AccessPolicy.canEdit(userId: 'user2', logAuthorId: 'user1'), isFalse);
    });

    test('canDelete returns true only if userId matches logAuthorId', () {
      expect(AccessPolicy.canDelete(userId: 'userA', logAuthorId: 'userA'), isTrue);
      expect(AccessPolicy.canDelete(userId: 'userB', logAuthorId: 'userA'), isFalse);
    });

    test('canView returns true if user is author, regardless of isPublic', () {
      final privateLog = LogModel(
        title: 'Test',
        description: 'Test',
        date: '2023-01-01',
        authorId: 'author1',
        teamId: 'team1',
        category: 'Test',
        isPublic: false,
      );
      
      expect(AccessPolicy.canView(log: privateLog, currentUserId: 'author1'), isTrue);
    });

    test('canView returns true if log is public, even for non-authors', () {
      final publicLog = LogModel(
        title: 'Test',
        description: 'Test',
        date: '2023-01-01',
        authorId: 'author1',
        teamId: 'team1',
        category: 'Test',
        isPublic: true,
      );
      
      expect(AccessPolicy.canView(log: publicLog, currentUserId: 'other_user'), isTrue);
    });

    test('canView returns false if log is private and user is not author', () {
      final privateLog = LogModel(
        title: 'Test',
        description: 'Test',
        date: '2023-01-01',
        authorId: 'author1',
        teamId: 'team1',
        category: 'Test',
        isPublic: false,
      );
      
      expect(AccessPolicy.canView(log: privateLog, currentUserId: 'other_user'), isFalse);
    });
  });
}
