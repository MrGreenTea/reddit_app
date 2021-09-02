import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SamplePlayer extends StatefulWidget {
  final String url;
  SamplePlayer({Key? key, required this.url}) : super(key: key);

  @override
  _SamplePlayerState createState() => _SamplePlayerState(url: this.url);
}

class _SamplePlayerState extends State<SamplePlayer> {
  late final FlickManager flickManager;
  final String url;

  _SamplePlayerState({required this.url});

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(this.url),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlickVideoPlayer(flickManager: flickManager),
    );
  }
}
