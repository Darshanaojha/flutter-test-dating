import 'package:logging/logging.dart';

/// Sets up and configures the application logger
Logger setup_logger() {
  // Configure logging
  Logger.root.level = Level.INFO; // Set the default logging level
  Logger.root.onRecord.listen((record) {
    // Print log messages to the console
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    
    // You can add additional logging destinations here if needed
    // For example: file logging, remote logging, etc.
  });

  // Return a logger instance for the application
  return Logger('DatingApp');
}
