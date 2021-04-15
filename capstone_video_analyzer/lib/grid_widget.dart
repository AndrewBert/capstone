import 'dart:math';
import 'package:capstone_video_analyzer/video_player_arguments.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone_video_analyzer/search.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'string_utils.dart';

class GridWidget extends StatelessWidget {
  final List gridItems;
  GridWidget(this.gridItems);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: gridItems.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          final gridItem = gridItems[index];
          return Container(
            child: Card(child: gridItem),
          );
        });
  }
}

class ThumbnailGrid extends StatefulWidget {
  final Future<List<VideoData>> _queryResults;

  ThumbnailGrid(this._queryResults);

  @override
  _ThumbnailGridState createState() => _ThumbnailGridState();
}

class _ThumbnailGridState extends State<ThumbnailGrid> {

  @override
  void initState() { 
    super.initState();
    _queryResults = search(widget.query);
    
  }
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: widget._queryResults.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          final gridItem = widget._queryResults[index];
          return Container(
            child: Card(child: Text(widget._queryResults[index])),
          );
        });
  }
}

class ThumbCard extends StatelessWidget {
  final VideoData videoData;
  final double cardWidth;

  const ThumbCard(this.videoData, this.cardWidth);

  // const ThumbCard.empty(this.cardWidth) : videoData = null;

  _onTap(BuildContext context) {
    Navigator.pushNamed(context, videoPlayerRoute, arguments: VideoPlayerPageArguments(videoData.videoUrl, videoData.filename));

    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           WatchPage(this.videoData.videoUrl, this.videoData.filename),
    //       fullscreenDialog: true,
    //     ));
  }

  String entitiesString({maxEntities: 10}) {
    if (videoData.entities.isEmpty) return " ";
    return videoData.entities
        .map((dynamic entity) {
          entity = entity.toString();
          return capitalize(entity);
        })
        .toList()
        .sublist(0, min(videoData.entities.length, maxEntities))
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
        child: Container(
          width: cardWidth,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThumbImage(videoData.thumbnailUrl),
                Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                    child: Text(timestampString(),
                        style: Theme.of(context).textTheme.headline6)),
                Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Text(entitiesString(),
                        style: Theme.of(context).textTheme.caption)),
              ],
            ),
          ),
        ));
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
    return AspectRatio(
        aspectRatio: 3 / 2,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
        ));
  }
}
