import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    // Ambil konfigurasi batas level log dari env
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;

    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      DateTime now = DateTime.now();
      String timestamp = DateFormat('HH:mm:ss').format(now);
      String dateStamp = DateFormat('dd-MM-yyyy').format(now);

      String label = _getLabel(level);
      String color = _getColor(level);

      // Log ke terminal jika level sesuai konfigurasi
      if (configLevel == 3) {
        dev.log(message, name: source, time: now, level: level * 100);
        print('$color[$timestamp] [$label] ($source): $message\x1B[0m');
      }

      // Tulis ke file log
      await _logToFile(dateStamp, timestamp, label, source, message);
    } catch (e) {
      dev.log('Failed to write log: $e', name: 'LogHelper', level: 1000);
    }
  }

  static Future<void> _logToFile(
    String date,
    String time,
    String label,
    String source,
    String message,
  ) async {
    try {
      final Directory logDir = Directory('logs');
      try {
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
      } catch (e) {
        // Fallback or ignore if directory creation fails in restricted environments
        return;
      }

      final File logFile = File('${logDir.path}/$date.log');
      final String logEntry = '[$time] [$label] ($source): $message\n';

      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      dev.log('File Log Error: $e', name: 'LogHelper');
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return 'ERROR';
      case 2:
        return 'INFO';
      case 3:
        return 'DEBUG';
      default:
        return 'LOG';
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
    }
  }
}
