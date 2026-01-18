import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  const Recommendation({
    required this.title,
    required this.items,
    required this.tip,
  });

  final String title;
  final List<String> items;
  final String tip;

  @override
  List<Object?> get props => [title, items, tip];
}
