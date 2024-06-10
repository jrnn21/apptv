import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<File?> getCachedImage(String imageUrl) async {
  try {
    FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(imageUrl);
    if (fileInfo != null) {
      return fileInfo.file;
    } else {
      return null;
    }
  } catch (e) {
    // print('Error getting cached image: $e');
    return null;
  }
}

Future<File?> saveImageToCache(String imageUrl) async {
  try {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    File file = await cacheManager.getSingleFile(imageUrl);
    return file;
  } catch (e) {
    // print('Error saving image to cache: $e');
    return null;
  }
}
