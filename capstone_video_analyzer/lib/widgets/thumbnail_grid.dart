import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:capstone_video_analyzer/widgets/thumbnail_card.dart';
import 'package:flutter/material.dart';


class ThumbnailGrid extends StatefulWidget {
  final List<VideoData> videoDataList;
  final Function(String) onDeleteVideo;

  ThumbnailGrid(this.videoDataList, this.onDeleteVideo);

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
          return ThumbCard(videoData, widget.onDeleteVideo);
        });
  }

  
}