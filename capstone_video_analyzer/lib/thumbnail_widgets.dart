import 'dart:math';
import 'package:capstone_video_analyzer/services/constants.dart';
import 'package:capstone_video_analyzer/services/string_utils.dart';
import 'package:capstone_video_analyzer/video_player_arguments.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'models/video_data.dart';
import 'services/cloud_service.dart';

class ThumbnailGrid extends StatefulWidget {
  final List<VideoData> videoDataList;

  ThumbnailGrid(this.videoDataList);

  @override
  _ThumbnailGridState createState() => _ThumbnailGridState();
}

class _ThumbnailGridState extends State<ThumbnailGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: widget.videoDataList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 9 / 16,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1),
        itemBuilder: (BuildContext context, int index) {
          final videoData = widget.videoDataList[index];
          return ThumbCard(videoData, _deleteVideo);
        });
  }

  void _deleteVideo(String url) {
    var videoDataList = widget.videoDataList;
    for (var i = 0; i < videoDataList.length; i++) {
      var videoData = videoDataList[i];
      if (url == videoData.videoUrl) {
        setState(() {
          videoDataList.removeAt(i);
          CloudService.deleteVideoFromCloud(videoData.filename);
        });
        break;
      }
    }
  }
}

class ThumbCard extends StatelessWidget {
  final VideoData videoData;
  final Function(String) onDeleteVideo;

  const ThumbCard(this.videoData, this.onDeleteVideo);

  _onTap(BuildContext context) {
    if (videoData.videoUrl == null || videoData.filename == null) return;
    Navigator.pushNamed(context, videoPlayerRoute,
        arguments: VideoPlayerPageArguments(
            videoData.videoUrl!, labelsString(), onDeleteVideo));
  }

  String labelsString({maxEntities: 10}) {
    if (videoData.entities == null || videoData.entities!.isEmpty) return " ";
    return videoData.entities!
        .map((dynamic entity) {
          entity = entity.toString();
          return capitalize(entity);
        })
        .toList()
        .sublist(0, min(videoData.entities!.length, maxEntities))
        .join(', ');
  }

  String timestampString() {
    if (videoData.timestamp == null) return " ";
    return (videoData.timestampGuess ? "Around " : "") +
        DateFormat("MMMM d, yyyy").format(videoData.timestamp!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async => {await _onTap(context)},
        child: ThumbImage(videoData.thumbnailUrl ?? ""));
  }
}

class EmptyThumbCard extends StatelessWidget {
  final double cardWidth;
  const EmptyThumbCard(this.cardWidth);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(
                children: <Widget>[
                  Container(color: Colors.grey[200]),
                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.red[100],
                    ),
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                child: Container(
                    color: Colors.grey[300],
                    width: cardWidth * 0.65,
                    height: 20)),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Container(
                    color: Colors.grey[300],
                    width: cardWidth * 0.55,
                    height: 20))
          ],
        ),
      ),
    );
  }
}

class ThumbImage extends StatelessWidget {
  final String imageUrl;
  ThumbImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      placeholder: (context, url) =>
          Center(child: Container(child: CircularProgressIndicator())),
    );
  }
}
