class VideoData {
  final String? filename;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? timestamp;
  final List<dynamic>? entities;
  final bool timestampGuess;
  final List<String> categories;

  VideoData( 
      {this.filename,
      this.thumbnailUrl,
      this.videoUrl,
      int? timestamp,
      this.timestampGuess = false,
      this.entities,
      this.categories = const []})
      : timestamp = timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
            : null;

  VideoData.fromJson(Map json)
      : filename = json['videoId'],
        thumbnailUrl = json['thumbnail'],
        videoUrl = json['video'],
        timestamp = json['timestampe'],
        timestampGuess = false,
        entities = json['entities'] ?? [],
        categories = _removeNullFromSet(json['categories']);

  static List<String> _removeNullFromSet(List list) {
    List<String?> oldList = List.from(list);
    oldList.removeWhere((value) => value == null);
    List<String> nList = List.from(oldList);
    return nList;
  }
}
