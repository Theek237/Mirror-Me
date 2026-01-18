import 'package:equatable/equatable.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

class CollectionsStarted extends CollectionsEvent {
  const CollectionsStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class CollectionCreateRequested extends CollectionsEvent {
  const CollectionCreateRequested({required this.uid, required this.name});

  final String uid;
  final String name;

  @override
  List<Object?> get props => [uid, name];
}

class CollectionsMessageCleared extends CollectionsEvent {
  const CollectionsMessageCleared();
}
