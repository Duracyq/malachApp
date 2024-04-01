import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

Future<File?> pickAndShrinkPhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile == null) return null;

  final File file = File(pickedFile.path);
  final int fileSize = await file.length();
  
  if (fileSize > 5 * 1024 * 1024) { // If file is larger than 5MB
    final img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) return null; // Check if image decoding was successful
    final img.Image resizedImage = img.copyResize(image, width: image.width ~/ 2);
    final String newPath = '${file.path}_resized.jpg';
    final File resizedFile = File(newPath);
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage));
    return resizedFile;
  } else {
    return file;
  }
}
