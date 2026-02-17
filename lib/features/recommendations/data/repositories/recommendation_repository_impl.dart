import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/exception.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/recommendations/data/datasources/recommendation_remote_data_source.dart';
import 'package:mm/features/recommendations/data/datasources/recommendation_supabase_data_source.dart';
import 'package:mm/features/recommendations/domain/entities/recommendation.dart';
import 'package:mm/features/recommendations/domain/repositories/recommendation_repository.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;
  final RecommendationSupabaseDataSource supabaseDataSource;

  RecommendationRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseDataSource,
  });

  @override
  Future<Either<Failure, String>> generateRecommendation({
    required Uint8List imageBytes,
    String? customPrompt,
  }) async {
    try {
      final result = await remoteDataSource.generateRecommendation(
        imageBytes: imageBytes,
        customPrompt: customPrompt,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to generate recommendation'),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Recommendation>> saveRecommendation({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  }) async {
    try {
      final result = await supabaseDataSource.saveRecommendation(
        userId: userId,
        imageUrl: imageUrl,
        recommendationText: recommendationText,
        imageSource: imageSource,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to save recommendation'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Recommendation>>> getRecommendations(
    String userId,
  ) async {
    try {
      final result = await supabaseDataSource.getRecommendations(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get recommendations'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecommendation(String id) async {
    try {
      await supabaseDataSource.deleteRecommendation(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to delete recommendation'),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
