import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ThumbImage extends StatelessWidget {
  final String imageUrl;
  ThumbImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      placeholder: (context, url) =>
          Center(child: Container(child: CircularProgressIndicator())),
    );
  }
}