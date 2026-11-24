class ApiConstants {
  ApiConstants._();

  // For Android emulator use 10.0.2.2
  // For physical device use your computer's local IP
  // For web/Windows use localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}
