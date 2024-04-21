import 'dart:io';
import 'dart:ui';

import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:malachapp/services/request_permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class Post3 extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const Post3({Key? key, required this.snapshot}) : super(key: key);

  @override
  _Post3State createState() => _Post3State();
}

class _Post3State extends State<Post3> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = widget.snapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = themeProvider.currentThemeKey == 'light'
        ? const Color.fromARGB(255, 133, 196, 255)
        : Colors.blueGrey;
    final color2 = themeProvider.currentThemeKey == 'light'
        ? const Color.fromARGB(255, 133, 196, 255)
        : Colors.grey.shade900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Name'),
        actions: [
          _buildPhotoAction(color),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopImage(color),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEventDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAction(Color color) {
    if(data['sideImageUrl'] == null) return Container();
    return GestureDetector(
      onTap: () => _showPhotoGallery(context, color),
      child: Padding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 14, left: 8),
        child: SizedBox(
          width: 70.0,
          height: 70.0,
          child: Shimmer.fromColors(
            period: const Duration(milliseconds: 1000),
            baseColor: color.withOpacity(0.9),
            highlightColor: color.withOpacity(0.3),
            child: const MyText1(
              text: 'Photos',
              rozmiar: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopImage(Color gradientColor) {
    String mainImageUrl = data['mainImageUrl'] as String? ?? '';  // Provide a default image path if null

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: (mainImageUrl != '') ? CachedNetworkImageProvider(mainImageUrl) : const CachedNetworkImageProvider('https://firebasestorage.googleapis.com/v0/b/malachapp.appspot.com/o/favicon.png?alt=media&token=5b974a23-3b18-4a6d-a41b-4a9e78dd91b0'),  // Use the validated or default image URL
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, gradientColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }


 Widget _buildEventDetails() {
  // Convert the Timestamp to DateTime
  DateTime createdAt = data['createdAt'].toDate();

  // Format the DateTime as a String
  String formattedDate = DateFormat('dd.MM.yyyy').format(createdAt);

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText1(
            text: data['title'],
            rozmiar: 34,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              formattedDate, // replace with the formatted date
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ],
      ),
        const SizedBox(height: 10),
        MyText2(
          text:
            data['description'],
          rozmiar: 16,
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Colors.grey,
          indent: 5,
          endIndent: 5,
          thickness: 4,
        ),
      ],
    );
  }

  void _showPhotoGallery(BuildContext context, Color border) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildPhotoGallery(border);
      },
    );
  }

  Widget _buildPhotoGallery(Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color.withOpacity(0.5), width: 3),
          left: BorderSide(color: color.withOpacity(0.5), width: 3),
          right: BorderSide(color: color.withOpacity(0.5), width: 3),
          bottom: BorderSide.none,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
            itemCount: data['sideImageUrl'].length, // Number of images
            itemBuilder: (BuildContext context, int index) {
              return _buildPhotoItem(context, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showPhotoDialog(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image(
          image: CachedNetworkImageProvider(
            data['sideImageUrl'][index] as String, // Use the validated image URL
          ),
          // placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          // errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildPhotoDialog(context, index);
      },
    );
  }

  Widget _buildPhotoDialog(BuildContext context, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: FittedBox(
                  child: Image(
                    image: CachedNetworkImageProvider(
                      data['sideImageUrl'][index] as String,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => _saveImage(context, data['sideImageUrl'][index] as String),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveImage2(BuildContext context, String url) async {
    try {
      var res = http.get(Uri.parse(url));
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File(path.join(dir.path, path.basename(url)));
      await file.writeAsBytes((await res).bodyBytes);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Download Complete'),
            content: const Text('The image has been saved to your gallery.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    }
  }

  Future<void> _saveImage3(String imageUrl) async {
    try {
      // Check and request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Fetching the image from the internet
        var response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          // Getting a directory where we can save the file
          Directory directory = await getApplicationDocumentsDirectory();
          String filePath = '${directory.path}/downloadedImage.jpg';
          File file = File(filePath);
          // Writing the file
          await file.writeAsBytes(response.bodyBytes);
          print("File saved at $filePath");
        } else {
          print('Failed to download image: ${response.statusCode}');
        }
      } else {
        print('Storage permission not granted');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  

  Future<void> _saveImage(BuildContext context, String url) async {
    try {
      final hasStoragePermission = await requestStoragePermission();

      if (!hasStoragePermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage Permission Denied')),
          );
        }
        return;
      }

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir.path,
          showNotification: true,
          openFileFromNotification: true,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get directory path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
        );
      }
    }
  }


}
