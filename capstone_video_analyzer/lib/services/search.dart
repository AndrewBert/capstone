import 'package:cloud_functions/cloud_functions.dart';

class VideoData {
  final String? filename;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? timestamp;
  final List<dynamic> entities;
  final bool timestampGuess;

  VideoData(this.filename, this.thumbnailUrl, this.videoUrl, int? timestamp,
      this.timestampGuess, this.entities)
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
      return VideoData(hit["filepath"], hit["thumbnail"], hit["video"],
          hit["timestamp"], timestampGuess, hit["entities"] ?? []);
    }).toList();
    return response;
  } catch (err) {
    print('Error in search! $err');
    return [];
  }
}
