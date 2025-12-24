/// Utility class for downloading Chinese language files for Inno Setup.
///
/// This class handles the automatic download of Chinese language files
/// (ChineseSimplified.isl and ChineseTraditional.isl) from reliable sources
/// when they are not available in the local Inno Setup installation.
library;

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:inno_bundle/utils/cli_logger.dart';

/// Downloads and manages Chinese language files for Inno Setup.
class ChineseLanguageDownloader {
  /// URL for the simplified Chinese language file
  static const String _simplifiedChineseUrl = 
      'https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/Unofficial/ChineseSimplified.isl';
  
  /// Fallback URL for the simplified Chinese language file
  static const String _simplifiedChineseFallbackUrl = 
      'https://raw.githubusercontent.com/kira-96/Inno-Setup-Chinese-Simplified-Translation/main/ChineseSimplified.isl';
  
  /// URL for the traditional Chinese language file  
  static const String _traditionalChineseUrl = 
      'https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/Unofficial/ChineseTraditional.isl';

  /// Cache directory for downloaded language files
  static String get _cacheDir => p.join(
    Directory.systemTemp.path,
    'inno_bundle_cache',
    'chinese_languages'
  );

  /// Downloads the Chinese language files to a temporary directory.
  /// 
  /// [tempDir] - The temporary directory to store downloaded files. If not provided,
  /// a default temporary directory will be created based on the current working directory.
  /// 
  /// Returns a map containing the paths to the downloaded files:
  /// - 'chineseSimplified': Path to ChineseSimplified.isl
  /// - 'chineseTraditional': Path to ChineseTraditional.isl
  static Future<Map<String, String>> downloadChineseLanguageFiles([String? tempDir]) async {
    // Use provided tempDir or create a default one
    final targetDir = tempDir ?? p.join(
      Directory.systemTemp.path, 
      'inno_bundle_${DateTime.now().millisecondsSinceEpoch}',
      'Languages'
    );
    
    final directory = Directory(targetDir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final simplifiedPath = p.join(targetDir, 'ChineseSimplified.isl');
    final traditionalPath = p.join(targetDir, 'ChineseTraditional.isl');

    // Try to use cached files first
    await _ensureCachedFiles();
    
    // Copy from cache or download if not available
    await _ensureLanguageFile(
      'ChineseSimplified.isl', 
      simplifiedPath, 
      _simplifiedChineseUrl, 
      _simplifiedChineseFallbackUrl
    );
    
    await _ensureLanguageFile(
      'ChineseTraditional.isl', 
      traditionalPath, 
      _traditionalChineseUrl, 
      null
    );

    return {
      'chineseSimplified': simplifiedPath,
      'chineseTraditional': traditionalPath,
    };
  }

  /// Ensures cached language files are available
  static Future<void> _ensureCachedFiles() async {
    final cacheDirectory = Directory(_cacheDir);
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync(recursive: true);
    }
  }

  /// Ensures a specific language file is available at the target path
  static Future<void> _ensureLanguageFile(
    String fileName, 
    String targetPath, 
    String primaryUrl, 
    String? fallbackUrl
  ) async {
    final cachedFilePath = p.join(_cacheDir, fileName);
    final cachedFile = File(cachedFilePath);
    final targetFile = File(targetPath);

    // If target already exists, we're done
    if (targetFile.existsSync()) {
      return;
    }

    // Try to copy from cache first
    if (cachedFile.existsSync()) {
      try {
        await cachedFile.copy(targetPath);
        CliLogger.info('Using cached $fileName');
        return;
      } catch (e) {
        CliLogger.warning('Failed to copy cached $fileName: $e');
      }
    }

    // Download to cache and then copy to target
    CliLogger.info('Downloading $fileName...');
    if (fallbackUrl != null) {
      await _downloadFileWithFallback(primaryUrl, fallbackUrl, cachedFilePath);
    } else {
      await _downloadFile(primaryUrl, cachedFilePath);
    }
    
    // Copy from cache to target
    await File(cachedFilePath).copy(targetPath);
    CliLogger.success('$fileName downloaded and cached');
  }

  /// Downloads a file from the given URL to the specified path with fallback support.
  static Future<void> _downloadFileWithFallback(String primaryUrl, String fallbackUrl, String filePath) async {
    try {
      await _downloadFile(primaryUrl, filePath);
    } catch (e) {
      CliLogger.warning('Primary download failed, trying fallback source...');
      try {
        await _downloadFile(fallbackUrl, filePath);
      } catch (fallbackError) {
        throw Exception('Both primary and fallback downloads failed. Primary: $e, Fallback: $fallbackError');
      }
    }
  }

  /// Downloads a file from the given URL to the specified path.
  static Future<void> _downloadFile(String url, String filePath) async {
    try {
      final client = http.Client();
      try {
        final response = await client.get(Uri.parse(url)).timeout(Duration(seconds: 30));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download file: HTTP ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      throw Exception('Failed to download file from $url: $e');
    }
  }

  /// Checks if Chinese language files exist in the Inno Setup installation directory.
  /// 
  /// Returns a map indicating which files are missing:
  /// - 'chineseSimplified': true if missing
  /// - 'chineseTraditional': true if missing
  static Map<String, bool> checkMissingChineseFiles() {
    // Try to find Inno Setup installation directory
    final possiblePaths = [
      r'C:\Program Files (x86)\Inno Setup 6\Languages',
      r'C:\Program Files\Inno Setup 6\Languages',
      'C:\\Users\\${Platform.environment['USERNAME'] ?? 'Default'}\\AppData\\Local\\Programs\\Inno Setup 6\\Languages',
    ];

    String? innoLanguagesDir;
    for (final path in possiblePaths) {
      final expandedPath = path.contains('\${Platform.environment[\'USERNAME\']') 
          ? path.replaceAll('\${Platform.environment[\'USERNAME\'] ?? \'Default\'}', 
              Platform.environment['USERNAME'] ?? 'Default')
          : path;
      if (Directory(expandedPath).existsSync()) {
        innoLanguagesDir = expandedPath;
        break;
      }
    }

    if (innoLanguagesDir == null) {
      // If we can't find Inno Setup, assume both files are missing
      return {
        'chineseSimplified': true,
        'chineseTraditional': true,
      };
    }

    final simplifiedExists = File(p.join(innoLanguagesDir, 'ChineseSimplified.isl')).existsSync();
    final traditionalExists = File(p.join(innoLanguagesDir, 'ChineseTraditional.isl')).existsSync();

    return {
      'chineseSimplified': !simplifiedExists,
      'chineseTraditional': !traditionalExists,
    };
  }

  /// Clears the cached Chinese language files
  static void clearCache() {
    final cacheDirectory = Directory(_cacheDir);
    if (cacheDirectory.existsSync()) {
      try {
        cacheDirectory.deleteSync(recursive: true);
        CliLogger.info('Chinese language file cache cleared');
      } catch (e) {
        CliLogger.warning('Failed to clear cache: $e');
      }
    }
  }

  /// Gets the size of the cached files in bytes
  static int getCacheSize() {
    final cacheDirectory = Directory(_cacheDir);
    if (!cacheDirectory.existsSync()) {
      return 0;
    }
    
    int totalSize = 0;
    try {
      final files = cacheDirectory.listSync(recursive: true);
      for (final file in files) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      }
    } catch (e) {
      CliLogger.warning('Failed to calculate cache size: $e');
    }
    
    return totalSize;
  }
}