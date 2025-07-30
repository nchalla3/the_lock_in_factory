import 'package:flutter_test/flutter_test.dart';
import 'package:the_lock_in_factory/models/lockin.dart';
import 'package:the_lock_in_factory/utils/lockin_scheduler.dart';

void main() {
  group('LockInScheduler Tests', () {
    late LockInScheduler scheduler;

    setUp(() {
      scheduler = LockInScheduler();
    });

    test('should generate daily instances including today', () {
      final now = DateTime.now();
      final lockIn = LockIn(
        id: 'test-id',
        userId: 'test-user',
        title: 'Daily Workout',
        description: 'Test description',
        frequency: 'daily',
        reminderTime: '09:00',
        createdAt: now,
      );

      final instances = scheduler.generateInstancesForTest(lockIn, 7);

      expect(instances.length, equals(8)); // Today + 7 days ahead
      expect(instances.first.scheduledFor.day, equals(now.day));
      expect(instances.first.scheduledFor.hour, equals(9));
      expect(instances.first.scheduledFor.minute, equals(0));
    });

    test('should generate weekly instances correctly', () {
      final now = DateTime.now();
      final lockIn = LockIn(
        id: 'test-id',
        userId: 'test-user',
        title: 'Weekly Review',
        description: 'Test description',
        frequency: 'weekly',
        reminderTime: '18:30',
        createdAt: now,
      );

      final instances = scheduler.generateInstancesForTest(lockIn, 21);

      expect(instances.length, equals(4)); // Today + 3 weeks ahead
      expect(instances.first.scheduledFor.hour, equals(18));
      expect(instances.first.scheduledFor.minute, equals(30));
    });
  });
}
