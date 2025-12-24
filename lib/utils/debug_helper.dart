/// Debug helper utilities for troubleshooting inno_bundle issues.
library;

import 'dart:io';
import 'package:inno_bundle/models/language.dart';
import 'package:inno_bundle/utils/cli_logger.dart';
import 'package:inno_bundle/utils/chinese_language_downloader.dart';
import 'package:path/path.dart' as p;

/// Helper class for debugging inno_bundle issues.
class DebugHelper {
  /// Prints comprehensive debug information about the current setup.
  static void printDebugInfo() {
    CliLogger.info('=== Inno Bundle Debug Information ===');
    
    // Version info
    CliLogger.info('Working Directory: ${Directory.current.path}');
    
    // Language configuration
    CliLogger.info('\nLanguage Configuration:');
    CliLogger.info('  Chinese Simplified: ${Language.chineseSimplified.file}');
    CliLogger.info('  Chinese Traditional: ${Language.chineseTraditional.file}');
    CliLogger.info('  Requires Special Handling: ${Language.chineseSimplified.requiresSpecialHandling}');
    
    // Sample Inno entries
    CliLogger.info('\nSample Inno Entries:');
    CliLogger.info('  English: ${Language.english.innoEntry}');
    CliLogger.info('  Chinese Simplified (standard): ${Language.chineseSimplified.innoEntry}');
    
    final samplePath = p.join(Directory.systemTemp.path, 'sample', 'ChineseSimplified.isl');
    CliLogger.info('  Chinese Simplified (custom): ${Language.chineseSimplified.innoEntryWithPath(samplePath)}');
    
    // Cache info
    final cacheSize = ChineseLanguageDownloader.getCacheSize();
    CliLogger.info('\nCache Information:');
    CliLogger.info('  Cache Size: ${(cacheSize / 1024).toStringAsFixed(2)} KB');
    
    CliLogger.info('=====================================');
  }
  
  /// Clears all build-related cache and temporary files.
  static void clearAllCache() {
    CliLogger.info('Clearing all cache and temporary files...');
    
    // Clear Chinese language cache
    ChineseLanguageDownloader.clearCache();
    
    // Clear build directory
    final buildDir = Directory(p.join(Directory.current.path, 'build'));
    if (buildDir.existsSync()) {
      try {
        buildDir.deleteSync(recursive: true);
        CliLogger.success('Build directory cleared');
      } catch (e) {
        CliLogger.warning('Failed to clear build directory: $e');
      }
    }
    
    // Clear temp directories related to inno_bundle
    final tempDir = Directory.systemTemp;
    try {
      final entries = tempDir.listSync();
      for (final entry in entries) {
        if (entry is Directory && entry.path.contains('inno_bundle')) {
          try {
            entry.deleteSync(recursive: true);
            CliLogger.info('Cleared temp directory: ${p.basename(entry.path)}');
          } catch (e) {
            // Ignore errors for temp directories that might be in use
          }
        }
      }
    } catch (e) {
      CliLogger.warning('Failed to clear some temp directories: $e');
    }
    
    CliLogger.success('Cache clearing completed');
  }
  
  /// Validates the current language configuration.
  static bool validateLanguageConfig(List<Language> languages) {
    CliLogger.info('Validating language configuration...');
    
    bool isValid = true;
    for (final language in languages) {
      if (language.requiresSpecialHandling) {
        CliLogger.info('  ${language.name}: Requires special handling (will be downloaded)');
      } else {
        CliLogger.info('  ${language.name}: Standard language file (${language.file})');
      }
    }
    
    final chineseLanguages = languages.where((l) => l.requiresSpecialHandling).toList();
    if (chineseLanguages.isNotEmpty) {
      CliLogger.info('Chinese languages detected: ${chineseLanguages.map((l) => l.name).join(', ')}');
      CliLogger.info('These will be automatically downloaded during build.');
    }
    
    return isValid;
  }
}