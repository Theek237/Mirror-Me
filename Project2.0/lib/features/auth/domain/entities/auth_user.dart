import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
