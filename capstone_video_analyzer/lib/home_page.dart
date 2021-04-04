import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    final PickedFile? file = await _picker.getVideo(
        source: source, maxDuration: const Duration(seconds: 10));
    await _playVideo(file);
    var bucketUri = await uploadFile(file);
  }

  Future<void> _playVideo(PickedFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _controller = controller;
      final double volume = 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<String?> uploadFile(PickedFile? file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    var fileName = (file.path.split('/').last);

    // Create a Reference to the file
    Reference ref =
        FirebaseStorage.instance.ref().child('videos').child('/$fileName');

    final metadata = SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {'picked-file-path': file.path});

    ref.putFile(File(file.path), metadata);

    var bucketPath = 'gs://video-intelligence-4f110.appspot.com/videos';

    var filePathInStorage = '$bucketPath/$fileName';

    return filePathInStorage;
  }

   @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  // Widget _previewVideo() {
  //   final Text? retrieveError = _getRetrieveErrorWidget();
  //   if (retrieveError != null) {
  //     return retrieveError;
  //   }
  //   if (_controller == null) {
  //     return const Text(
  //       'You have not yet picked a video',
  //       textAlign: TextAlign.center,
  //     );
  //   }
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: AspectRatioVideo(_controller),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Upload")),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthService>().signOut();
                },
                child: Text("Sign out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
