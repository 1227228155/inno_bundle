#!/usr/bin/env dart

import 'package:inno_bundle/utils/debug_helper.dart';
import 'package:inno_bundle/utils/cli_logger.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('info', abbr: 'i', help: 'Show debug information')
    ..addFlag('clear', abbr: 'c', help: 'Clear all cache and build files')
    ..addFlag('help', abbr: 'h', help: 'Show help information');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _showHelp(parser);
      return;
    }

    if (results['info'] as bool) {
      DebugHelper.printDebugInfo();
      return;
    }

    if (results['clear'] as bool) {
      DebugHelper.clearAllCache();
      return;
    }

    // Default: show info
    DebugHelper.printDebugInfo();
    
  } catch (e) {
    CliLogger.exitError('Error: $e');
  }
}

void _showHelp(ArgParser parser) {
  print('''
Inno Bundle Debug Tool

Usage: dart run inno_bundle:debug [options]

Options:
${parser.usage}

Examples:
  dart run inno_bundle:debug --info     Show debug information
  dart run inno_bundle:debug --clear    Clear all cache and build files
  dart run inno_bundle:debug --help     Show this help message

This tool helps diagnose and resolve issues with inno_bundle, especially
related to Chinese language support and plugin usage scenarios.
''');
}