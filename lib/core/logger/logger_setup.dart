import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

void setupLogging() {
  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;

  Logger.root.onRecord.listen((record) {
    final message =
        '[${record.level.name}] ${record.loggerName}: ${record.message}';

    if (record.error != null) {
      log(message, error: record.error, stackTrace: record.stackTrace);
    } else {
      log(message);
    }
  });
}
