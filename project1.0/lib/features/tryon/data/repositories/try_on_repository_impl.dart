// import 'package:mm/core/errors/exception.dart';
// import 'package:mm/features/tryon/data/datasources/try_on_remote_data_source.dart';
// import 'package:mm/core/errors/failure.dart';
// import 'package:dartz/dartz.dart';
// import 'package:mm/features/tryon/domain/repositories/try_on_repository.dart';

// class TryOnRepositoryImpl implements TryOnRepository {
//   final TryOnRemoteDataSource remoteDataSource;

//   TryOnRepositoryImpl({required this.remoteDataSource});

//   @override
//   Future<Either<Failure, String>> generateImage(
//     String userId,
//     String userImage,
//     String clothImage,
//   ) async {
//     try {
//       final result = await remoteDataSource.generateImage(
//         userId,
//         userImage,
//         clothImage,
//       );
//       return Right(result.image);
//     } on ServerException {
//       return Left(ServerFailure('Server error'));
//     }
//   }
// }
