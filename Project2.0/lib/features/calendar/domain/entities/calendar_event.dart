import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
  });

  final String id;
  final String title;
  final String date;

  @override
  List<Object?> get props => [id, title, date];
}
