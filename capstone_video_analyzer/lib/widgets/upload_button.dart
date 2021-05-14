import 'dart:io';
import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;


class UploadButton extends StatelessWidget {
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Uploading video...')));

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

    return Future.value(uploadTask);
  }

  Future<void> handleUploadType(BuildContext context) async {
    PickedFile? file =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    await uploadFile(file, context);
    // UploadTask? task = await uploadFile(file, context);
    // if (task != null) {
    //   setState(() {
    //     _uploadTasks = [..._uploadTasks, task];
    //   });
    // }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FloatingActionButton(
        onPressed: () => handleUploadType(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.file_upload),
      ),
    );
  }
}
