import 'package:flutter/material.dart';

// تعريف الألوان الرئيسية
class AppColors {
  static const Color primaryDarkBlue = Color(0xFF0B1D51); // أزرق غامق (يمكن تعديل الدرجة)
  static const Color accentDarkPurple = Color(0xFF725CAD); // بنفسجي غامق (يمكن تعديل الدرجة)
  static const Color backgroundColor = Color(0xFFF0F2F5); // لون خلفية فاتح
  static const Color textColor = Color(0xFF333333); // لون نص أساسي غامق
  static const Color lightTextColor = Color(0xFFFFFFFF); // لون نص فاتح (للاستخدام على خلفيات داكنة)
  static const Color errorColor = Color(0xFFD32F2F); // لون للأخطاء
  static const Color successColor = Color(0xFF388E3C); // لون للنجاح
  static const Color warningColor = Color(0xFFFBC02D); // لون للتحذير
}

// تعريف الثيم الأساسي للتطبيق
final ThemeData appTheme = ThemeData(
  // الألوان الأساسية
  primaryColor: AppColors.primaryDarkBlue,
  hintColor: AppColors.accentDarkPurple,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  brightness: Brightness.light, // الوضع الفاتح

  // شريط التطبيق (AppBar)
  appBarTheme: const AppBarTheme(
    color: AppColors.primaryDarkBlue,
    foregroundColor: AppColors.lightTextColor,
    elevation: 4, // ظل شريط التطبيق
    titleTextStyle: TextStyle(
      color: AppColors.lightTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // أزرار
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.accentDarkPurple,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentDarkPurple, // لون خلفية الزر
      foregroundColor: AppColors.lightTextColor, // لون نص الزر
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accentDarkPurple, // لون نص الزر
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accentDarkPurple,
      side: const BorderSide(color: AppColors.accentDarkPurple, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // حقول الإدخال (TextFormField)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
    labelStyle: const TextStyle(color: AppColors.primaryDarkBlue),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none, // بدون حدود مرئية افتراضياً
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.accentDarkPurple, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // الخطوط وأنماط النصوص
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: AppColors.textColor),
    displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w400, color: AppColors.textColor),
    displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: AppColors.textColor),
    headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textColor),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textColor),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textColor),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textColor),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textColor),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textColor),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textColor),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColor),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textColor),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.lightTextColor), // للأزرار
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColor),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textColor),
  ),

  // أيقونات
  iconTheme: const IconThemeData(
    color: AppColors.primaryDarkBlue,
    size: 24,
  ),

  // ألوان المخطط (ColorScheme) - مهم لتحديد الألوان بشكل أعمق
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryDarkBlue,
    onPrimary: AppColors.lightTextColor,
    secondary: AppColors.accentDarkPurple,
    onSecondary: AppColors.lightTextColor,
    surface: Colors.white,
    onSurface: AppColors.textColor,
    background: AppColors.backgroundColor,
    onBackground: AppColors.textColor,
    error: AppColors.errorColor,
    onError: AppColors.lightTextColor,
  ).copyWith(secondary: AppColors.accentDarkPurple), // التأكد من أن accentColor يطابق secondary
);