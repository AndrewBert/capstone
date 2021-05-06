import 'package:cloud_functions/cloud_functions.dart';

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

Future<List<VideoData>> search(String query) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('search');
  // ..timeout = const Duration(seconds: 60);
  try {
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{'text': query},
    );
    final List<VideoData> response = result.data['hits'].map<VideoData>((hit) {
      bool timestampGuess =
          hit["timestampGuess"] == null ? false : hit["timestampGuess"];
      return VideoData(
          filename: hit["filepath"],
          thumbnailUrl: hit["thumbnail"],
          videoUrl: hit["video"],
          timestamp: hit["timestamp"],
          timestampGuess: timestampGuess,
          entities: hit["entities"] ?? []);
    }).toList();
    return response;
  } catch (err) {
    print('Error in search! $err');
    return [];
  }
}

Future<List<VideoData>> getAllVideoData() async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('getAllVideoData');
  // ..timeout = const Duration(seconds: 60);
  try {
    final HttpsCallableResult result = await callable.call();

    final List<VideoData> response =
        result.data['videoData'].map<VideoData>((video) {
      bool timestampGuess =
          video["timestampGuess"] == null ? false : video["timestampGuess"];

      return VideoData(
          filename: video["videoId"],
          thumbnailUrl: video["thumbnail"],
          videoUrl: video["video"],
          timestamp: video["timestamp"],
          timestampGuess: timestampGuess,
          entities: video["entities"] ?? []);
    }).toList();

    return response;
  } catch (err) {
    print('Error in search! $err');
    return [];
  }
}

Future<void> deleteVideo(String? filename) async {
  if (filename == null) return;

  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('deleteVideo');
  // ..timeout = const Duration(seconds: 60);
  try {
    await callable.call(
      <String, dynamic>{'fileName': filename},
    );
  } catch (err) {
    print('Error in search! $err');
  }
}
