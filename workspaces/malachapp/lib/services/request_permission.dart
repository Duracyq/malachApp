import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  var storageStatus = await Permission.storage.status;
  if (!storageStatus.isGranted) {
    if (await Permission.storage.shouldShowRequestRationale) {
      // Ideally show a dialog explaining the need for this permission.
    }
    storageStatus = await Permission.storage.request();
  }
  if (await Permission.storage.isPermanentlyDenied || await Permission.manageExternalStorage.isPermanentlyDenied) {
    openAppSettings(); // Directs the user to app settings.
  }

  if (storageStatus.isGranted && Platform.isAndroid && int.parse(Platform.operatingSystemVersion.split(" ").first) >= 30) {
    var manageStorageStatus = await Permission.manageExternalStorage.status;
    if (!manageStorageStatus.isGranted) {
      if (await Permission.manageExternalStorage.shouldShowRequestRationale) {
        // Ideally show a dialog here.
      }
      manageStorageStatus = await Permission.manageExternalStorage.request();
    }
    return manageStorageStatus.isGranted;
  }

  return storageStatus.isGranted;
}
