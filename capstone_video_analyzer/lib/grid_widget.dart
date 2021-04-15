
import 'package:flutter/material.dart';



class GridWidget extends StatelessWidget {
  final List gridItems;
  GridWidget(this.gridItems);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: gridItems.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          final gridItem = gridItems[index];
          return Container(
            child: Card(child: gridItem),
          );
        });
  }
}


