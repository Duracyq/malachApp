import 'package:flutter/material.dart';
import 'package:malachapp/services/storage_service.dart' as storage;

class PostWidget extends StatelessWidget {
  final String imagePath; // Path to the image in Firebase Storage
  final String title;
  final String description;

  PostWidget({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    String limitedDescription = _limitDescription(description);

    return Card(
      elevation: 3.0,
      margin: EdgeInsets.all(10.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _getImageUrl(imagePath), // Call _getImageUrl with await
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 200.0,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Text('Error loading image: ${snapshot.error}');
              }

              String imageUrl = snapshot.data ?? '';
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 200.0,
                width: double.infinity,
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  limitedDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _limitDescription(String description) {
    const int maxChars = 200;

    if (description.length <= maxChars) {
      return description;
    } else {
      return '${description.substring(0, maxChars - 3)}...';
    }
  }

  Future<String> _getImageUrl(String imagePath) async {
    final storageService = storage.Storage();
    List<String> urls = await storageService.getImageUrls(imagePath);

    // Assuming you only have one image, return the first URL
    return urls.isNotEmpty ? urls.first : '';
  }
}
