import 'package:equatable/equatable.dart';

class ClosetAnalytics extends Equatable {
  const ClosetAnalytics({
    required this.categoryCounts,
    required this.colorCounts,
  });

  final Map<String, int> categoryCounts;
  final Map<String, int> colorCounts;

  @override
  List<Object?> get props => [categoryCounts, colorCounts];
}
