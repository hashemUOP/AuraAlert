import 'package:flutter/material.dart';
import '../global_widgets/custom_text.dart';
import 'package:aura_alert/navbar_pages/learn/emergency_guide_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aura_alert/navbar_pages/learn/article_page.dart';

// --- Data Model for a Learning Topic ---
class LearnTopic {
  final String title;
  final IconData icon;
  final Color color;

  const LearnTopic({
    required this.title,
    required this.icon,
    required this.color,
  });
}

// --- Our Simulated Database ---
final List<LearnTopic> learnTopics = [
  LearnTopic(
    title: 'What is Epilepsy?',
    icon: Icons.psychology_outlined,
    color: Colors.blue,
  ),
  LearnTopic(
    title: 'Types of Seizures',
    icon: Icons.dashboard_customize_outlined,
    color: Colors.orange,
  ),
  LearnTopic(
    title: 'Medication Guide',
    icon: Icons.medication_outlined,
    color: Colors.green,
  ),
  LearnTopic(
    title: 'Danger Signs',
    icon: Icons.warning_amber_rounded,
    color: Colors.red,
  ),
  LearnTopic(
    title: 'Myths & Facts',
    icon: Icons.question_answer_outlined,
    color: Colors.teal,
  ),
  LearnTopic(
    title: 'After Seizure Care',
    icon: Icons.healing_outlined,
    color: Colors.indigo,
  ),
];

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmergencyCard(),
                    const SizedBox(height: 24),
                    _buildLearnGrid(),
                    const SizedBox(height: 24),
                    _buildDownloadCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the purple, curved header at the top of the screen.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF8e44ad),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'Learn About Epilepsy & First Aid',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fromLeft: 0,
          ),
          SizedBox(height: 8),
          CustomText(
            '"Knowledge saves lives."',
            fontSize: 16,
            color: Colors.white70,
            fromLeft: 0,
          ),
        ],
      ),
    );
  }

  /// Builds the prominent emergency guide card.
  Widget _buildEmergencyCard() {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 4,
          shadowColor: Colors.yellow.withOpacity(0.3),
          color: Colors.yellow[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyGuidePage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.emergency_outlined,
                    color: Colors.black87,
                    size: 40,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Emergency Guide',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fromLeft: 0,
                        ),
                        SizedBox(height: 4),
                        CustomText(
                          'Open First Aid Now',
                          fontSize: 15,
                          color: Colors.black54,
                          fromLeft: 0,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.black54),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the grid of learning topics.
  Widget _buildLearnGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: learnTopics.length,
      itemBuilder: (context, index) {
        final topic = learnTopics[index];
        return _buildTopicCard(topic);
      },
    );
  }

  /// Builds a single card for the learning grid.
  Widget _buildTopicCard(LearnTopic topic) {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            // --- MODIFIED ONTAP FUNCTION ---
            onTap: () {
              // In a real application, you would make an API call here to get
              // the imageUrl and content from your database based on the topic.title.
              // For now, we will use placeholder data to demonstrate the navigation.

              // Example placeholder data:
              String imageUrl =
                  'https://images.unsplash.com/photo-1579154204601-01588f351e67?fit=crop&w=800&q=80';
              String content =
                  'This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.This is the detailed content for the article titled "${topic.title}". In a real app, this text would be much longer and would be fetched from your database based on the topic you selected. This reusable page allows you to display any article with a consistent and beautiful design.';

              // Navigate to the reusable ArticlePage and pass the data to it.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticlePage(
                    title: topic.title,
                    imageUrl: imageUrl,
                    content: content,
                  ),
                ),
              );
            },
            // --- END OF MODIFICATION ---
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(topic.icon, color: topic.color, size: 36),
                  const Spacer(),
                  CustomText(
                    topic.title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fromLeft: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the download card at the bottom.
  Widget _buildDownloadCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF0E6F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // This is the corrected, modern implementation for mobile
        onTap: () async {
          try {
            // 1. Load the image from your assets using the CORRECT PATH
            final byteData = await rootBundle.load(
              'images/Seizure-First-Aid-Poster.png',
            );

            // 2. Get a temporary directory. This is always safe to write to.
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/Seizure-First-Aid-Poster.png';

            // 3. Write the asset data to the temporary file
            final file = File(path);
            await file.writeAsBytes(byteData.buffer.asUint8List());

            // 4. Use share_plus to open the native share dialog
            await Share.shareXFiles(
              [XFile(path)],
              text:
              'Here is the Epilepsy First Aid card from my AuraAlert app.',
            );
          } catch (e) {
            print('Error sharing image: $e');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                Icons.download_for_offline_outlined,
                color: Color(0xFF8e44ad),
                size: 40,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Download First Aid Card',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fromLeft: 0,
                    ),
                    CustomText(
                      "Keep it offline, share it with your family.",
                      fontSize: 14,
                      color: Colors.black54,
                      fromLeft: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
