/// Utility class for resolving paths in different usage contexts.
/// 
/// This class handles path resolution for both standalone usage and when
/// used as a plugin dependency from other projects.
library;

import 'dart:io';
import 'package:path/path.dart' as p;

/// Resolves paths for different usage contexts (standalone vs plugin).
class PathResolver {
  /// Gets the current working directory (the project using inno_bundle)
  static String get workingDirectory => Directory.current.path;
  
  /// Gets a temporary directory specific to the current build
  static String getBuildTempDirectory(String appName) {
    final buildId = DateTime.now().millisecondsSinceEpoch;
    return p.join(
      Directory.systemTemp.path,
      'inno_bundle_${buildId}_${_sanitizeAppName(appName)}'
    );
  }
  
  /// Gets the output directory for the installer
  static String getInstallerOutputDirectory(String buildType) {
    return p.join(
      workingDirectory,
      'build',
      'windows',
      'x64',
      'installer',
      buildType
    );
  }
  
  /// Gets the app build directory
  static String getAppBuildDirectory(String buildType) {
    return p.join(
      workingDirectory,
      'build',
      'windows',
      'x64',
      'runner',
      buildType
    );
  }
  
  /// Resolves a relative path from the working directory
  static String resolveFromWorkingDirectory(String relativePath) {
    if (p.isAbsolute(relativePath)) {
      return relativePath;
    }
    return p.join(workingDirectory, relativePath);
  }
  
  /// Checks if a file exists relative to the working directory
  static bool fileExistsInWorkingDirectory(String relativePath) {
    final absolutePath = resolveFromWorkingDirectory(relativePath);
    return File(absolutePath).existsSync();
  }
  
  /// Gets a cache directory for persistent data
  static String getCacheDirectory(String subDir) {
    return p.join(
      Directory.systemTemp.path,
      'inno_bundle_cache',
      subDir
    );
  }
  
  /// Sanitizes app name for use in file paths
  static String _sanitizeAppName(String appName) {
    return appName
        .replaceAll(RegExp(r'[^\w\-_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase();
  }
  
  /// Creates a directory if it doesn't exist
  static void ensureDirectoryExists(String path) {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
  
  /// Gets the relative path from working directory to a file
  static String getRelativePathFromWorkingDirectory(String absolutePath) {
    return p.relative(absolutePath, from: workingDirectory);
  }
}