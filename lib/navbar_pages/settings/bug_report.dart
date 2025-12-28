import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  User? user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _textController;

  // State variables for image and loading status
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text:
      "Hello, I am writing to report an issue I encountered within your app. It is not working properly.\n\nWhen I click it nothing is happening. I am attaching a link with a highlighted spot.",
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- 1. Function to Pick Image ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // --- 2. Function to Upload Data to Firebase ---
  Future<void> _submitReport() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the issue.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl;

      // A. Upload Image to Storage (if selected)
      if (_selectedImage != null) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef =
        FirebaseStorage.instance.ref().child('bug_reports/$fileName');

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // B. Save Report to Firestore
      await FirebaseFirestore.instance.collection('ReportBug').add({
        'uid': user?.uid ?? 'guest',
        'email': user?.email ?? 'anonymous',
        'description': _textController.text.trim(),
        'attachmentUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report sent successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        if (kDebugMode) {
          print("error occurred $e");
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // 1. Top Navigation Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                backgroundImage: (user != null && user!.photoURL != null)
                                    ? NetworkImage(user!.photoURL!)
                                    : null,
                                child: (user == null || user!.photoURL == null)
                                    ? const Text("R",
                                    style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold))
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balanced spacing
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 3. Title Text
                      const Text(
                        "Describe the problem you have encountered. Please be as specific as possible",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Text Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEBF0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: 8,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.purple,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Attachments Section
                      Row(
                        children: [
                          // Thumbnail Preview
                          Container(
                            width: 60,
                            height: 60,
                            clipBehavior: Clip.hardEdge, // Clip image to border
                            decoration: BoxDecoration(
                              color: _selectedImage == null
                                  ? Colors.purple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            // Logic: Show Image if picked, otherwise show Icon
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                                : const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // "Attach image" Button (Clickable)
                          Expanded(
                            child: InkWell(
                              onTap: _pickImage, // Trigger Image Picker
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.attach_file, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text(
                                      "Attach Image",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // 6. Send Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          // Disable button while uploading
                          onPressed: _isUploading ? null : _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isUploading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Send",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.send,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}