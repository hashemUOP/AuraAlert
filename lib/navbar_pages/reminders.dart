import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aura_alert/global_widgets/create_reminder.dart';
import 'package:aura_alert/global_widgets/no_reminders_screen.dart';
import 'package:intl/intl.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<Reminders> {
  Color containerColor1 = Colors.green.withOpacity(0.1);
  Color containerColor2 = Colors.transparent;
  bool isPlantTapped = true;

  // Dummy data (since Firebase removed)
  final List<Map<String, dynamic>> plants = [
    {
      "plant_id": "001",
      "common_name": "Carrot",
      "scientific_name": "Daucus carota",
      "images": ["https://upload.wikimedia.org/wikipedia/commons/4/40/Carrot.jpg"],
    },
    {
      "plant_id": "002",
      "common_name": "Tomato",
      "scientific_name": "Solanum lycopersicum",
      "images": ["https://upload.wikimedia.org/wikipedia/commons/8/88/Bright_red_tomato_and_cross_section02.jpg"],
    },
  ];

  final List<Map<String, dynamic>> reminders = [
    {
      "reminder_id": "r001",
      "reminder_date": "25/10/2025",
      "reminder_time": "08:00 AM",
      "common_name": "Carrot",
      "remind_about": "Watering",
    },
    {
      "reminder_id": "r002",
      "reminder_date": "26/10/2025",
      "reminder_time": "06:00 PM",
      "common_name": "Tomato",
      "remind_about": "Fertilizing",
    },
  ];

  void onRemovePlant(int index) {
    setState(() {
      plants.removeAt(index);
    });
  }

  void onRemoveReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 125,
        backgroundColor: Colors.grey[300],
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.grey.shade400, height: 1.0),
        ),
        flexibleSpace: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "No Plants",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "My Garden",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
            ),
            const Spacer(),
            Stack(
              children: [
                SizedBox(
                  width: screenWidth,
                  height: screenHeight * 0.1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset("assets/images/img2-2.png", fit: BoxFit.cover),
                      ),
                      Expanded(
                        child: Image.asset("assets/images/img_2-3.png", fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  child: Container(
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPlantTapped = true;
                                containerColor1 = Colors.green.withOpacity(0.2);
                                containerColor2 = Colors.transparent;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: containerColor1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text("All Plants"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPlantTapped = false;
                                containerColor2 = Colors.green.withOpacity(0.2);
                                containerColor1 = Colors.transparent;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: containerColor2,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text("Reminders"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: isPlantTapped ? buildPlantsSection(screenHeight, screenWidth) : buildRemindersSection(screenHeight, screenWidth),
      ),
    );
  }

  Widget buildPlantsSection(double screenHeight, double screenWidth) {
    if (plants.isEmpty) return const NoRemindersScreen();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Plants", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text("Add Plant", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            children: List.generate(plants.length, (index) {
              final plant = plants[index];
              final images = plant['images'] as List<String>;
              final imageUrl = images.isNotEmpty ? images[0] : "";

              return Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.013, horizontal: screenWidth * 0.04),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: screenHeight * 0.1,
                      width: screenHeight * 0.1,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/no image found.png",
                        height: screenHeight * 0.1,
                        width: screenHeight * 0.1,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(plant['common_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          AutoSizeText(plant['scientific_name']),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () => showModalBottomSheet(
                        backgroundColor: Colors.grey.shade200,
                        context: context,
                        builder: (_) => buildRemoveModal(screenHeight, () => onRemovePlant(index), "Remove from Garden"),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildRemindersSection(double screenHeight, double screenWidth) {
    if (reminders.isEmpty) return const NoRemindersScreen();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Upcoming reminders", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReminder())),
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.013, horizontal: screenWidth * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.shade200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AutoSizeText(
                              '${reminder['reminder_time']} , ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                            ),
                            AutoSizeText(
                              reminder['reminder_date'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () => showModalBottomSheet(
                            backgroundColor: Colors.grey.shade200,
                            context: context,
                            builder: (_) => buildRemoveModal(screenHeight, () => onRemoveReminder(index), "Remove Reminder"),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Reminder for ${reminder["remind_about"]} ${reminder["common_name"]}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildRemoveModal(double screenHeight, VoidCallback onConfirm, String label) {
    return SizedBox(
      height: screenHeight * 0.13,
      child: Column(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: screenHeight * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade50,
                      ),
                      child: const Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(label, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
