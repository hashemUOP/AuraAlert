import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateReminder extends StatefulWidget {
  const CreateReminder({super.key});

  @override
  State<CreateReminder> createState() => _CreateReminderState();
}

class _CreateReminderState extends State<CreateReminder> {

  Future<void> saveReminder() async {

    final User? user = FirebaseAuth.instance.currentUser;

    // check if user is null, show error then stop.
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to set a reminder.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 3. Proceed with saving to Firestore
    try {
      // Construct the 'time' field by combining selectedDate and selectedTime
      DateTime finalTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Create the data map for Firestore based on your required schema
      Map<String, dynamic> reminderData = {
        "about": selectedRemindAbout,           // (string)
        "patient": user.email,                  // (string) - Dynamic patient email
        "starting_date": Timestamp.fromDate(selectedDate), // (timestamp)
        "time": Timestamp.fromDate(finalTime),  // (timestamp)
      };

      // CRUD: CREATE operation in collection 'Reminders'
      await FirebaseFirestore.instance.collection('Reminders').add(reminderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder has been saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> data = [
    {
      "left-text": "Remind me about",
      "icon": Iconsax.sun_1,
    },
    {
      "left-text": "Time",
      "icon": Iconsax.clock,
    },
    {
      "left-text": "Starting Date",
      "icon": Icons.calendar_month_outlined,
    },
  ];

  String selectedRemindAbout = "Select";
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade200,
        toolbarHeight: screenHeight * 0.1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.grey.shade400,
            height: 1.0,
          ),
        ),
        title: SafeArea(
          child: Row(
            children: [
              GestureDetector(
                child: const Icon(Iconsax.arrow_circle_left, color: Colors.black87),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              const Text(
                "Set Reminder",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            for (int i = 0; i < data.length; i++)              Padding(
                padding: EdgeInsets.only(
                    left: 20.0, right: 20, top: i == 0 ? 30 : 10, bottom: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200),
                            child: Icon(data[i]["icon"]),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            data[i]["left-text"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (i == 0) _showAboutModal(context);
                          else if (i == 1) _showTimePicker(context, screenHeight); // Changed from 2 to 1
                          else if (i == 2) _showDatePicker(context);              // Changed from 3 to 2
                        },
                        child: Row(
                          children: [
                            Text(
                              i == 0 ? selectedRemindAbout :
                              i == 1 ? selectedTime.format(context) :          // Changed from 2 to 1
                              DateFormat('dd/MM/yy').format(selectedDate),     // Index 2 is Date
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            const SizedBox(width: 7),
                            const Icon(Iconsax.arrow_right_3, color: Colors.grey),
                            const SizedBox(width: 7)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                if (selectedRemindAbout == "Select" || selectedRemindAbout.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please enter details.'),
                    ),
                  );
                  return;
                }
                await saveReminder();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.purple,
                  ),
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Set Reminder",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  void _showAboutModal(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade200,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Wrap(
          children: [
            const Text("Enter details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: "Type here...", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15), prefixIcon: Icon(Icons.edit, color: Colors.grey)),
                onChanged: (val) => setState(() => selectedRemindAbout = val),
                onSubmitted: (_) => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildPickerWheel(dynamic items, Function(int) onSelected) {
    int count = items is int ? items : (items as List).length;
    return Container(
      width: items is int ? 80 : 120,
      height: 150,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: ListWheelScrollView(
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        children: List.generate(count, (idx) => Center(child: Text(items is int ? '${idx + 1}' : items[idx], style: const TextStyle(fontSize: 20)))),
      ),
    );
  }

  void _showTimePicker(BuildContext context, double screenHeight) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade200,
      context: context,
      builder: (context) => SizedBox(
        height: screenHeight * 0.4,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SpinnerTimePicker(
              initTime: selectedTime,
              is24HourFormat: false,
              spinnerHeight: screenHeight * 0.2,
              spinnerWidth: 100,
              elementsSpace: 20,
              digitHeight: 50,
              spinnerBgColor: Colors.white,
              selectedTextStyle: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
              onChangedSelectedTime: (TimeOfDay sel) => setState(() => selectedTime = sel),
              nonSelectedTextStyle: TextStyle(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) setState(() => selectedDate = date);
    });
  }
}