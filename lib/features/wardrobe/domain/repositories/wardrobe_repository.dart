import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';

abstract class WardrobeRepository {
  Future<Either<Failure, List<ClothingItemModel>>> getClothingItems(
    String userId,
  );
  Future<Either<Failure, void>> addClothingItem(
    String userId,
    String name,
    String category,
    File imageFile,
  );
  Future<Either<Failure, void>> deleteClothingItem(
    String userId,
    String itemId,
  );
}
