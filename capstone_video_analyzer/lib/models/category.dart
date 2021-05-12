import 'package:capstone_video_analyzer/models/video_data.dart';

class Category {
  final String name;
  final List<VideoData> videoDataList;

  Category(this.name, this.videoDataList);
}
