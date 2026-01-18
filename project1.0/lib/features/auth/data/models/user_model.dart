import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.name,
    super.photoUrl,
  });

  factory UserModel.fromSupabaseUser(User user, {String? name}) {
    return UserModel(
      uid: user.id,
      email: user.email ?? '',
      name: name ?? user.userMetadata?['name'],
      photoUrl: user.userMetadata?['avatar_url'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': uid, 'email': email, 'name': name, 'photo_url': photoUrl};
  }
}
