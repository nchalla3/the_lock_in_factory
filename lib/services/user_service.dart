import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final doc = await _firestore.collection('usernames').doc(username.toLowerCase()).get();
      return !doc.exists;
    } catch (e) {
      throw Exception('Error checking username availability: $e');
    }
  }

  // Reserve username and create user profile
  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    try {
      // Check if username is still available
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user profile
      final userProfile = UserProfile(
        uid: uid,
        username: username,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        createdAt: now,
        updatedAt: now,
      );

      // Reserve username
      final usernameRef = _firestore.collection('usernames').doc(username.toLowerCase());
      batch.set(usernameRef, {
        'uid': uid,
        'username': username, // Keep original case
        'createdAt': now.toIso8601String(),
      });

      // Create user profile
      final userRef = _firestore.collection('users').doc(uid);
      batch.set(userRef, userProfile.toFirestore());

      await batch.commit();
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  // Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      final userRef = _firestore.collection('users').doc(userProfile.uid);
      await userRef.update(userProfile.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Clean up username reservation (in case of account deletion)
  Future<void> deleteUserProfile(String uid) async {
    try {
      final userProfile = await getUserProfile(uid);
      if (userProfile != null) {
        final batch = _firestore.batch();
        
        // Remove username reservation
        final usernameRef = _firestore.collection('usernames').doc(userProfile.username.toLowerCase());
        batch.delete(usernameRef);
        
        // Remove user profile
        final userRef = _firestore.collection('users').doc(uid);
        batch.delete(userRef);
        
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Error deleting user profile: $e');
    }
  }

  // Get username by UID (helper method)
  Future<String?> getUsernameByUid(String uid) async {
    try {
      final userProfile = await getUserProfile(uid);
      return userProfile?.username;
    } catch (e) {
      return null;
    }
  }

  /// Get user profile by username
  Future<UserProfile?> getUserProfileByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return UserProfile.fromFirestore(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user profile by username: $e');
    }
  }

  /// Get email by username for authentication
  Future<String?> getEmailByUsername(String username) async {
    try {
      final userProfile = await getUserProfileByUsername(username);
      return userProfile?.email;
    } catch (e) {
      print('Error getting email by username: $e');
      return null;
    }
  }
}
