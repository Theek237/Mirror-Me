import '../entities/style_preferences.dart';
import '../repositories/style_quiz_repository.dart';

class LoadStylePreferences {
  const LoadStylePreferences(this._repository);

  final StyleQuizRepository _repository;

  Future<StylePreferences> call(String uid) {
    return _repository.loadPreferences(uid);
  }
}
