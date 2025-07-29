import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web client ID for Google Sign-In
    clientId: kIsWeb ? '645381910519-vbq2ns3kl4unab19iftplllsusuidjt7.apps.googleusercontent.com' : null,
  );

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  /// Returns null if the user cancels the sign-in process
  /// Throws exception if new user needs to set username
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;
      
      if (kIsWeb) {
        // For web platforms, use the popup flow
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // For mobile platforms (Android/iOS)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          // User canceled the sign-in
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check if this is a new user who needs to set a username
      if (userCredential.user != null) {
        final existingProfile = await _userService.getUserProfile(userCredential.user!.uid);
        if (existingProfile == null) {
          // New user - AuthWrapper will handle username setup
          // Just return the user credential, no exception needed
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Handle any remaining errors
      if (kIsWeb && e.toString().contains('popup')) {
        throw Exception('Please allow popups for this site to sign in with Google');
      }
      throw Exception('An unexpected error occurred during Google Sign-In: $e');
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithUsername({
    required String username,
    required String password,
  }) async {
    // Get email from username
    final email = await _userService.getEmailByUsername(username);
    if (email == null) {
      throw Exception('Username not found');
    }
    
    // Sign in with email and password
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Check if username is available
    final isAvailable = await _userService.isUsernameAvailable(username);
    if (!isAvailable) {
      throw Exception('Username is already taken');
    }

    // Create Firebase Auth account
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile with username
    if (userCredential.user != null) {
      await _userService.createUserProfile(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
      );
    }

    return userCredential;
  }

  // Add method to check username availability
  Future<bool> isUsernameAvailable(String username) async {
    return await _userService.isUsernameAvailable(username);
  }

  // Complete Google Sign-In by creating user profile with username
  Future<void> completeGoogleSignInWithUsername(String username) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _userService.createUserProfile(
      uid: user.uid,
      username: username,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> signOut() async {
    // Sign out from Google and Firebase
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore errors if Google Sign-In wasn't used
    }
    await _auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  /// Helper method to handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return Exception('An account already exists with a different credential.');
      case 'invalid-credential':
        return Exception('The credential is invalid or has expired.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'user-not-found':
        return Exception('No user found with this credential.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'invalid-verification-code':
        return Exception('Invalid verification code.');
      case 'invalid-verification-id':
        return Exception('Invalid verification ID.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }

}