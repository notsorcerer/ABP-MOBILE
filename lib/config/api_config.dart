class ApiConfig {
  // Untuk Android Emulator: 'http://10.0.2.2:8000'
  // Untuk HP fisik (1 jaringan): 'http://192.168.x.x:8000'
  // Untuk iOS Simulator / Web: 'http://localhost:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String apiPrefix = '/api/';
  static const Duration timeout = Duration(seconds: 30);
}
