// You will need to import firebase_auth and your auth service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Assuming your AuthService class is in auth_service.dart
import 'auth_service.dart'; // <-- You'll need this import

// Your existing screen imports
import 'welcome.dart'; 
import 'PetScreen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the stream of authentication state changes
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges, // Use your defined stream
      builder: (context, snapshot) {
        
        // --- State Check 1: Loading/Checking Status ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You can show a loading screen or your existing SplashScreen here 
          // while Firebase checks for a token.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // --- State Check 2: Session Found ---
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in (session token was found and is valid)
          // Send them to your main app content (TestPage/HomePage)
          return const HomeScreen(); 
        } 
        
        // --- State Check 3: No Session Found ---
        else {
          // User is logged out (no valid token)
          // Send them to the welcome screen
          return const WelcomeScreen(); 
        }
      },
    );
  }
}