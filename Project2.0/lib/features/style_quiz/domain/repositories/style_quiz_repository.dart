import '../entities/style_preferences.dart';

abstract class StyleQuizRepository {
  Future<StylePreferences> loadPreferences(String uid);
  Future<void> savePreferences(String uid, StylePreferences preferences);
}
