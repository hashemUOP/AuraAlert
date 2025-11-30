// reminders.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aura_alert/navbar_pages/reminder/create_reminder.dart';
import 'package:aura_alert/navbar_pages/reminder/no_reminders_screen.dart';
import 'package:aura_alert/navbar_pages/reminder/reminder_model.dart';
import 'package:aura_alert/navbar_pages/reminder/storage_service.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _MyRemindersState();
}

class _MyRemindersState extends State<Reminders> {
  Color containerColor1 = Colors.green.withOpacity(0.1);
  Color containerColor2 = Colors.transparent;

  List<ReminderModel> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // Load reminders from SharedPreferences
  Future<void> _loadReminders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedReminders = await StorageService.loadReminders();
      setState(() {
        reminders = loadedReminders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
      if (kDebugMode) {
        print('Error loading reminders: $e');
      }
    }
  }

  // Add a new reminder
  Future<void> addReminder(ReminderModel reminder) async {
    await StorageService.addReminder(reminder);
    await _loadReminders(); // Refresh the list
  }

  // Remove reminder
  Future<void> onRemoveReminder(int index) async {
    if (index >= 0 && index < reminders.length) {
      final reminderId = reminders[index].reminderId;
      await StorageService.removeReminder(reminderId);
      await _loadReminders(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder removed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Clear all reminders
  Future<void> _clearAllReminders() async {
    await StorageService.clearAllReminders();
    await _loadReminders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All reminders cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.grey.shade200,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.grey.shade400, height: 1.0),
        ),
        flexibleSpace: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  "${reminders.length} Reminders",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "My Reminders",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                ),
                if (reminders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'clear_all') {
                          _showClearAllDialog();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(Icons.clear_all, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Clear All'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : buildRemindersSection(screenHeight, screenWidth),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Reminders'),
          content: const Text(
            'Are you sure you want to remove all reminders? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllReminders();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
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
                child: Text(
                  "Upcoming reminders",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateReminder()),
                    );

                    // If a reminder was created, refresh the list
                    if (result == true) {
                      _loadReminders();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:  Icon(Icons.add, color: Colors.purple.shade200),
                  ),
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
                margin: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.013,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.purple.shade300,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              AutoSizeText(
                                '${reminder.reminderTime} , ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Flexible(
                                child: AutoSizeText(
                                  reminder.reminderDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onPressed: () => showModalBottomSheet(
                            backgroundColor: Colors.grey.shade200,
                            context: context,
                            builder: (_) => buildRemoveModal(
                              screenHeight,
                              () => onRemoveReminder(index),
                              "Remove Reminder",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Reminder for ${reminder.remindAbout} ${reminder.commonName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget buildRemoveModal(
    double screenHeight,
    VoidCallback onConfirm,
    String label,
  ) {
    return SizedBox(
      height: screenHeight * 0.13,
      child: Column(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onConfirm();
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
                      child: const Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.red,
                        size: 20,
                      ),
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
