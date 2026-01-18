import '../../domain/entities/style_preferences.dart';
import '../../domain/repositories/style_quiz_repository.dart';
import '../datasources/style_quiz_remote_datasource.dart';

class StyleQuizRepositoryImpl implements StyleQuizRepository {
  StyleQuizRepositoryImpl(this._remote);

  final StyleQuizRemoteDataSource _remote;

  @override
  Future<StylePreferences> loadPreferences(String uid) =>
      _remote.loadPreferences(uid);

  @override
  Future<void> savePreferences(String uid, StylePreferences preferences) =>
      _remote.savePreferences(uid, preferences);
}
