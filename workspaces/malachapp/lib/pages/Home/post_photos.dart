import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PostPhotos extends StatelessWidget {
  const PostPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MasonryGridView.builder(
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10), // Zaokrąglenie rogów
            child: Image.asset(
              'assets/zd${index + 1}.jpg',
              fit: BoxFit.cover,
            ),
          );
        },
        itemCount: 6, // Number of images
      ),
    );
  }
}
