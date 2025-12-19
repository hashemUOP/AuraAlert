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
        title: Text(title,style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF8e44ad),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ LOAD IMAGE DIRECTLY FROM ASSETS
            Image.asset(
              imagePath, // 🔥 NO "assets/" added
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 220,
                  child: Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomText(
                content,
                fontSize: 15,
                color: Colors.black87,
                fromLeft: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
