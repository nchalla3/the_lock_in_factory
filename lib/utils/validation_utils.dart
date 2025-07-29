class ValidationUtils {
  // Username validation constants
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  /// Validates username and returns error message if invalid, null if valid
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Please enter a username';
    }

    final trimmed = username.trim();

    if (trimmed.length < minUsernameLength) {
      return 'Username must be at least $minUsernameLength characters';
    }

    if (trimmed.length > maxUsernameLength) {
      return 'Username must be less than $maxUsernameLength characters';
    }

    if (!usernameRegex.hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null; // Valid username
  }

  /// Validates email and returns error message if invalid, null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!email.contains('@')) {
      return 'Please enter a valid email';
    }

    return null; // Valid email
  }

  /// Validates password and returns error message if invalid, null if valid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null; // Valid password
  }

  /// Checks if username meets basic requirements (for real-time checking)
  static bool isValidUsernameFormat(String username) {
    final trimmed = username.trim();
    return trimmed.length >= minUsernameLength &&
           trimmed.length <= maxUsernameLength &&
           usernameRegex.hasMatch(trimmed);
  }
}
