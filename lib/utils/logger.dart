import 'package:flutter/foundation.dart';

enum MyLogger {
  black("30"),
  red("31"),
  green("32"),
  yellow("33"),
  blue("34"),
  magenta("35"),
  cyan("36"),
  white("37");

  static const topLeftCorner = '┌';
  static const middleCorner = '├';
  static const verticalLine = '│';
  static const doubleDivider = '─';
  static const bottomLeftCorner = '└';

  final String code;
  const MyLogger(this.code);

  void log(String text, {bool hasBorder = false}) {
    if (kDebugMode) {
      // print('\x1B[${code}m$text\x1B[0m');

      final length = text.length > 160 ? 160 : text.length;
      if (hasBorder) {
        var doubleDividerLine = StringBuffer();
        for (var i = 0; i < length + 1; i++) {
          doubleDividerLine.write(doubleDivider);
        }

        final topBorder = '$topLeftCorner$doubleDividerLine';
        final bottomBorder = '$bottomLeftCorner$doubleDividerLine';

        print(topBorder);
        print('$verticalLine $text');
        print(bottomBorder);
      } else {
        print(text);
      }
    }
  }
}

void logDebug(dynamic message, {String? key, bool hasBorder = false}) {
  if (kDebugMode) {
    MyLogger.green.log('📔 Numerology: ${key != null ? 'key: ' : ''} ${message.toString()}', hasBorder: hasBorder);
  }
}

void logInfo(dynamic message, {String? key, bool hasBorder = false}) {
  if (kDebugMode) {
    MyLogger.white.log('📘 Numerology: ${key != null ? 'key: ' : ''} ${message.toString()}', hasBorder: hasBorder);
  }
}

void logWarning(dynamic message, {String? key, bool hasBorder = false}) {
  if (kDebugMode) {
    MyLogger.yellow.log('📙 Numerology: ${key != null ? 'key: ' : ''} ${message.toString()}', hasBorder: hasBorder);
  }
}

void logError(dynamic message, {String? key, bool hasBorder = true}) {
  if (kDebugMode) {
    MyLogger.red.log('📕 Numerology: ${key != null ? '$key: ' : ''} ${message.toString()}', hasBorder: hasBorder);
  }
}
