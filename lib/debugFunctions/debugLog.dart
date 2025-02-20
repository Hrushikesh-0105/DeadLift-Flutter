import 'package:flutter/foundation.dart';

void debugLog(String message, {String tag = 'DEBUG'}) {
  if (kDebugMode) {
    final timeStamp = DateTime.now().toIso8601String();
    print('[$timeStamp][$tag]: $message');
  }
}
