import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String baseUrl = 'YOUR_BASE_URL';
  
  // Load API key from .env file
  static String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';
  
  // Initialize environment variables
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
  
  // Add other configuration variables as needed
} 