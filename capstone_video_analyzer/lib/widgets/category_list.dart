import 'package:capstone_video_analyzer/models/category.dart';
import 'package:flutter/material.dart';

import '../thumbnail_widgets.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onDeleteVideo;
  final List<Category> categories;

  CategoryList(this.onDeleteVideo, this.categories);

  @override
  Widget build(BuildContext context) {
    categories.sort(
        (b, a) => a.videoDataList.length.compareTo(b.videoDataList.length));
    return Container(
      padding: EdgeInsets.only(top: 60),
      height: 50,
      child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            final videoDataList = categories[index].videoDataList;
            return Column(
              children: [
                Text(categories[index].name),
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
                        child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: ThumbCard(
                                videoDataList[i], onDeleteVideo)),
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
