import 'package:capstone_video_analyzer/models/category.dart';
import 'package:flutter/material.dart';

import 'thumbnail_card.dart';


class CategoryList extends StatelessWidget {
  final Function(String) onDeleteVideo;
  final List<Category> categories;

  CategoryList(this.categories, this.onDeleteVideo);

  @override
  Widget build(BuildContext context) {
    categories.sort(
        (b, a) => a.videoDataList.length.compareTo(b.videoDataList.length));
    return Container(
      child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            final videoDataList = categories[index].videoDataList;
            return Column(
              children: [
                Text(categories[index].name.toUpperCase()),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 240,
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
