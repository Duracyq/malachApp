import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

Future<File?> pickAndShrinkPhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
  if (pickedFile == null) return null;

  File file = File(pickedFile.path);
  final int fileSize = await file.length();
  
  // Ensure all images are saved as JPEG
  final String newPath = file.path.replaceAll(RegExp(r'\.(\w+)$'), '.jpg');
  file = File(newPath);

  if (fileSize > 5 * 1024 * 1024) { // If file is larger than 5MB
    final img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) return null; // Check if image decoding was successful

    // Resize maintaining the aspect ratio
    const int targetWidth = 800; // Set this to the desired width
    final double aspectRatio = image.width / image.height;
    final img.Image resizedImage = img.copyResize(image, width: targetWidth, height: (targetWidth / aspectRatio).round());
    
    // Write the resized image to newPath, ensure it's a JPEG
    await File(newPath).writeAsBytes(img.encodeJpg(resizedImage, quality: 85)); // Quality can be adjusted for further optimization
    return File(newPath);
  } else {
    // Convert to JPEG if not already
    if (!file.path.endsWith('.jpg')) {
      final img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image != null) {
        await file.writeAsBytes(img.encodeJpg(image, quality: 85)); // Adjust quality as needed
      }
    }
    return file;
  }
}

