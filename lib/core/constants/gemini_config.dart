/// Configuration for AI services
/// IMPORTANT: Replace with your actual API key from https://aistudio.google.com/apikey
///
/// For production, consider using:
/// - Environment variables
/// - flutter_dotenv package
/// - Secure storage
class GeminiConfig {
  /// Your Gemini API Key
  /// Get one at: https://aistudio.google.com/apikey
  static const String apiKey = 'AIzaSyCvc5SbvwG9ztU04LCDHS3u4m_wwnYmELY';

  /// The model to use for image generation (Virtual Try-On)
  /// Options:
  /// - 'gemini-2.0-flash-exp' - Fast, experimental (supports image gen)
  /// - 'gemini-2.5-flash-image' (Nano Banana) - Speed optimized
  /// - 'gemini-3-pro-image-preview' (Nano Banana Pro) - Best quality, 4K support
  static const String imageModel = 'gemini-3-pro-image-preview';

  /// The model to use for AI Recommendations (text-based)
  /// Options:
  /// - 'gemini-2.0-flash' - Fast, good for text
  /// - 'gemini-1.5-pro' - Most capable for text analysis
  /// - 'gemini-1.5-flash' - Fast and efficient
  static const String recommendationModel = 'gemini-2.0-flash';
}
