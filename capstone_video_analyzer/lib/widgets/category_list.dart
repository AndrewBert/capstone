import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:flutter/material.dart';

import '../thumbnail_widgets.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onDeleteVideo;
  final Map<String, List<VideoData>> categories;

  CategoryList(this.onDeleteVideo, this.categories);



  @override
  Widget build(BuildContext context) {
    var allVideoData = categories.values.toList();
    var categoryNames = categories.keys.toList();
    return Container(
      padding: EdgeInsets.only(top: 60),
      height: 50,
      child: ListView.builder(
        
          itemCount: allVideoData.length,
          itemBuilder: (BuildContext context, int index) {
            final videoDataList = allVideoData[index];
            return Column(
              children: [
                Text(categoryNames[index]),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 300,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: videoDataList.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 1),
                        child: AspectRatio(aspectRatio: 9/16, child: ThumbCard(videoDataList[i], onDeleteVideo)),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
