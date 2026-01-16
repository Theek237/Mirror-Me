import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:mm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mm/features/auth/data/reoisitories/auth_repository_impl.dart';
import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';
import 'package:mm/features/auth/domain/usecases/get_currentuser_usecase.dart';
import 'package:mm/features/auth/domain/usecases/login_usecase.dart';
import 'package:mm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mm/features/auth/domain/usecases/register_usecase.dart';
import 'package:mm/features/auth/presentation/bloc/auth%20bloc/auth_bloc.dart';
import 'package:mm/features/tryon/data/datasources/try_on_remote_data_source.dart';
import 'package:mm/features/tryon/data/repositories/try_on_repository_impl.dart';
import 'package:mm/features/tryon/domain/repositories/try_on_repository.dart';
import 'package:mm/features/tryon/presentation/bloc/try_on_bloc.dart';
import 'package:mm/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:mm/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:mm/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe%20bloc/wardrobe_bloc.dart';

//Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //Auth Feature
  //BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUsecase: sl(),
      logoutUsecase: sl(),
      getCurrentuserUsecase: sl(),
      registerUsecase: sl(),
    ),
  );

  //Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUsecase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentuserUsecase(repository: sl()));
  //Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      // googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  //2. External (Firebase)
  final firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  // final googleSignIn = GoogleSignIn();

  sl.registerLazySingleton(() => firebaseAuth);
  sl.registerLazySingleton(() => fireStore);
  // sl.registerLazySingleton(() => googleSignIn);

  //----------------------------------------------------//
  //Wardrobe Feature
  //BLoC
  sl.registerFactory(() => WardrobeBloc(repository: sl()));

  //Repository
  sl.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(remoteDataSource: sl()),
  );

  //Data Source
  sl.registerLazySingleton<WardrobeRemoteDataSource>(
    () => WardrobeRemoteDataSourceImpl(firestore: sl()),
  );

  //----------------------------------------------------//
  //TryOn Feature
  //BLoC
  // sl.registerFactory(() => TryOnBloc(tryOnRepository: sl()));

  // //Repository
  // sl.registerLazySingleton<TryOnRepository>(
  //   () => TryOnRepositoryImpl(remoteDataSource: sl()),
  // );

  // //Data Source
  // sl.registerLazySingleton<TryOnRemoteDataSource>(
  //   () => TryOnRemoteDataSourceImpl(),
  // );
}
