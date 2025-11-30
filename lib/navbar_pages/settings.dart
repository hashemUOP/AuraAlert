import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:aura_alert/global_widgets/animated_button.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';
import 'package:aura_alert/global_widgets/color_changing_container.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}
class _SettingsState extends State<Settings> {
  final AuthService _authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.white, automaticallyImplyLeading: false),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Settings", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 30),
              ColorChangingContainer(
                iconPadding: 20,
                icon: const Icon(Icons.bug_report_outlined, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Report a bug',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyNavBar()),
                  );
                },
              ),
              ColorChangingContainer(
                icon: const Icon(Iconsax.star, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Rate app',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              ColorChangingContainer(
                icon: const Icon(FontAwesomeIcons.solidCircleUser, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'User\'s Info',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No user is currently signed in.')),
                    );
                    return;
                  }
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: screenHeight * 0.4,
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user!.photoURL != null)
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(user!.photoURL!),
                                  ),
                                ),
                              _userInfoRow('Username', user!.displayName ?? 'N/A'),
                              user!.phoneNumber != null
                                  ? _userInfoRow('Phone Number', user!.phoneNumber!)
                                  : _userInfoRow('Email', user!.email ?? 'N/A'),
                              _userInfoRow('UID', user!.uid),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              ColorChangingContainer(
                icon: const Icon(Iconsax.global, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Change language',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {},
              ),
              ColorChangingContainer(
                onTap: () async {
                  try {
                    await _authService.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                },
                icon: const Icon(Iconsax.logout, color: Colors.black54),
                inWidget: const CustomText(
                  'Log out',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedButton(
                onTap: () async {
                  await _authService.deleteUser(context);
                },
                buttonColor: Colors.white,
                text: 'Delete my account',
                textColor: Colors.purple,
                textSize: 15,
                containerBorderColor: Colors.purple,
                containerRadius: 10,
                containerHeight: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoRow(String title, String value) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}



