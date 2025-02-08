import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl;
  final dio = Dio();

  ImagePreview({Key? key, required this.imageUrl}) : super(key: key);

  Future<void> _saveImage() async {
    try {
      bool permissionGranted = false;
      
      if (Platform.isAndroid) {
        if (await Permission.mediaLibrary.request().isGranted && 
            await Permission.photos.request().isGranted) {
          permissionGranted = true;
        }
      } else {
        permissionGranted = await Permission.storage.request().isGranted;
      }

      if (!permissionGranted) {
        Get.snackbar(
          'Permission Required',
          'Please enable storage permission from settings to download images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          mainButton: TextButton(
            child: Text('Open Settings', style: TextStyle(color: Colors.white)),
            onPressed: () => openAppSettings(),
          ),
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // Save to Pictures folder to be visible in gallery
      final directory = Directory('/storage/emulated/0/Pictures/ChitChat');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = "IMG_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final savePath = "${directory.path}/$fileName";

      await dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("${(received / total * 100).toStringAsFixed(0)}%");
          }
        }
      );

      // Use MediaScanner intent to make the image visible
      try {
        await dio.post('content://media/none/none/scanFile', 
          data: {'path': savePath},
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );
      } catch (e) {
        print('Media scanning failed but file was saved: $e');
      }

      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Success',
        'Image saved to Pictures/ChitChat folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to save image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error saving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _saveImage,
            ),
          ],
        ),
        body: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
        ),
      );
}
