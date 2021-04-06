import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  //download all video thumbnails
  List<Image> thumbnails = [];

  //display thumbnails in gallery

  //open video player on thumbnail pressed

  Future<void> _getThumbnails(BuildContext context) async {
    User? currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    var thumbnailStorage =
        FirebaseStorage.instanceFor(bucket: "gs://thumbnails5555")
            .ref()
            .child(currentUser.uid);

    var result = await thumbnailStorage.listAll();

     result.items.forEach((imageReference) async {
        var downloadUrl = await imageReference.getDownloadURL();
        var thumbnail = Image.network(
          downloadUrl.toString(),
          fit: BoxFit.scaleDown,
        );
        thumbnails.add(thumbnail);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
      ),
      body: FutureBuilder(
        future: _getThumbnails(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
                child: GridView.builder(
                    itemCount: thumbnails.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (BuildContext context, int index) {
                      final thumbnailItem = thumbnails[index];
                      return Container(
                        child: thumbnailItem,
                      );
                    }));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: MediaQuery.of(context).size.height / 1.25,
                width: MediaQuery.of(context).size.width / 1.25,
                child: CircularProgressIndicator());
          }

          return Container();
        },
      ),
    );
  }
}
