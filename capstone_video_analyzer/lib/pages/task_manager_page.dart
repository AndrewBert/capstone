import 'dart:io';

import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;



/// A StatefulWidget which keeps track of the current uploaded files.
class TaskManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TaskManager();
  }
}

class _TaskManager extends State<TaskManager> {
  List<UploadTask> _uploadTasks = [];

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

    return Future.value(uploadTask);
  }

  Future<void> handleUploadType(BuildContext context) async {
    PickedFile? file =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    UploadTask? task = await uploadFile(file, context);
    if (task != null) {
      setState(() {
        _uploadTasks = [..._uploadTasks, task];
      });
    }
  }

  void _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTasks = _uploadTasks..removeAt(index);
    });
  }

  Future<void> _downloadLink(Reference ref) async {
    final link = await ref.getDownloadURL();

    await Clipboard.setData(ClipboardData(
      text: link,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Success!\n Copied download URL to Clipboard!',
        ),
      ),
    );
  }

  Future<void> _downloadFile(Reference ref) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
          'at path: ${ref.fullPath} \n'
          'Wrote "${ref.fullPath}" to tmp-${ref.name}.txt',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Example App'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => handleUploadType(context)),
        ],
      ),
      body: _uploadTasks.isEmpty
          ? const Center(child: Text("Press the '+' button to add a new file."))
          : ListView.builder(
              itemCount: _uploadTasks.length,
              itemBuilder: (context, index) => UploadTaskListTile(
                task: _uploadTasks[index],
                onDismissed: () => _removeTaskAtIndex(index),
                onDownloadLink: () {
                  _downloadLink(_uploadTasks[index].snapshot.ref);
                },
                onDownload: () {
                  _downloadFile(_uploadTasks[index].snapshot.ref);
                },
              ),
            ),
    );
  }
}

/// Displays the current state of a single UploadTask.
class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    Key? key,
    this.task,
    this.onDismissed,
    this.onDownload,
    this.onDownloadLink,
  }) : super(key: key);

  /// The [UploadTask].
  final UploadTask? /*!*/ task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback? /*!*/ onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback? /*!*/ onDownload;

  /// Triggered when the user presses the "link" button on a completed upload task.
  final VoidCallback? /*!*/ onDownloadLink;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(TaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalBytes}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task?.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        Widget subtitle = const Text('---');
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            subtitle = const Text('Upload canceled.');
          } else {
            // ignore: avoid_print
            print(asyncSnapshot.error);
            subtitle = const Text('Something went wrong.');
          }
        } else if (snapshot != null) {
          subtitle = Text('$state: ${_bytesTransferred(snapshot)} bytes sent');
        }

        return Dismissible(
          key: Key(task.hashCode.toString()),
          //todo changed dimissed() to dismissed
          onDismissed: ($) => onDismissed,
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: task?.pause,
                  ),
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: task?.cancel,
                  ),
                if (state == TaskState.paused)
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: task?.resume,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: onDownload,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: onDownloadLink,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
