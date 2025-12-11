import 'package:flutter/material.dart';
import '../../global_widgets/custom_text.dart'; // Using your custom text widget

class ArticlePage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String content;

  // The constructor requires the data for the article to be passed in.
  const ArticlePage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // We use a CustomScrollView to create a beautiful collapsing header effect.
      body: CustomScrollView(
        slivers: [
          // --- The App Bar that collapses as you scroll ---
          SliverAppBar(
            // Make the app bar float and snap back into view
            floating: true,
            pinned: true,

            iconTheme: const IconThemeData(color: Colors.white), 
            // How tall the header is when fully expanded
            expandedHeight: 250.0,
            backgroundColor: const Color(0xFF8e44ad), // A default color
            // The content of the expanded header
            flexibleSpace: FlexibleSpaceBar(
              // The title shrinks and fades into the app bar
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                
              ),
              // The background image of the header
              background: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // Add a dark overlay to make the white title text readable
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
                // Add a loading indicator while the image loads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // Show an error icon if the image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, color: Colors.white));
                },
              ),
            ),
          ),

          // --- The Main Content of the Article ---
          // This part is the scrollable body of the article.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Title (repeated for emphasis)
                  CustomText(
                    title,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fromLeft: 0,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Article Content
                  CustomText(
                    content,
                    fontSize: 18,
                    color: Colors.black87,
                    fromLeft: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}