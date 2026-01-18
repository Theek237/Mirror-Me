import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wardrobe_item.dart';
import '../../domain/usecases/watch_wardrobe_items.dart';
import 'wardrobe_event.dart';
import 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  WardrobeBloc({required WatchWardrobeItems watchWardrobeItems})
    : _watchWardrobeItems = watchWardrobeItems,
      super(WardrobeState.initial()) {
    on<WardrobeStarted>(_onStarted);
    on<WardrobeItemsUpdated>(_onItemsUpdated);
    on<WardrobeCategorySelected>(_onCategorySelected);
    on<WardrobeFailed>(_onFailed);
  }

  final WatchWardrobeItems _watchWardrobeItems;
  StreamSubscription<List<WardrobeItem>>? _subscription;

  Future<void> _onStarted(
    WardrobeStarted event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(state.copyWith(status: WardrobeStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchWardrobeItems(event.uid).listen(
      (items) => add(WardrobeItemsUpdated(items: items)),
      onError: (error) => add(WardrobeFailed(message: error.toString())),
    );
  }

  void _onItemsUpdated(
    WardrobeItemsUpdated event,
    Emitter<WardrobeState> emit,
  ) {
    final items = event.items;
    final filtered = _filterItems(items, state.selectedCategory);
    final status = filtered.isEmpty
        ? WardrobeStatus.empty
        : WardrobeStatus.success;
    emit(
      state.copyWith(
        status: status,
        items: items,
        filteredItems: filtered,
        errorMessage: null,
      ),
    );
  }

  void _onCategorySelected(
    WardrobeCategorySelected event,
    Emitter<WardrobeState> emit,
  ) {
    final filtered = _filterItems(state.items, event.category);
    final status = filtered.isEmpty
        ? WardrobeStatus.empty
        : WardrobeStatus.success;
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredItems: filtered,
        status: status,
      ),
    );
  }

  void _onFailed(WardrobeFailed event, Emitter<WardrobeState> emit) {
    emit(
      state.copyWith(
        status: WardrobeStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  List<WardrobeItem> _filterItems(List<WardrobeItem> items, String category) {
    if (category == 'All') return items;
    return items.where((item) => item.category == category).toList();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
