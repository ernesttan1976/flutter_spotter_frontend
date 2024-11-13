class Logger {
  void error(String message, [dynamic error]) {
    print('ERROR: $message');
    if (error != null) {
      print('Details: $error');
    }
  }

  void info(String message) {
    print('INFO: $message');
  }

  void warning(String message) {
    print('WARNING: $message');
  }
}