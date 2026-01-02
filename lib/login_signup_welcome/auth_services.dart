import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/login_signup_welcome/google_questions/question_1.dart';
import '../navbar_pages/location/LocationManager.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> initializeGoogleSignIn() async {
    if (!_isInitialized && !kIsWeb) {
      try {
        await _googleSignIn.initialize();
      } catch (e) {
        debugPrint("GoogleSignIn initialize skipped: $e");
      }
      _isInitialized = true;
    }
  }

  /// --------------------------------- ///
        /// GOOGLE LOGIN (WEB + MOBILE)
  /// --------------------------------- ///
  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      UserCredential userCredential;

      // 1️⃣ PERFORM AUTHENTICATION
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        await initializeGoogleSignIn();

        // Force user to select account (prevents auto-login loop)
        try {
          await _googleSignIn.signOut();
        } catch (_) {}

        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

        if (googleUser == null) return; // User cancelled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          throw Exception("Google sign-in missing ID Token");
        }

        final authorization = await googleUser.authorizationClient.authorizationForScopes(['email']);
        final credential = GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: authorization?.accessToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // 2️⃣ POST-LOGIN LOGIC
      // If we reach here, user is logged in.
      // We must catch errors here carefully to avoid "zombie" login sessions.

      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (!context.mounted) return;

      if (isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Question1Screen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LocationManager(child: const MyNavBar())),
        );
      }

    } catch (e) {
      // 🚨 ERROR CAUGHT - ROLLBACK 🚨
      // If the user IS logged in but the app crashed/failed during navigation,
      // log them out immediately so they can try again.
      if (_auth.currentUser != null) {
        await signOut();
        if (kDebugMode) print("Rolled back (Signed out) due to error: $e");
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Login Failed: $e")),
        );
      }
    }
  }

  /// -----------------------------
        /// UNIVERSAL LOGOUT
  /// -----------------------------
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

    // Only sign out GoogleSignIn on mobile
    if (isGoogleUser && !kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }

    await _auth.signOut();
  }

  /// -----------------------------
            /// DELETE ACCOUNT
  /// -----------------------------
  Future<void> deleteUser(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
      await signOut();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
  }

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}