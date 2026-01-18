import '../entities/style_preferences.dart';
import '../repositories/style_quiz_repository.dart';

class SaveStylePreferences {
  const SaveStylePreferences(this._repository);

  final StyleQuizRepository _repository;

  Future<void> call(String uid, StylePreferences preferences) {
    return _repository.savePreferences(uid, preferences);
  }
}
