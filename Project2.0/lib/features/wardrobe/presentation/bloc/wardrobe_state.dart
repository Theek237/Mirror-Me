import 'package:equatable/equatable.dart';

import '../../domain/entities/wardrobe_item.dart';

enum WardrobeStatus { initial, loading, success, empty, failure }

class WardrobeState extends Equatable {
  const WardrobeState({
    required this.status,
    required this.items,
    required this.filteredItems,
    required this.selectedCategory,
    required this.categories,
    this.errorMessage,
  });

  factory WardrobeState.initial() {
    return const WardrobeState(
      status: WardrobeStatus.initial,
      items: [],
      filteredItems: [],
      selectedCategory: 'All',
      categories: [
        'All',
        'Tops',
        'Bottoms',
        'Dresses',
        'Shoes',
        'Outerwear',
        'Accessories',
      ],
      errorMessage: null,
    );
  }

  final WardrobeStatus status;
  final List<WardrobeItem> items;
  final List<WardrobeItem> filteredItems;
  final String selectedCategory;
  final List<String> categories;
  final String? errorMessage;

  WardrobeState copyWith({
    WardrobeStatus? status,
    List<WardrobeItem>? items,
    List<WardrobeItem>? filteredItems,
    String? selectedCategory,
    List<String>? categories,
    String? errorMessage,
  }) {
    return WardrobeState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filteredItems,
    selectedCategory,
    categories,
    errorMessage,
  ];
}
