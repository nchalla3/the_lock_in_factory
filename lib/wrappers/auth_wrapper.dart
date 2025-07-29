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
          // User is logged in, check if they have username set
          return FutureBuilder(
            future: UserService().getUserProfile(snapshot.data!.uid),
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
                // User doesn't have username set, show username selection
                return UsernameSelectionPage(
                  displayName: snapshot.data!.displayName,
                  photoUrl: snapshot.data!.photoURL,
                );
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}
