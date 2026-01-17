part of 'wardrobe_bloc.dart';

sealed class WardrobeState extends Equatable {
  const WardrobeState();

  @override
  List<Object> get props => [];
}

class WardrobeInitialState extends WardrobeState {}

class WardrobeLoadingState extends WardrobeState {}

class WardrobeLoadedState extends WardrobeState {
  final List<ClothingItemModel> clothingItems;

  const WardrobeLoadedState({required this.clothingItems});

  @override
  List<Object> get props => [clothingItems];
}

class WardrobeErrorState extends WardrobeState {
  final String message;

  const WardrobeErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
