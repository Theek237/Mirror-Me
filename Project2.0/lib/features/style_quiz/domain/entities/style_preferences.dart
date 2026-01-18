import 'package:equatable/equatable.dart';

class StylePreferences extends Equatable {
  const StylePreferences({required this.styles, required this.occasions});

  final List<String> styles;
  final List<String> occasions;

  @override
  List<Object?> get props => [styles, occasions];
}
