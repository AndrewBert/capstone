import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';

import 'auth_service.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Future? thumbnailFuture;
  List<CachedNetworkImage> thumbnails = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthService>().currentUser;
    thumbnailFuture = _getThumbnails();
  }
  //download all video thumbnails
  // List<AnalysisResults> analysisResults = [];

  //display thumbnails in gallery

  //open video player on thumbnail pressed

  _getThumbnails() async {
    if (currentUser == null) return [];

    var thumbnailStorage =
        FirebaseStorage.instanceFor(bucket: "gs://thumbnails5555")
            .ref()
            .child(currentUser!.uid);

    var result = await thumbnailStorage.listAll();

    for (var imageRef in result.items) {
      var downloadUrl = await imageRef.getDownloadURL();
      var thumbnail = CachedNetworkImage(
        imageUrl: downloadUrl.toString(),
        fit: BoxFit.scaleDown,
        placeholder: (context, url) => CircularProgressIndicator(),
      );
      thumbnails.add(thumbnail);
    }
  }

  Future<void> _getLabels(BuildContext context) async {
    User? currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    var labelStorage =
        FirebaseStorage.instanceFor(bucket: "gs://analysis_json5555")
            .ref()
            .child(currentUser.uid);

    var result = await labelStorage.listAll();

    result.items.forEach((labelsJson) async {
      var downloadUrl = await labelsJson.getDownloadURL();
      //TODO parse json into AnlaysisResults
    });
  }

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(PickedFile? file, BuildContext context) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    User? currentUser = context.read<AuthService>().currentUser;
    //TODO throw proper exception instead?
    if (currentUser == null) return null;

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(currentUser.uid)
        .child('/${path.basename(file.path)}');

    final metadata = SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {'picked-file-path': file.path});

    uploadTask = ref.putFile(File(file.path), metadata);

    _getThumbnails();

    return Future.value(uploadTask);
  }

  Future<void> selectVideoForUpload(BuildContext context) async {
    PickedFile? file =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    await uploadFile(file, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => selectVideoForUpload(context),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: thumbnailFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Container(
                child: GridView.builder(
                    itemCount: thumbnails.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      final thumbnailItem = thumbnails[index];
                      return Container(
                        color: Colors.black,
                        child: thumbnailItem,
                      );
                    }));
        },
      ),
    );
  }
}
