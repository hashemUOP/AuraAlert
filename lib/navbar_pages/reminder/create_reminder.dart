import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:aura_alert/navbar_pages/reminder/reminder_model.dart';
import 'package:aura_alert/navbar_pages/reminder/storage_service.dart';

class CreateReminder extends StatefulWidget {
  const CreateReminder({super.key});

  @override
  State<CreateReminder> createState() => _CreateReminderState();
}

class _CreateReminderState extends State<CreateReminder> {
  // Updated method to save reminder to SharedPreferences only
  Future<void> saveReminder() async {
    try {
      // Generate unique primary key
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      int randomNum = Random().nextInt(9999);
      String pk = '$randomNum-$timestamp';

      // Create ReminderModel
      ReminderModel reminder = ReminderModel(
        reminderId: pk,
        reminderDate: DateFormat('MMM dd, yyyy').format(selectedDate),
        reminderTime:
        '${selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
        commonName: '$repeatEveryPick2 $repeatEveryPick',
        remindAbout: selectedRemindAbout,
      );

      // Save to SharedPreferences
      await StorageService.addReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder has been added successfully!'),
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
      "right-text": "Select"
    },
    {
      "left-text": "Repeat Every",
      "icon": Icons.autorenew,
      "right-text": "3 Day"
    },
    {"left-text": "Time", "icon": Iconsax.clock, "right-text": "08:00-AM"},
    {
      "left-text": "Starting Date",
      "icon": Icons.calendar_month_outlined,
      "right-text": "12/10/24"
    },
  ];

  String selectedRemindAbout = "Select";
  String repeatEveryPick = "Days";
  int repeatEveryPick2 = 3;
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
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: const Icon(Iconsax.arrow_circle_left,
                        color: Colors.black87),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Set Reminder",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Container for each option
            for (int i = 0; i < 4; i++)
              Padding(
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
                        child: Row(
                          children: [
                            Text(
                              i == 0
                                  ? selectedRemindAbout
                                  : i == 1
                                  ? "$repeatEveryPick2 $repeatEveryPick"
                                  : i == 2
                                  ? selectedTime.format(context)
                                  : i == 3
                                  ? DateFormat('dd/MM/yy')
                                  .format(selectedDate)
                                  .toString()
                                  : data[i]["right-text"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            const SizedBox(width: 7),
                            const Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 7)
                          ],
                        ),
                        onTap: () {
                          // Modal for "Remind me about"
                          if (i == 0) {
                            showModalBottomSheet(
                              useSafeArea: true,
                              isScrollControlled: true,
                              backgroundColor: Colors.grey.shade200,
                              context: context,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      left: 20,
                                      right: 20,
                                      top: 20),
                                  child: Wrap(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Enter details",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 15),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: TextField(
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                hintText: "Type here...",
                                                border: InputBorder.none,
                                                contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 15),
                                                prefixIcon: Icon(Icons.edit,
                                                    color: Colors.grey),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedRemindAbout = value;
                                                });
                                              },
                                              onSubmitted: (value) {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          // Modal for "Repeat Every"
                          else if (i == 1) {
                            showModalBottomSheet(
                              backgroundColor: Colors.grey.shade200,
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: screenHeight * 0.3,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Repeat Every",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          // Number picker
                                          Container(
                                            width: 80,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: ListWheelScrollView(
                                              itemExtent: 50,
                                              physics:
                                              const FixedExtentScrollPhysics(),
                                              onSelectedItemChanged: (index) {
                                                setState(() {
                                                  repeatEveryPick2 = index + 1;
                                                });
                                              },
                                              children: List.generate(
                                                30,
                                                    (index) => Center(
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // Period picker
                                          Container(
                                            width: 120,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: ListWheelScrollView(
                                              itemExtent: 50,
                                              physics:
                                              const FixedExtentScrollPhysics(),
                                              onSelectedItemChanged: (index) {
                                                setState(() {
                                                  repeatEveryPick = [
                                                    'Days',
                                                    'Weeks',
                                                    'Months'
                                                  ][index];
                                                });
                                              },
                                              children: ['Days', 'Weeks', 'Months']
                                                  .map((period) => Center(
                                                child: Text(
                                                  period,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Done'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          // Time picker
                          else if (i == 2) {
                            showModalBottomSheet(
                              backgroundColor: Colors.grey.shade200,
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: screenHeight * 0.4,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Select Time",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20),
                                      SpinnerTimePicker(
                                        initTime:
                                        selectedTime, // The selected time
                                        is24HourFormat:
                                        false, // AM/PM format
                                        spinnerHeight: screenHeight *
                                            0.2, // Height of the spinner
                                        spinnerWidth:
                                        100, // Width of the spinner
                                        elementsSpace:
                                        20, // Space between spinner elements
                                        digitHeight:
                                        50, // Height of the digits
                                        spinnerBgColor: Colors
                                            .white, // Background color of the spinner
                                        selectedTextStyle:
                                        const TextStyle(
                                          fontSize: 24,
                                          color: Colors
                                              .black, // You can use green here if needed
                                          fontWeight: FontWeight.bold,
                                        ), // Style for selected text
                                        nonSelectedTextStyle:
                                        const TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ), // Style for non-selected text
                                        onChangedSelectedTime:
                                            (TimeOfDay selected) {
                                          setState(() {
                                            selectedTime = selected;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Done'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          // Date picker
                          else if (i == 3) {
                            showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                            ).then((pickedDate) {
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Set Reminder button
            GestureDetector(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.purple,
                  ),
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Set Reminder",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              onTap: () async {
                // Validation
                if (selectedRemindAbout == "Select" ||
                    selectedRemindAbout.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                          'Please enter what you want to be reminded about.'),
                    ),
                  );
                  return;
                }

                // Save reminder
                await saveReminder();
              },
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}