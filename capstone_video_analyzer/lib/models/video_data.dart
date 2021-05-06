class VideoData {
  final String? filename;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? timestamp;
  final List<dynamic>? entities;
  final bool timestampGuess;

  VideoData(
      {this.filename,
      this.thumbnailUrl,
      this.videoUrl,
      int? timestamp,
      this.timestampGuess = false,
      this.entities})
      : timestamp = timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
            : null;
}


