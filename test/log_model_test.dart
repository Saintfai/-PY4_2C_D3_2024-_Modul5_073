import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

void main() {
  group('LogModel Tests', () {
    test('toMap converts LogModel to Map correctly', () {
      final log = LogModel(
        id: ObjectId().oid,
        title: 'Project Update',
        description: 'Fixed bugs',
        date: '2023-10-25',
        authorId: 'user123',
        teamId: 'team456',
        category: 'Software',
        isSynced: true,
        isPublic: true,
      );

      final map = log.toMap();

      expect(map['_id'], isA<ObjectId>());
      expect(map['title'], 'Project Update');
      expect(map['description'], 'Fixed bugs');
      expect(map['date'], '2023-10-25');
      expect(map['authorId'], 'user123');
      expect(map['teamId'], 'team456');
      expect(map['category'], 'Software');
      expect(map['isSynced'], true);
      expect(map['isPublic'], true);
    });

    test('fromMap creates LogModel from Map correctly', () {
      final objectId = ObjectId();
      final map = {
        '_id': objectId,
        'title': 'New Feature',
        'description': 'Added auth',
        'date': '2023-11-01',
        'authorId': 'user789',
        'teamId': 'team012',
        'category': 'Backend',
        'isPublic': false,
      };

      final log = LogModel.fromMap(map);

      expect(log.id, objectId.oid);
      expect(log.title, 'New Feature');
      expect(log.description, 'Added auth');
      expect(log.date, '2023-11-01');
      expect(log.authorId, 'user789');
      expect(log.teamId, 'team012');
      expect(log.category, 'Backend');
      expect(log.isSynced, true); // default is true in fromMap
      expect(log.isPublic, false);
    });

    test('copyWith creates a new instance with updated values', () {
      final log = LogModel(
        title: 'Initial Title',
        description: 'Initial Description',
        date: '2023-01-01',
        authorId: 'author1',
        teamId: 'team1',
        category: 'Test',
      );

      final updatedLog = log.copyWith(
        title: 'Updated Title',
        isPublic: true,
      );

      expect(updatedLog.title, 'Updated Title');
      expect(updatedLog.isPublic, true);
      
      // Values not updated should remain the same
      expect(updatedLog.description, 'Initial Description');
      expect(updatedLog.date, '2023-01-01');
      expect(updatedLog.authorId, 'author1');
      expect(updatedLog.teamId, 'team1');
      expect(updatedLog.category, 'Test');
    });
  });
}
