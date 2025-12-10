import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:mm/features/wardrobe/domain/repositories/wardrobe_repository.dart';
part 'wardrobe_event.dart';
part 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  final WardrobeRepository repository;
  
  WardrobeBloc({required this.repository}) : super(WardrobeInitialState()) {
    on<WardrobeLoadWardrobeItemsEvent>((event, emit) async{
      emit(WardrobeLoadingState());
      final result = await repository.getClothingItems(event.userId);
      result.fold(
        (failure) => emit(WardrobeErrorState(message: failure.toString())),
        (clothingItems) => emit(WardrobeLoadedState(clothingItems: clothingItems)),
      );
    });

    on<WardrobeAddClothingItemEvent>((event, emit) async{
      emit(WardrobeLoadingState());
      final result = await repository.addClothingItem(event.userId, event.name, event.category, event.imageFile);
      await result.fold(
        (failure) async => emit(WardrobeErrorState(message: failure.toString())),
        (_) async {
          final loadResult = await repository.getClothingItems(event.userId);
          loadResult.fold(
            (failure) => emit(WardrobeErrorState(message: failure.toString())),
            (clothingItems) => emit(WardrobeLoadedState(clothingItems: clothingItems)),
          );
        },
      );
    });

    on<WardrobeDeleteClothingItemEvent>((event, emit) async{
      emit(WardrobeLoadingState());
      final result = await repository.deleteClothingItem(event.userId, event.itemId);
      await result.fold(
        (failure) async => emit(WardrobeErrorState(message: failure.toString())),
        (_) async {
          final loadResult = await repository.getClothingItems(event.userId);
          loadResult.fold(
            (failure) => emit(WardrobeErrorState(message: failure.toString())),
            (clothingItems) => emit(WardrobeLoadedState(clothingItems: clothingItems)),
          );
        },
      );
    });

    
  }
}
