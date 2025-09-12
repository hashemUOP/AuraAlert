import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aura_alert/theme.dart';

class BackgroundVideoWidget extends StatefulWidget {
  const BackgroundVideoWidget({super.key});

  @override
  State<BackgroundVideoWidget> createState() => _BackgroundVideoWidgetState();
}

class _BackgroundVideoWidgetState extends State<BackgroundVideoWidget> {
  late final VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset('assets/videos/Background_shooting_star.mp4')
      ..initialize().then((_) {
        setState(() {
          videoController.play();
          videoController.setLooping(true);
        });
      });
  }//on initial show the login video

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videoController.value.isInitialized
          ? Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size?.width ?? 0,
                height: videoController.value.size?.height ?? 0,
                child: VideoPlayer(videoController),
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator(color: AppColors.accentDarkPurple,)),//if video didn't appear show a loading circle
    );
  }
}