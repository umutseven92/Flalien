import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String url;

  VideoPage(this.url);

  @override
  State<StatefulWidget> createState() => VideoPageState(url);
}

//TODO: Stop video playback if the user presses back
class VideoPageState extends State<VideoPage> {
  String url;
  VideoPlayerController _controller;
  bool _isPlaying = false;

  VideoPageState(String url) {
    this.url = "$url/HLSPlaylist.m3u8";
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url)
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Uri.parse(url).host)),
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : LoadingWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _controller.value.isPlaying ? _controller.pause : _controller.play,
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
