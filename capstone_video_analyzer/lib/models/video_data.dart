class VideoData {
  final String? filename;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? timestamp;
  final List<dynamic>? entities;
  final bool timestampGuess;
  final List<dynamic>? categories;

  VideoData( 
      {this.filename,
      this.thumbnailUrl,
      this.videoUrl,
      int? timestamp,
      this.timestampGuess = false,
      this.entities,
      this.categories})
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

  static List _removeNullFromSet(List list) {
    var newList = List.from(list);
    newList.removeWhere((value) => value == null);
    return newList;
  }
}
