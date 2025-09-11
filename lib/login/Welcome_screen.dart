import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aura_alert/login/bg_video_widget.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/theme.dart'; // استيراد ملف الثيم الخاص بك

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _LoginState();
}

class _LoginState extends State<WelcomeScreen> {
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    // الوصول إلى الألوان من الثيم
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).hintColor; // hintColor هو نفسه secondary في colorScheme
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!; // لون النص من الثيم
    final Color lightTextColor = AppColors.lightTextColor; // لون نص فاتح ثابت من AppColors

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double containerResponsiveHeight() {
      if (screenHeight < 600) {
        return screenHeight * 0.5;
      } else {
        return screenHeight * 0.3;
      }
    }

    return Stack(
      children: [
        const BackgroundVideoWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: containerResponsiveHeight()*1.3,
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue, // استخدام لون الخلفية من الثيم
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 80.0),
                    child: Text(
                      'Welcome to Aura Alert !',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white, // استخدام primaryColor من الثيم
                        fontWeight: FontWeight.w600,
                        // fontFamily: 'Tajawal', // إذا كان الخط Tajawal معرفاً في الثيم، سيعمل تلقائياً
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Sign In to Continue.',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: primaryColor.withOpacity(0.8), // لون أغمق قليلاً
                        fontWeight: FontWeight.w400,
                        // fontFamily: 'Tajawal',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInputContainer(
                    context, // تمرير السياق للوصول إلى الثيم
                    FontAwesomeIcons.rightToBracket,
                    '  Login',
                    // onTap: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const MyPhone()),
                    // ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputContainer(
                    context, // تمرير السياق للوصول إلى الثيم
                    FontAwesomeIcons.userPlus,
                    '   Sign-Up',
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyNavBar()),
                        ),
                  ),
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
          ), //if user press
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).scaffoldBackgroundColor, // لون خلفية الثيم
                ),
                width: screenWidth,
                height: 70,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor), // لون التحميل بنفس لون accent
                    ),
                    const SizedBox(
                      width: 21,
                    ),
                    Expanded(
                        child: AutoSizeText(
                          "Your request is being processed...",
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: textColor, // لون النص من الثيم
                            fontWeight: FontWeight.w300,
                            // fontFamily: "Tajawal",
                            decoration: TextDecoration.none,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// تم تعديل الدالة لتأخذ BuildContext
Widget _buildInputContainer(BuildContext context, IconData icon, String placeholder,
    {VoidCallback? onTap}) {
  // الوصول إلى الألوان من الثيم
  final Color primaryColor = Theme.of(context).primaryColor;
  final Color accentColor = Theme.of(context).hintColor;
  final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40.0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: accentColor, // استخدام accentColor كلون خلفية للزر
          border: Border.all(color: primaryColor, width: 2), // حد أزرق داكن
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Icon(
              icon,
              color: AppColors.lightTextColor, // لون الأيقونة أبيض فاتح
              size: 20, // حجم الأيقونة
            ),
            const SizedBox(width: 10),
            Text(
              placeholder,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.lightTextColor, // لون النص أبيض فاتح
                fontSize: 16, // حجم الخط للزر
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}