import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/style_preferences.dart';
import '../../domain/usecases/load_style_preferences.dart';
import '../../domain/usecases/save_style_preferences.dart';
import 'style_quiz_event.dart';
import 'style_quiz_state.dart';

class StyleQuizBloc extends Bloc<StyleQuizEvent, StyleQuizState> {
  StyleQuizBloc({
    required LoadStylePreferences loadStylePreferences,
    required SaveStylePreferences saveStylePreferences,
  }) : _loadStylePreferences = loadStylePreferences,
       _saveStylePreferences = saveStylePreferences,
       super(StyleQuizState.initial()) {
    on<StyleQuizStarted>(_onStarted);
    on<StyleSelected>(_onStyleSelected);
    on<OccasionSelected>(_onOccasionSelected);
    on<StyleQuizSaved>(_onSaved);
    on<StyleQuizMessageCleared>(_onMessageCleared);
  }

  final LoadStylePreferences _loadStylePreferences;
  final SaveStylePreferences _saveStylePreferences;

  Future<void> _onStarted(
    StyleQuizStarted event,
    Emitter<StyleQuizState> emit,
  ) async {
    emit(state.copyWith(status: StyleQuizStatus.loading, message: null));
    try {
      final preferences = await _loadStylePreferences(event.uid);
      emit(
        state.copyWith(
          status: StyleQuizStatus.idle,
          styles: preferences.styles.toSet(),
          occasions: preferences.occasions.toSet(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: StyleQuizStatus.failure, message: e.toString()),
      );
    }
  }

  void _onStyleSelected(StyleSelected event, Emitter<StyleQuizState> emit) {
    final updated = Set<String>.from(state.styles);
    if (event.selected) {
      updated.add(event.style);
    } else {
      updated.remove(event.style);
    }
    emit(state.copyWith(styles: updated));
  }

  void _onOccasionSelected(
    OccasionSelected event,
    Emitter<StyleQuizState> emit,
  ) {
    final updated = Set<String>.from(state.occasions);
    if (event.selected) {
      updated.add(event.occasion);
    } else {
      updated.remove(event.occasion);
    }
    emit(state.copyWith(occasions: updated));
  }

  Future<void> _onSaved(
    StyleQuizSaved event,
    Emitter<StyleQuizState> emit,
  ) async {
    emit(state.copyWith(status: StyleQuizStatus.saving, message: null));
    try {
      final preferences = StylePreferences(
        styles: state.styles.toList(),
        occasions: state.occasions.toList(),
      );
      await _saveStylePreferences(event.uid, preferences);
      emit(
        state.copyWith(
          status: StyleQuizStatus.success,
          message: 'Style preferences saved.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: StyleQuizStatus.failure, message: e.toString()),
      );
    }
  }

  void _onMessageCleared(
    StyleQuizMessageCleared event,
    Emitter<StyleQuizState> emit,
  ) {
    emit(state.copyWith(message: null));
  }
}
