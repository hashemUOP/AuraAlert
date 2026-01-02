/*
very very important:
WillPopScope this widget is deprecated try using if playstore doesn't accept app ,
use Navigator.pushReplacement in main.dart which prevents user from pop after
sending user to a new route(page),in other words doesn't keep old route in stack
as if the new route is the top of stack and only element in it
 */
import 'package:aura_alert/navbar_pages/ChatBotMain.dart';
import 'package:aura_alert/navbar_pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:aura_alert/navbar_pages/Learn.dart';
import 'package:aura_alert/navbar_pages/settings.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MyNavBar extends StatefulWidget {
  final int? globalSelectedIndex;
  const MyNavBar({super.key, this.globalSelectedIndex});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int _selectedIndex = 0;
  bool hasUsedGlobalIndex = false;
  bool? hasConnection;
  bool? isPatient;

  @override
  void initState() {
    super.initState();

    if (widget.globalSelectedIndex != null && !hasUsedGlobalIndex) {
      _selectedIndex = widget.globalSelectedIndex!;
      hasUsedGlobalIndex = true;
    }

    loadUserType();
  }

  Future<void> loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    bool? localStatus = prefs.getBool('isPatient');

    if (localStatus != null) {
      if (mounted) {
        setState(() {
          isPatient = localStatus;
        });
      }
    } else {
      bool? firebaseStatus = await getIsPatient();
      if (mounted) {
        setState(() {
          isPatient = firebaseStatus ?? false;
        });
      }
    }
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Exit App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Do you really want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const Home(),
      const ChatBotMain(),
      const EducationPage(),
      Settings(isPatient: isPatient),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: hasConnection == false
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage('assets/images/5865576.jpg')),
              Padding(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.1),
                child: const Text(
                  'No internet connection.\nPlease check your connection.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
            : pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
            child: GNav(
              backgroundColor: Colors.white,
              color: Colors.grey,
              activeColor: Colors.black54,
              tabBackgroundColor: const Color(0xffdf8fff),
              gap: 8,
              padding: const EdgeInsets.all(12),
              selectedIndex: _selectedIndex,
              onTabChange: _navigateBottomBar,
              tabs: const [
                GButton(
                  icon: Iconsax.house_24,
                  text: 'Home',
                ),
                GButton(
                  icon: Iconsax.messages,
                  text: 'ChatBot',
                ),
                GButton(
                  icon: Iconsax.book_1,
                  text: 'Learn',
                ),
                GButton(
                  icon: Iconsax.setting_2,
                  text: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}