import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatelessWidget {
  final String url;
  final String labels;
  final Function(String) onDeleteVideo;
  VideoPlayerPage(
    this.url,
    this.labels,
    this.onDeleteVideo,
  );

  @override
  Widget build(BuildContext context) {
    _deleteButtonPressed() async {
      var deleteSelected = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Delete Video"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('Yes')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text('No')),
              ],
            );
          });
      if (deleteSelected != null && deleteSelected) {
        onDeleteVideo(url);
        Navigator.pop(context);
      }
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('View labels'),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('Delete'),
                  value: 2,
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Labels"),
                          content: Text(labels),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Done')),
                          ],
                        );
                      });
                }
                if (value == 2) {
                  _deleteButtonPressed();
                }
              },
            )
          ],
        ),
        body: Expanded(child: VideoViewer(url)));
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
        autoPlay: true,
        showControls: true,
        autoInitialize: true,
        looping: true,
        allowPlaybackSpeedChanging: false,
        allowMuting: false,
        aspectRatio: 9 / 16);
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
