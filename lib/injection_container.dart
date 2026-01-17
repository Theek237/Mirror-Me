import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mm/features/auth/data/reoisitories/auth_repository_impl.dart';
import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';
import 'package:mm/features/auth/domain/usecases/get_currentuser_usecase.dart';
import 'package:mm/features/auth/domain/usecases/login_usecase.dart';
import 'package:mm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mm/features/auth/domain/usecases/register_usecase.dart';
import 'package:mm/features/auth/presentation/bloc/auth%20bloc/auth_bloc.dart';
import 'package:mm/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:mm/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:mm/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
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
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  //2. External (Supabase)
  final supabaseClient = Supabase.instance.client;

  sl.registerLazySingleton(() => supabaseClient);

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
    () => WardrobeRemoteDataSourceImpl(supabaseClient: sl()),
  );

  //----------------------------------------------------//
  //Gallery Feature
  //BLoC
  sl.registerFactory(() => GalleryBloc(repository: sl()));

  //Repository
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(remoteDataSource: sl()),
  );

  //Data Source
  sl.registerLazySingleton<GalleryRemoteDataSource>(
    () => GalleryRemoteDataSourceImpl(supabaseClient: sl()),
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
