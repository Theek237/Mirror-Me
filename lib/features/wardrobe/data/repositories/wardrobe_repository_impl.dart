import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:mm/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class WardrobeRepositoryImpl implements WardrobeRepository{
  final WardrobeRemoteDataSource remoteDataSource;

  WardrobeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> addClothingItem(String userId, String name, String category, File imageFile) async {
    try{
      await remoteDataSource.addClothingItem(userId, name, category, imageFile);
      return Right(null);
    } catch (e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClothingItem(String userId, String itemId) async {
    try{
      await remoteDataSource.deleteClothingItem(userId, itemId);
      return Right(null);
    } catch (e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClothingItemModel>>> getClothingItems(String userId) async{
    try{
      final items = await remoteDataSource.getClothingItems(userId);
      return Right(items);
    } catch (e){
      return Left(ServerFailure(e.toString()));
    }
  }
}