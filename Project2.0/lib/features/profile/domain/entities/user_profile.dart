import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.fullName,
    required this.email,
    this.photoUrl,
  });

  final String fullName;
  final String email;
  final String? photoUrl;

  @override
  List<Object?> get props => [fullName, email, photoUrl];
}
