import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/lockin.dart';

class LockInService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  // ========== LockIn Operations ==========

  /// Create a new LockIn
  Future<String> createLockIn(LockIn lockIn) async {
    try {
      final docRef = _firestore.collection('lockIns').doc();
      
      // Create new LockIn with the generated ID
      final newLockIn = LockIn(
        id: docRef.id,
        userId: lockIn.userId,
        title: lockIn.title,
        description: lockIn.description,
        frequency: lockIn.frequency,
        reminderTime: lockIn.reminderTime,
        createdAt: lockIn.createdAt,
      );

      await docRef.set(newLockIn.toMap());
      _logger.i('Created LockIn with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating LockIn', error: e);
      throw Exception('Failed to create LockIn: $e');
    }
  }

  /// Read all LockIns for a specific user
  Stream<List<LockIn>> getUserLockIns(String userId) {
    try {
      return _firestore
          .collection('lockIns')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final lockIns = snapshot.docs
                .map((doc) => LockIn.fromMap(doc.id, doc.data()))
                .toList();
            // Sort in memory to avoid index requirement
            lockIns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return lockIns;
          });
    } catch (e) {
      _logger.e('Error getting user LockIns', error: e);
      return Stream.error('Failed to get LockIns: $e');
    }
  }

  /// Get a specific LockIn by ID
  Future<LockIn?> getLockIn(String lockInId) async {
    try {
      final doc = await _firestore.collection('lockIns').doc(lockInId).get();
      if (doc.exists && doc.data() != null) {
        return LockIn.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting LockIn', error: e);
      throw Exception('Failed to get LockIn: $e');
    }
  }

  /// Update an existing LockIn
  Future<void> updateLockIn(LockIn lockIn) async {
    try {
      await _firestore
          .collection('lockIns')
          .doc(lockIn.id)
          .update(lockIn.toMap());
      _logger.i('Updated LockIn: ${lockIn.id}');
    } catch (e) {
      _logger.e('Error updating LockIn', error: e);
      throw Exception('Failed to update LockIn: $e');
    }
  }

  /// Delete a LockIn and all its instances
  Future<void> deleteLockIn(String lockInId) async {
    try {
      final batch = _firestore.batch();

      // Delete all instances first
      final instancesSnapshot = await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .get();

      for (final doc in instancesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the LockIn document
      batch.delete(_firestore.collection('lockIns').doc(lockInId));

      await batch.commit();
      _logger.i('Deleted LockIn and all instances: $lockInId');
    } catch (e) {
      _logger.e('Error deleting LockIn', error: e);
      throw Exception('Failed to delete LockIn: $e');
    }
  }

  // ========== LockInInstance Operations ==========

  /// Create a new LockInInstance
  Future<String> createLockInInstance(String lockInId, LockInInstance instance) async {
    try {
      final docRef = _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc();

      // Create new instance with the generated ID
      final newInstance = LockInInstance(
        id: docRef.id,
        scheduledFor: instance.scheduledFor,
        completedAt: instance.completedAt,
        mediaUrl: instance.mediaUrl,
        status: instance.status,
      );

      await docRef.set(newInstance.toMap());
      _logger.i('Created LockInInstance with ID: ${docRef.id} for LockIn: $lockInId');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating LockInInstance', error: e);
      throw Exception('Failed to create LockInInstance: $e');
    }
  }

  /// Read all instances for a specific LockIn
  Stream<List<LockInInstance>> getLockInInstances(String lockInId) {
    try {
      return _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .snapshots()
          .map((snapshot) {
            final instances = snapshot.docs
                .map((doc) => LockInInstance.fromMap(doc.id, doc.data()))
                .toList();
            // Sort in memory to avoid index requirement
            instances.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
            return instances;
          });
    } catch (e) {
      _logger.e('Error getting LockInInstances', error: e);
      return Stream.error('Failed to get LockInInstances: $e');
    }
  }

  /// Get a specific LockInInstance
  Future<LockInInstance?> getLockInInstance(String lockInId, String instanceId) async {
    try {
      final doc = await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc(instanceId)
          .get();

      if (doc.exists && doc.data() != null) {
        return LockInInstance.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting LockInInstance', error: e);
      throw Exception('Failed to get LockInInstance: $e');
    }
  }

  /// Update an existing LockInInstance
  Future<void> updateLockInInstance(String lockInId, LockInInstance instance) async {
    try {
      await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc(instance.id)
          .update(instance.toMap());
      _logger.i('Updated LockInInstance: ${instance.id} for LockIn: $lockInId');
    } catch (e) {
      _logger.e('Error updating LockInInstance', error: e);
      throw Exception('Failed to update LockInInstance: $e');
    }
  }

  /// Mark an instance as completed
  Future<void> completeLockInInstance(String lockInId, String instanceId, {String? mediaUrl}) async {
    try {
      final updateData = {
        'status': 'completed',
        'completedAt': DateTime.now(),
      };
      
      if (mediaUrl != null) {
        updateData['mediaUrl'] = mediaUrl;
      }

      await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc(instanceId)
          .update(updateData);
      
      _logger.i('Completed LockInInstance: $instanceId for LockIn: $lockInId');
    } catch (e) {
      _logger.e('Error completing LockInInstance', error: e);
      throw Exception('Failed to complete LockInInstance: $e');
    }
  }

  /// Mark an instance as missed
  Future<void> markLockInInstanceAsMissed(String lockInId, String instanceId) async {
    try {
      await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc(instanceId)
          .update({'status': 'missed'});
      
      _logger.i('Marked LockInInstance as missed: $instanceId for LockIn: $lockInId');
    } catch (e) {
      _logger.e('Error marking LockInInstance as missed', error: e);
      throw Exception('Failed to mark LockInInstance as missed: $e');
    }
  }

  /// Delete a specific LockInInstance
  Future<void> deleteLockInInstance(String lockInId, String instanceId) async {
    try {
      await _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .doc(instanceId)
          .delete();
      
      _logger.i('Deleted LockInInstance: $instanceId for LockIn: $lockInId');
    } catch (e) {
      _logger.e('Error deleting LockInInstance', error: e);
      throw Exception('Failed to delete LockInInstance: $e');
    }
  }

  // ========== Query Operations ==========

  /// Get instances by status for a specific LockIn
  Stream<List<LockInInstance>> getLockInInstancesByStatus(String lockInId, String status) {
    try {
      return _firestore
          .collection('lockIns')
          .doc(lockInId)
          .collection('instances')
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) {
            final instances = snapshot.docs
                .map((doc) => LockInInstance.fromMap(doc.id, doc.data()))
                .toList();
            // Sort in memory to avoid index requirement
            instances.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
            return instances;
          });
    } catch (e) {
      _logger.e('Error getting LockInInstances by status', error: e);
      return Stream.error('Failed to get LockInInstances by status: $e');
    }
  }

  /// Get instances scheduled for today across all user's LockIns
  Stream<List<Map<String, dynamic>>> getTodaysInstances(String userId) {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      return _firestore
          .collection('lockIns')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .asyncMap((lockInSnapshot) async {
        final List<Map<String, dynamic>> result = [];
        
        for (final lockInDoc in lockInSnapshot.docs) {
          final lockIn = LockIn.fromMap(lockInDoc.id, lockInDoc.data());
          
          // Get instances for this LockIn that are scheduled for today
          final instancesSnapshot = await _firestore
              .collection('lockIns')
              .doc(lockIn.id)
              .collection('instances')
              .where('scheduledFor', isGreaterThanOrEqualTo: startOfDay)
              .where('scheduledFor', isLessThanOrEqualTo: endOfDay)
              .get();
          
          for (final instanceDoc in instancesSnapshot.docs) {
            final instance = LockInInstance.fromMap(instanceDoc.id, instanceDoc.data());
            result.add({
              'lockIn': lockIn,
              'instance': instance,
            });
          }
        }
        
        // Sort by scheduled time
        result.sort((a, b) {
          final aTime = (a['instance'] as LockInInstance).scheduledFor;
          final bTime = (b['instance'] as LockInInstance).scheduledFor;
          return aTime.compareTo(bTime);
        });
        
        return result;
      });
    } catch (e) {
      _logger.e('Error getting today\'s instances', error: e);
      return Stream.error('Failed to get today\'s instances: $e');
    }
  }
}
