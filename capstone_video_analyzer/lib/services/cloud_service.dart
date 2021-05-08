import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CloudService {
  static Future<List<VideoData>> search(String query) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('search');
    // ..timeout = const Duration(seconds: 60);
    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'text': query},
      );
      final List<VideoData> response =
          result.data['hits'].map<VideoData>((hit) {
        // bool timestampGuess =
        //     hit["timestampGuess"] == null ? false : hit["timestampGuess"];
        return VideoData.fromJson(hit);
      }).toList();
      return response;
    } catch (err) {
      print('Error in search! $err');
      return [];
    }
  }

  static Future<List<VideoData>> getAllVideoData() async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getAllVideoData');
    // ..timeout = const Duration(seconds: 60);
    try {
      final HttpsCallableResult result = await callable.call();

      final List<VideoData> response =
          result.data['videoData'].map<VideoData>((video) {
        // bool timestampGuess =
        //     video["timestampGuess"] == null ? false : video["timestampGuess"];

        return VideoData.fromJson(video);
      }).toList();

      return response;
    } catch (err) {
      print('Error in search! $err');
      return [];
    }
  }

  static Future<void> deleteVideoFromCloud(String? filename) async {
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
}
