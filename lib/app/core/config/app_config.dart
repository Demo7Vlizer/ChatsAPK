class AppConfig {
  static const String baseUrl = 'YOUR_BASE_URL';
  
  // Load API keys from environment variables
  static String get googleApiKey => const String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );
  
  // Add other configuration variables as needed
} 