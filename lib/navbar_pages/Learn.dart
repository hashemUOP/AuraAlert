import 'package:flutter/material.dart';
import '../global_widgets/custom_text.dart';
import 'package:aura_alert/navbar_pages/learn/emergency_guide_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aura_alert/navbar_pages/learn/article_page.dart';

// --- 1. Data Model ---
class LearnTopic {
  final String title;
  final IconData icon;
  final Color color;
  final String imagePath;
  final String content;

  const LearnTopic({
    required this.title,
    required this.icon,
    required this.color,
    required this.imagePath,
    required this.content,
  });
}

// --- 2. Database with EXPANDED Content ---
final List<LearnTopic> learnTopics = [
  LearnTopic(
    title: 'What is Epilepsy?',
    icon: Icons.psychology_outlined,
    color: Colors.blue,
    imagePath: 'assets/images/learn/epilepsy_intro.jpg',
    content: 'Epilepsy is a chronic disorder, the hallmark of which is recurrent, unprovoked seizures. A person is diagnosed with epilepsy if they have two unprovoked seizures (or one unprovoked seizure with the likelihood of more) that were not caused by some known and reversible medical condition like alcohol withdrawal or extremely low blood sugar.\n\n'
        'The seizures in epilepsy may be related to a brain injury or a family tendency, but often the cause is completely unknown. The word "epilepsy" does not indicate anything about the cause of the person’s seizures or their severity.\n\n'
        'Many people with epilepsy have more than one type of seizure and may have other symptoms of neurological problems as well. Sometimes EEG (electroencephalogram) testing, clinical history, family history, and outlook are similar among a group of people with epilepsy. In these situations, their condition can be defined as a specific epilepsy syndrome.\n\n'
        'Epilepsy is the fourth most common neurological disorder and affects people of all ages. It means the same thing as "seizure disorders." It is characterized by unpredictable seizures and can cause other health problems. However, the majority of people with epilepsy live full, active, and productive lives.',
  ),
  LearnTopic(
    title: 'Types of Seizures',
    icon: Icons.dashboard_customize_outlined,
    color: Colors.orange,
    imagePath: 'assets/images/learn/seizure_types.webp',
    content: 'Seizures are classified into two broad categories based on where they start in the brain: Focal seizures and Generalized seizures.\n\n'
        '1. FOCAL SEIZURES:\n'
        'These seizures start in one area or group of cells in one side of the brain.\n'
        '- Focal Onset Aware Seizures: When a person is awake and aware during a seizure. They may know what is happening but feel frozen. This was previously called a "simple partial seizure."\n'
        '- Focal Onset Impaired Awareness: When a person is confused or their awareness is affected in some way during a focal seizure. This was previously called a "complex partial seizure."\n\n'
        '2. GENERALIZED SEIZURES:\n'
        'These affect both sides of the brain or groups of cells on both sides of the brain at the same time.\n'
        '- Absence Seizures: Also known as "petit mal," these cause a short period of "blanking out" or staring into space.\n'
        '- Tonic-Clonic Seizures: Also known as "grand mal," these are what most people think of when they hear the word "seizure." They involve loss of consciousness, body stiffening (tonic), and shaking (clonic).\n'
        '- Atonic Seizures: Muscles suddenly lose strength. The eyelids may droop, the head may nod, and the person may drop things or fall to the ground.',
  ),
  LearnTopic(
    title: 'Medication Guide',
    icon: Icons.medication_outlined,
    color: Colors.green,
    imagePath: 'assets/images/learn/medication.jpg',
    content: 'Anti-seizure medication (ASM) is the most common way to treat epilepsy. About 7 out of 10 people with epilepsy can control their seizures with medication alone.\n\n'
        'KEY RULES FOR MEDICATION:\n'
        '1. Consistency is Key: Take your medicine exactly as prescribed. Missing doses can cause your seizures to come back or become more intense.\n\n'
        '2. Do Not Stop Suddenly: Never stop taking your medication without consulting your doctor. Stopping suddenly can trigger a dangerous condition called "status epilepticus" (continuous seizures).\n\n'
        '3. Watch for Side Effects: Common side effects can include fatigue, dizziness, or mood changes. If side effects are severe, talk to your doctor—do not just quit the drug. There may be a different medication that works better for you.\n\n'
        '4. Interactions: Be careful with other substances. Alcohol, certain herbal supplements, and other prescription drugs can interact with seizure medications, making them less effective or increasing side effects.',
  ),
  LearnTopic(
    title: 'Danger Signs',
    icon: Icons.warning_amber_rounded,
    color: Colors.red,
    imagePath: 'assets/images/learn/danger_signs.jpg',
    content: 'Most seizures end on their own and do not require emergency medical attention. However, there are specific situations where you MUST call 911 or your local emergency number immediately:\n\n'
        'CALL AN AMBULANCE IF:\n'
        '- The seizure lasts longer than 5 minutes.\n'
        '- The person has another seizure soon after the first one, without regaining consciousness in between.\n'
        '- Consciousness does not return after the shaking has stopped.\n'
        '- The person is injured during the seizure (e.g., a fall or cut).\n'
        '- The seizure happens in water (swimming pool or bathtub).\n'
        '- The person is pregnant or has diabetes.\n'
        '- The person has difficulty breathing after the seizure.\n\n'
        'Status Epilepticus: A seizure that lasts longer than 5 minutes is a medical emergency. It can lead to permanent brain damage or death if not treated immediately with rescue medication.',
  ),
  LearnTopic(
    title: 'Myths & Facts',
    icon: Icons.question_answer_outlined,
    color: Colors.teal,
    imagePath: 'assets/images/learn/myths.png',
    content: 'Epilepsy is often misunderstood. Clearing up these myths is essential for proper first aid and reducing stigma.\n\n'
        'MYTH: You can swallow your tongue during a seizure.\n'
        'FACT: It is physically impossible to swallow your tongue. You should NEVER put anything in a person\'s mouth during a seizure. Doing so can break their teeth or injure your fingers.\n\n'
        'MYTH: You should restrain someone having a seizure.\n'
        'FACT: Never hold someone down. This can cause bone fractures or muscle injuries. Instead, protect them by moving dangerous objects away and placing something soft under their head.\n\n'
        'MYTH: Epilepsy is contagious.\n'
        'FACT: You cannot catch epilepsy from another person. It is not an infection.\n\n'
        'MYTH: All people with epilepsy are sensitive to flashing lights.\n'
        'FACT: Photosensitive epilepsy affects only about 3% of people with epilepsy. For most, flashing lights do not trigger seizures.',
  ),
  LearnTopic(
    title: 'After Seizure Care',
    icon: Icons.healing_outlined,
    color: Colors.indigo,
    imagePath: 'assets/images/learn/recovery.jpg',
    content: 'The time immediately following a seizure is called the "post-ictal" phase. This recovery period can last from minutes to hours. The person may be confused, tired, embarrassed, or have a headache.\n\n'
        'STEPS FOR CARE:\n'
        '1. Check for Injuries: Look for cuts or bruises that may have happened during the fall.\n\n'
        '2. Recovery Position: If they are not fully awake, gently roll them onto their side. This keeps their airway clear and prevents choking on saliva or vomit.\n\n'
        '3. Stay With Them: Do not leave the person alone until they are fully alert and aware of their surroundings. Talk to them in a calm, reassuring voice.\n\n'
        '4. No Food or Water: Do not offer them anything to eat or drink until they are fully awake and able to swallow safely.\n\n'
        '5. Let Them Rest: Seizures consume a massive amount of energy. The person will likely want to sleep. Let them rest in a safe place.',
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
                    // _buildDownloadCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticlePage(
                    title: topic.title,
                    imagePath: topic.imagePath,
                    content: topic.content,
                  ),
                ),
              );
            },
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

//   Widget _buildDownloadCard() {
//     return Card(
//       elevation: 0,
//       color: const Color(0xFFF0E6F6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: () async {
//           try {
//             final byteData = await rootBundle.load(
//               'assets/images/Seizure-First-Aid-Poster.png',
//             );
//
//             final tempDir = await getTemporaryDirectory();
//             final path = '${tempDir.path}/Seizure-First-Aid-Poster.png';
//
//             final file = File(path);
//             await file.writeAsBytes(byteData.buffer.asUint8List());
//
//             await Share.shareXFiles(
//               [XFile(path)],
//               text: 'Here is the Epilepsy First Aid card from my AuraAlert app.',
//             );
//           } catch (e) {
//             print('Error sharing image: $e');
//           }
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: const Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.download_for_offline_outlined,
//                 color: Color(0xFF8e44ad),
//                 size: 40,
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomText(
//                       'Download First Aid Card',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                       fromLeft: 0,
//                     ),
//                     CustomText(
//                       "Keep it offline, share it with your family.",
//                       fontSize: 14,
//                       color: Colors.black54,
//                       fromLeft: 0,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
}