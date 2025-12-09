import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends UserEntity{
  const UserModel({
    required super.uid,
    required super.email,
    super.name,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseUser(User user){
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}