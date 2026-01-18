import 'package:equatable/equatable.dart';

import '../../domain/entities/wardrobe_item.dart';

abstract class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object?> get props => [];
}

class WardrobeStarted extends WardrobeEvent {
  const WardrobeStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class WardrobeItemsUpdated extends WardrobeEvent {
  const WardrobeItemsUpdated({required this.items});

  final List<WardrobeItem> items;

  @override
  List<Object?> get props => [items];
}

class WardrobeCategorySelected extends WardrobeEvent {
  const WardrobeCategorySelected({required this.category});

  final String category;

  @override
  List<Object?> get props => [category];
}

class WardrobeFailed extends WardrobeEvent {
  const WardrobeFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
