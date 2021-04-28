import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatelessWidget {
  final String url;
  final String labels;
  final String? title;
  VideoPlayerPage(this.url, this.labels, {this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Video Player"),
        ),
        body: Column(
          children: <Widget>[
            SingleChildScrollView(child: Text(labels)),
            Expanded(child: Center(child: VideoViewer(url))),
          ],
        ));
  }
}

class VideoViewer extends StatefulWidget {
  final String url;
  final String? title;
  VideoViewer(this.url, {this.title});

  @override
  State<StatefulWidget> createState() {
    return _VideoViewerState();
  }
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        allowFullScreen: false,
        autoPlay: false,
        showControls: true,
        autoInitialize: true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}

void showWatchDialog(BuildContext context, String url, [String title = " "]) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return WatchDialog(url, title);
    },
  );
}

class WatchDialog extends StatelessWidget {
  final String url;
  final String? title;
  WatchDialog(this.url, this.title);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? ''),
      content: Container(width: 1000, child: VideoViewer(this.url)),
      actions: <Widget>[
        TextButton(
          child: Text('Back'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
