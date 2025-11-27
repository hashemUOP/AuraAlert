import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:aura_alert/login_signup_welcome/login/login_screen.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // v7 uses singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  /// -----------------------------
  /// REQUIRED FOR GOOGLE SIGN-IN v7
  /// -----------------------------
  Future<void> initializeGoogleSignIn() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  /// -----------------------------
  /// GOOGLE LOGIN (v7 API)
  /// -----------------------------
  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      await initializeGoogleSignIn();

      // Prevent conflict login
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.authenticate();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception("Google sign-in missing ID Token");
      }

      // ACCESS TOKEN (v7 way)
      final GoogleSignInClientAuthorization? authorization =
      await googleUser.authorizationClient
          .authorizationForScopes(['email']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );

      await _auth.signInWithCredential(credential);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyNavBar()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Login Failed: $e")),
        );
      }
    }
  }

  /// -----------------------------
  /// UNIVERSAL LOGOUT (Email + Google)
  /// -----------------------------
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if logged in with Google
    final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

    if (isGoogleUser && !kIsWeb) {
      // Only sign out Google on mobile (Android/iOS)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint("Google sign out ignored: $e");
      }
    }

    // Always sign out Firebase
    await _auth.signOut();
  }


  /// -----------------------------
  /// DELETE ACCOUNT (Email + Google)
  /// -----------------------------
  Future<void> deleteUser(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();

      await signOut(); // reuse logout logic

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
