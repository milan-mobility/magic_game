import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager {
  AppImageCacheManager._();

  static const String cacheKey = 'app_image_cache';

  static final CacheManager instance = CacheManager(
    Config(
      cacheKey,

      // Image can remain cached for 15 days without being used.
      stalePeriod: const Duration(days: 15),

      // Maximum number of cached image files.
      maxNrOfCacheObjects: 500,
    ),
  );

  static Future<void> clearCache() async {
    await instance.emptyCache();
  }

  static Future<void> removeImage(String imageUrl) async {
    await instance.removeFile(imageUrl);
  }
}
