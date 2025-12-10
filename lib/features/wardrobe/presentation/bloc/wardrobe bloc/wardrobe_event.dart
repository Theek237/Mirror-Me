// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'wardrobe_bloc.dart';

sealed class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object> get props => [];
}

class WardrobeLoadWardrobeItemsEvent extends WardrobeEvent {
  final String userId;
  const WardrobeLoadWardrobeItemsEvent({
    required this.userId,
  });
}

class WardrobeAddClothingItemEvent extends WardrobeEvent {
  final String userId;
  final String name;
  final String category;
  final File imageFile;
  const WardrobeAddClothingItemEvent({
    required this.userId,
    required this.name,
    required this.category,
    required this.imageFile,
  });
}

class WardrobeDeleteClothingItemEvent extends WardrobeEvent {
  final String userId;
  final String itemId;
  const WardrobeDeleteClothingItemEvent({
    required this.userId,
    required this.itemId,
  });
}
