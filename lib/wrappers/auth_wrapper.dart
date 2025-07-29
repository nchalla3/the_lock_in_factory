import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth/login_page.dart';
import '../screens/auth/username_selection_page.dart';
import '../screens/home/home_page.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking auth state, show loading
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          
          // Check if this is a Google user without a profile
          final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
          
          // Only check for username setup if it's a Google user
          if (isGoogleUser) {
            return FutureBuilder(
              future: UserService().getUserProfile(user.uid),
              builder: (context, userProfileSnapshot) {
                if (userProfileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userProfileSnapshot.hasData && userProfileSnapshot.data != null) {
                  // User has complete profile, go to home
                  return const HomePage();
                } else {
                  // Google user doesn't have username set, show username selection
                  return UsernameSelectionPage(
                    displayName: user.displayName,
                    photoUrl: user.photoURL,
                  );
                }
              },
            );
          } else {
            // Email/password user - they should have a profile, but check to be safe
            return FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 500))
                  .then((_) => UserService().getUserProfile(user.uid)),
              builder: (context, userProfileSnapshot) {
                if (userProfileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Email/password users should always have a profile by now
                return const HomePage();
              },
            );
          }
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}
