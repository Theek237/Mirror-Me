import 'package:equatable/equatable.dart';

class TryOnResult extends Equatable {
  final String id;
  final String userId;
  final String poseImageUrl;
  final String clothingImageUrl;
  final String resultImageUrl;
  final String? prompt;
  final DateTime createdAt;

  const TryOnResult({
    required this.id,
    required this.userId,
    required this.poseImageUrl,
    required this.clothingImageUrl,
    required this.resultImageUrl,
    this.prompt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    poseImageUrl,
    clothingImageUrl,
    resultImageUrl,
    prompt,
    createdAt,
  ];
}
