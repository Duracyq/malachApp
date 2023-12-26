import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/services/storage_service.dart';

class StorageLoader extends StatelessWidget{
  final Storage storage;
  final String uri;
  const StorageLoader({super.key, 
    required this.storage,
    required this.uri
  }); 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.getImageUrls(uri),
      builder: (BuildContext context,
          AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: CachedNetworkImage(
                    imageUrl: snapshot.data![index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                );
              },
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Container();
      },
    );
  }
}
