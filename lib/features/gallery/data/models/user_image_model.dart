import 'package:mm/features/gallery/domain/entities/user_image.dart';

class UserImageModel extends UserImageEntity {
  const UserImageModel({
    required super.id,
    required super.userId,
    required super.imageUrl,
    required super.poseName,
    super.description,
    required super.createdAt,
  });

  factory UserImageModel.fromJson(Map<String, dynamic> json) {
    return UserImageModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      poseName: json['pose_name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'pose_name': poseName,
      'description': description,
    };
  }
}
