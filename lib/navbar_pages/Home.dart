import 'package:aura_alert/navbar_pages/home/HomeCareGiver.dart';
import 'package:aura_alert/navbar_pages/home/HomePatient.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const HomePageCaregiver();
  }
}
