import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/watch_collections.dart';
import 'collections_event.dart';
import 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc({
    required WatchCollections watchCollections,
    required CreateCollection createCollection,
  }) : _watchCollections = watchCollections,
       _createCollection = createCollection,
       super(CollectionsState.initial()) {
    on<CollectionsStarted>(_onStarted);
    on<CollectionCreateRequested>(_onCreateRequested);
    on<CollectionsMessageCleared>(_onMessageCleared);
  }

  final WatchCollections _watchCollections;
  final CreateCollection _createCollection;
  StreamSubscription<List>? _subscription;

  Future<void> _onStarted(
    CollectionsStarted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.loading, message: null));
    await _subscription?.cancel();
    _subscription = _watchCollections(event.uid).listen(
      (items) {
        emit(
          state.copyWith(status: CollectionsStatus.idle, collections: items),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: CollectionsStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onCreateRequested(
    CollectionCreateRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.saving, message: null));
    try {
      await _createCollection(uid: event.uid, name: event.name);
      emit(state.copyWith(status: CollectionsStatus.idle));
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionsStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  void _onMessageCleared(
    CollectionsMessageCleared event,
    Emitter<CollectionsState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
