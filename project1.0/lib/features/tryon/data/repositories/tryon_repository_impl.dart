import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/exception.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/data/datasources/gemini_remote_data_source.dart';
import 'package:mm/features/tryon/data/datasources/tryon_remote_data_source.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class TryOnRepositoryImpl implements TryOnRepository {
  final GeminiRemoteDataSource geminiDataSource;
  final TryOnRemoteDataSource tryOnDataSource;

  TryOnRepositoryImpl({
    required this.geminiDataSource,
    required this.tryOnDataSource,
  });

  @override
  Future<Either<Failure, Uint8List>> generateTryOn({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  }) async {
    try {
      final result = await geminiDataSource.generateTryOnImage(
        poseImageBytes: poseImageBytes,
        clothingImageBytes: clothingImageBytes,
        customPrompt: customPrompt,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to generate try-on'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TryOnResult>> saveTryOnResult({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required Uint8List resultImageBytes,
    String? prompt,
  }) async {
    try {
      final result = await tryOnDataSource.saveTryOnResult(
        userId: userId,
        poseImageUrl: poseImageUrl,
        clothingImageUrl: clothingImageUrl,
        resultImageBytes: resultImageBytes,
        prompt: prompt,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to save result'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TryOnResult>>> getTryOnResults(
    String userId,
  ) async {
    try {
      final results = await tryOnDataSource.getTryOnResults(userId);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch results'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTryOnResult(String resultId) async {
    try {
      await tryOnDataSource.deleteTryOnResult(resultId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete result'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TryOnResult>>> getFavoriteTryOnResults(
    String userId,
  ) async {
    try {
      final results = await tryOnDataSource.getFavoriteTryOnResults(userId);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch favorites'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TryOnResult>> toggleFavorite(
    String resultId,
    bool isFavorite,
  ) async {
    try {
      final result = await tryOnDataSource.toggleFavorite(resultId, isFavorite);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to toggle favorite'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
