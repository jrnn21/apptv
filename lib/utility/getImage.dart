// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getImage(imageUrl) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String filename = imageUrl.split('/').last;
  String imagePath = '$tempPath/$filename';

  File imageFile = File(imagePath);
  if (await imageFile.exists()) {
    return imageFile;
  } else {
    await _downloadAndSaveImage(imageUrl, imagePath);
    return imageFile;
  }
}

Future<void> _downloadAndSaveImage(String url, String path) async {
  HttpClient httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  File file = File(path);
  await file.writeAsBytes(bytes);
}
