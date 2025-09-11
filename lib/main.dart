import 'package:aura_alert/theme.dart';
import 'package:flutter/material.dart';
import 'login/Welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aura ALert',
      theme:  appTheme,
      home: WelcomeScreen()
    );
  }
}
