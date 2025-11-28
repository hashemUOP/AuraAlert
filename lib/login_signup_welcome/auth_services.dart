import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Only used on Mobile
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

  /// -----------------------------
  /// GOOGLE LOGIN (WEB + MOBILE)
  /// -----------------------------
  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      // ------------------------------------
      // 1️⃣ WEB LOGIN (NO google_sign_in HERE)
      // ------------------------------------
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});

        await _auth.signInWithPopup(googleProvider);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyNavBar()),
          );
        }
        return;
      }

      // ------------------------------------
      // 2️⃣ MOBILE LOGIN (ANDROID / IOS)
      // ------------------------------------
      await initializeGoogleSignIn();

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

      final authorization =
      await googleUser.authorizationClient.authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
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
  /// UNIVERSAL LOGOUT (mobile+web)
  /// -----------------------------
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final isGoogleUser =
    user.providerData.any((p) => p.providerId == 'google.com');

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
