import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:aura_alert/login/login.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use singleton instance for v7
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  // Call this early (e.g. in main() or before any sign in attempts)
  Future<void> initializeGoogleSignIn() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        // optional parameters
        // clientId: 'your-client-id-if-needed',
        // serverClientId: 'your-server-client-id-if using server side auth',
      );
      _isInitialized = true;
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      // Ensure initialization done
      await initializeGoogleSignIn();

      // Sign out first just in case
      await _googleSignIn.signOut();

      // Begin user-initiated authentication
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        // scopeHint: optional list of scopes, e.g. ['email', 'profile']
      );

      if (googleUser == null) {
        // User cancelled
        return;
      }

      // Separate: First, get the *authentication* part (which gives idToken etc.)
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception("Missing ID Token from Google Sign-In");
      }

      // For *authorization* (to get something like accessToken), you use the authorization client
      // If you need accessToken:
      final GoogleSignInClientAuthorization? authorization =
      await googleUser.authorizationClient
          .authorizationForScopes(<String>['email']);

      // Build Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        // accessToken is optional; might be null if not requested or not returned
        accessToken: authorization?.accessToken,
      );

      // Sign in to Firebase
      await _auth.signInWithCredential(credential);

      // Navigate on success
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyNavBar()),
        );
      }

    } on GoogleSignInException catch (gError) {
      // Handle cancellations, etc.
      final codeName = gError.code.name; // or gError.code.toString()
      if (codeName == GoogleSignInExceptionCode.canceled.name ||
          codeName == GoogleSignInExceptionCode.canceled.toString()) {
        // User canceled; you can ignore or show a message
      } else {
        // Other Google Sign-In errors
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Google Sign-In error: $codeName"),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: $error"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> signOut() async {
    await initializeGoogleSignIn();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> deleteUser(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
        await initializeGoogleSignIn();
        await _googleSignIn.signOut();
        await _auth.signOut();

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error deleting account: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
