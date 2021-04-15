import 'package:flutter/material.dart';

import 'thumbnail_widgets.dart';

class SearchPageV2 extends StatelessWidget {
  final String query;
  SearchPageV2(this.query) : assert(query != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ThumbnailGrid(query, 400));
  }
}