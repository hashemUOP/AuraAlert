import 'package:aura_alert/login/create_account.dart';
import 'package:aura_alert/login/email.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aura_alert/login/bg_video_widget.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    double containerResponsiveHeight() {
      if (screenHeight < 600) {
        return screenHeight * 0.5;
      } else {
        return screenHeight * 0.32;
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        const BackgroundVideoWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: containerResponsiveHeight(),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 40.0),
                    child: CustomText(
                      'Welcome to Ward !',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fromLeft: 0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 40.0),
                    child: CustomText(
                      'Sign In to Continue.',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fromLeft: 0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInputContainer(
                      FontAwesomeIcons.google,
                      'Continue with Google',
                      onTap: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyNavBar()))),
                  const SizedBox(height: 20),
                  _buildInputContainer(
                    Icons.email,
                    'Continue with email',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Email())),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        "No account yet? ",
                        fontSize: 12,
                        color: Colors.black,
                        fromLeft: 0,

                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Signin())),
                        child: const CustomText(
                          "Sign up here",
                          fontSize: 12,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fromLeft: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          const ModalBarrier(
            dismissible: false,
            color: Colors.black38,
          ),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                width: screenWidth,
                height: 70,
                child: const Row(
                  children: [
                    SizedBox(width: 20),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(width: 21),
                    Expanded(
                      child: AutoSizeText(
                        "Your request is being processed...",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Widget _buildInputContainer(IconData icon, String placeholder, {VoidCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40.0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          border: Border.all(color: Colors.black87),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Icon(icon),
            const SizedBox(width: 10),
            CustomText(
              placeholder,
              fontSize: 12,
              color: Colors.black87,
              fromLeft: 0,
            ),
          ],
        ),
      ),
    ),
  );
}
