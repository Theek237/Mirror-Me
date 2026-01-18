import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, email, name, photoUrl];
}
