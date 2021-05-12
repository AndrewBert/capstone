import 'dart:math';

import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:capstone_video_analyzer/models/video_player_arguments.dart';
import 'package:capstone_video_analyzer/services/constants.dart';
import 'package:capstone_video_analyzer/services/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'thumbnail_image.dart';

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