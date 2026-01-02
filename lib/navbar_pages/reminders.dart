import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_alert/navbar_pages/reminder/create_reminder.dart';
import 'package:aura_alert/navbar_pages/reminder/no_reminders_screen.dart';
import 'package:aura_alert/navbar_pages/reminder/reminder_model.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _MyRemindersState();
}

class _MyRemindersState extends State<Reminders> {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  // CRUD: DELETE - Removes a specific document from Firestore
  Future<void> onRemoveReminder(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Reminders').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint("Error deleting reminder: $e");
    }
  }

  // CRUD: DELETE ALL - Removes all reminders for the current patient
  Future<void> _clearAllReminders() async {
    try {
      var snapshots = await FirebaseFirestore.instance
          .collection('Reminders')
          .where('patient', isEqualTo: userEmail)
          .get();

      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Error clearing reminders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Reminders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, "Clear All", _clearAllReminders),
          )
        ],
      ),
      body: StreamBuilder<List<ReminderModel>>(
        // CRUD: READ - Listening to real-time changes for this specific patient
        stream: FirebaseFirestore.instance
            .collection('Reminders')
            .where('patient', isEqualTo: userEmail)
            .snapshots()
            .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromFirestore(doc))
            .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoRemindersScreen();
          }

          final reminders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FontAwesomeIcons.bell, color: Colors.purple),
                    ),
                    title: AutoSizeText(
                      reminder.about,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "Time: ${DateFormat('hh:mm a').format(reminder.time)}",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(FontAwesomeIcons.trashCan, color: Colors.redAccent, size: 18),
                      onPressed: () => _showDeleteConfirmation(
                          context,
                          "Delete Reminder",
                              () => onRemoveReminder(reminder.reminderId)
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple.shade300,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateReminder()),
        ),
        label: const Text("New Reminder",style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String label, VoidCallback onConfirm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 150,
          child: Column(
            children: [
              const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  onConfirm();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.trash, color: Colors.red, size: 18),
                      const SizedBox(width: 10),
                      Text(label, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}