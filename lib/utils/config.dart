import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // API Keys
  static String get googleTranslationApiKey =>
      dotenv.env['GOOGLE_TRANSLATION_API_KEY'] ?? '';

  // Environment
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isProductionMode =>
      environment == 'production';

  static bool get isDevelopmentMode =>
      environment == 'development';

  // API Base URLs
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.campussocial.example.com';

  // App Configuration
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING'] == 'true';

  static int get maxImageSize =>
      int.tryParse(dotenv.env['MAX_IMAGE_SIZE'] ?? '5242880') ?? 5242880; // 5MB default

  // Translation Settings
  static bool get enableTranslation =>
      dotenv.env['ENABLE_TRANSLATION'] == 'true';

  static int get translationTimeout =>
      int.tryParse(dotenv.env['TRANSLATION_TIMEOUT'] ?? '10000') ?? 10000; // 10 seconds default

  // NFC Settings
  static bool get enableNfcLogin =>
      dotenv.env['ENABLE_NFC_LOGIN'] == 'true';

  // Developer Options
  static bool get showDebugInfo =>
      dotenv.env['SHOW_DEBUG_INFO'] == 'true';

  // Feature Flags
  static bool get enableShakeFeature =>
      dotenv.env['ENABLE_SHAKE_FEATURE'] == 'true';

  static bool get enableImageUpload =>
      dotenv.env['ENABLE_IMAGE_UPLOAD'] == 'true';
}