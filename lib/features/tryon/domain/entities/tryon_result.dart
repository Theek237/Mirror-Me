import 'package:equatable/equatable.dart';

class TryOnResult extends Equatable {
  final String id;
  final String userId;
  final String poseImageUrl;
  final String clothingImageUrl;
  final String resultImageUrl;
  final String? prompt;
  final bool isFavorite;
  final DateTime createdAt;

  const TryOnResult({
    required this.id,
    required this.userId,
    required this.poseImageUrl,
    required this.clothingImageUrl,
    required this.resultImageUrl,
    this.prompt,
    this.isFavorite = false,
    required this.createdAt,
  });

  TryOnResult copyWith({
    String? id,
    String? userId,
    String? poseImageUrl,
    String? clothingImageUrl,
    String? resultImageUrl,
    String? prompt,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return TryOnResult(
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

  @override
  List<Object?> get props => [
    id,
    userId,
    poseImageUrl,
    clothingImageUrl,
    resultImageUrl,
    prompt,
    isFavorite,
    createdAt,
  ];
}
