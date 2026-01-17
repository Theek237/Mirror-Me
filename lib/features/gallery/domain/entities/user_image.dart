import 'package:equatable/equatable.dart';

class UserImageEntity extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String poseName;
  final String? description;
  final DateTime createdAt;

  const UserImageEntity({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.poseName,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    poseName,
    description,
    createdAt,
  ];
}
