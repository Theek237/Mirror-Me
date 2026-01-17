import 'package:mm/features/tryon/domain/entities/tryon_result.dart';

class TryOnResultModel extends TryOnResult {
  const TryOnResultModel({
    required super.id,
    required super.userId,
    required super.poseImageUrl,
    required super.clothingImageUrl,
    required super.resultImageUrl,
    super.prompt,
    super.isFavorite = false,
    required super.createdAt,
  });

  factory TryOnResultModel.fromJson(Map<String, dynamic> json) {
    return TryOnResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      poseImageUrl: json['pose_image_url'] as String,
      clothingImageUrl: json['clothing_image_url'] as String,
      resultImageUrl: json['result_image_url'] as String,
      prompt: json['prompt'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pose_image_url': poseImageUrl,
      'clothing_image_url': clothingImageUrl,
      'result_image_url': resultImageUrl,
      'prompt': prompt,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a model for inserting into database (without id and created_at)
  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required String resultImageUrl,
    String? prompt,
    bool isFavorite = false,
  }) {
    return {
      'user_id': userId,
      'pose_image_url': poseImageUrl,
      'clothing_image_url': clothingImageUrl,
      'result_image_url': resultImageUrl,
      'prompt': prompt,
      'is_favorite': isFavorite,
    };
  }

  @override
  TryOnResultModel copyWith({
    String? id,
    String? userId,
    String? poseImageUrl,
    String? clothingImageUrl,
    String? resultImageUrl,
    String? prompt,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return TryOnResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      poseImageUrl: poseImageUrl ?? this.poseImageUrl,
      clothingImageUrl: clothingImageUrl ?? this.clothingImageUrl,
      resultImageUrl: resultImageUrl ?? this.resultImageUrl,
      prompt: prompt ?? this.prompt,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
