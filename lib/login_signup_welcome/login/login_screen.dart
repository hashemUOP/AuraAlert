import 'package:flutter/material.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  String _errorMessage = '';
  bool isLoading = false; // Controls loading state for both buttons

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to MyNavBar on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyNavBar()),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ✅ FIX: LayoutBuilder + SingleChildScrollView prevents overflow
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        // --- Header Row ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const CustomText(
                              'Log In',
                              fontSize: 16,
                              color: Colors.black54,
                              fromLeft: 0.0,
                            ),
                            const SizedBox(width: 48), // Balances the back button
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- Title ---
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            'Enter your account information',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fromLeft: 0.0,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Email Field ---
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          controller: _emailController,
                        ),
                        const SizedBox(height: 30),

                        // --- Password Field ---
                        TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          controller: _passwordController,
                        ),

                        // --- Error Message ---
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 30),

                        // --- "OR" Divider ---
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: CustomText(
                                'Or',
                                fontSize: 14,
                                color: Colors.grey[600],
                                fromLeft: 0.0,
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- Google Login Button ---
                        ElevatedButton(
                          onPressed: isLoading
                              ? null // Disable button while loading
                              : () async {
                            setState(() { isLoading = true; });
                            await _authService.handleGoogleSignIn(context);
                            if(mounted) setState(() { isLoading = false; });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 22,
                                width: 22,
                              ),
                              const SizedBox(width: 12),
                              const CustomText(
                                'Continue with Google',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fromLeft: 0.0,
                              ),
                            ],
                          ),
                        ),

                        // ✅ Pushes "Continue" button to bottom (works safely now)
                        const Spacer(),
                        const SizedBox(height: 20),

                        // --- Continue (Login) Button ---
                        ElevatedButton(
                          onPressed: isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8e44ad),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                              : const CustomText(
                            "Continue",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fromLeft: 0.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}