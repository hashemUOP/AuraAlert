import 'package:flutter/material.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

class ArticlePage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String content;

  const ArticlePage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8e44ad),
        iconTheme: const IconThemeData(color: Colors.white), // Ensures back button is white
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Image.asset(
              imagePath, // Ensure this is a relative path (e.g., 'assets/images/learn/pic.png')
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        "Image not found",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              },
            ),

            // CONTENT SECTION
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}