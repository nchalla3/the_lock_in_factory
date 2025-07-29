import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import '../utils/validation_utils.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final doc = await _firestore.collection('usernames').doc(username.toLowerCase()).get();
      return !doc.exists;
    } catch (e) {
      throw Exception('Error checking username availability: $e');
    }
  }

  // Validate username format and check availability
  Future<String?> validateAndCheckUsername(String username) async {
    // First check format using centralized validation
    final formatError = ValidationUtils.validateUsername(username);
    if (formatError != null) {
      return formatError;
    }

    // Then check availability
    try {
      final isAvailable = await isUsernameAvailable(username.trim());
      return isAvailable ? null : 'Username is already taken';
    } catch (e) {
      _logger.e('Error checking username availability', error: e);
      return 'Error checking username availability';
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
      // Validate username format first
      final validationError = ValidationUtils.validateUsername(username);
      if (validationError != null) {
        throw Exception(validationError);
      }

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
      // Check the usernames collection for the corresponding user ID
      final usernameDoc = await _firestore.collection('usernames').doc(username.toLowerCase()).get();
      if (!usernameDoc.exists) {
        return null; // Username not found
      }
      
      // Retrieve the user profile using the user ID
      final userId = usernameDoc.data()?['uid'];
      if (userId == null) {
        return null; // UID not found in the username document
      }
      
      final userProfile = await getUserProfile(userId);
      return userProfile;
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
      _logger.w('Error getting email by username', error: e);
      return null;
    }
  }
}
