class AppConfig {
  // ═══════════════════════════════════════════════════════════════════════════
  // GEMINI API CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  // Gemini API Key - Set this before running the app
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Check if API key is configured
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;

  // Fallback for development - you can set this directly during development
  // IMPORTANT: Never commit actual API keys to version control
  static String getGeminiApiKey() {
    if (geminiApiKey.isNotEmpty) {
      return geminiApiKey;
    }
    // Development fallback - TODO: Remove before production
    return 'AIzaSyDDZspZHezsmv19Wdq_IIcU3_vgFnl4inY';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPABASE CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  // Supabase Project URL
  // Get this from your Supabase project settings: Settings > API > Project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  // Supabase Anonymous Key
  // Get this from your Supabase project settings: Settings > API > anon public key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Check if Supabase is configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Development fallback for Supabase
  static String getSupabaseUrl() {
    if (supabaseUrl.isNotEmpty) {
      return supabaseUrl;
    }
    // Development fallback
    return 'https://zdijdwblemdtxpykfaxo.supabase.co';
  }

  static String getSupabaseAnonKey() {
    if (supabaseAnonKey.isNotEmpty) {
      return supabaseAnonKey;
    }
    // Development fallback
    return 'sb_publishable_w6DhxGZ4EvkeyqyTW8H5xw_U8SuWMip';
  }

  // Supabase Storage Bucket Names
  static const String wardrobeBucket = 'wardrobe';
  static const String tryonBucket = 'tryons';
  static const String profileBucket = 'profiles';
}
