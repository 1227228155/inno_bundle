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
      'https://raw.githubusercontent.com/kira-96/Inno-Setup-Chinese-Simplified-Translation/main/ChineseSimplified.isl';
  
  /// URL for the traditional Chinese language file  
  static const String _traditionalChineseUrl = 
      'https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/Unofficial/ChineseTraditional.isl';

  /// Downloads the Chinese language files to a temporary directory.
  /// 
  /// Returns a map containing the paths to the downloaded files:
  /// - 'chineseSimplified': Path to ChineseSimplified.isl
  /// - 'chineseTraditional': Path to ChineseTraditional.isl
  static Future<Map<String, String>> downloadChineseLanguageFiles(String tempDir) async {
    final directory = Directory(tempDir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final simplifiedPath = p.join(tempDir, 'ChineseSimplified.isl');
    final traditionalPath = p.join(tempDir, 'ChineseTraditional.isl');

    // Download simplified Chinese if not exists
    if (!File(simplifiedPath).existsSync()) {
      CliLogger.info('Downloading Chinese Simplified language file...');
      await _downloadFile(_simplifiedChineseUrl, simplifiedPath);
      CliLogger.success('Chinese Simplified language file downloaded');
    }

    // Download traditional Chinese if not exists
    if (!File(traditionalPath).existsSync()) {
      CliLogger.info('Downloading Chinese Traditional language file...');
      await _downloadFile(_traditionalChineseUrl, traditionalPath);
      CliLogger.success('Chinese Traditional language file downloaded');
    }

    return {
      'chineseSimplified': simplifiedPath,
      'chineseTraditional': traditionalPath,
    };
  }

  /// Downloads a file from the given URL to the specified path.
  static Future<void> _downloadFile(String url, String filePath) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      CliLogger.exitError('Failed to download Chinese language file from $url: $e');
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
}