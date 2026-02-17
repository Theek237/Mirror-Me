import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mm/core/constants/gemini_config.dart';
import 'package:mm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mm/features/auth/domain/repositories/auth_repository.dart';
import 'package:mm/features/auth/domain/usecases/get_currentuser_usecase.dart';
import 'package:mm/features/auth/domain/usecases/login_usecase.dart';
import 'package:mm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mm/features/auth/domain/usecases/register_usecase.dart';
import 'package:mm/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:mm/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:mm/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:mm/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:mm/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:mm/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:mm/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe_bloc/wardrobe_bloc.dart';
import 'package:mm/features/tryon/data/datasources/gemini_remote_data_source.dart';
import 'package:mm/features/tryon/data/datasources/tryon_remote_data_source.dart';
import 'package:mm/features/tryon/data/repositories/tryon_repository_impl.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';
import 'package:mm/features/tryon/domain/usecases/generate_tryon.dart';
import 'package:mm/features/tryon/domain/usecases/get_tryon_results.dart';
import 'package:mm/features/tryon/domain/usecases/save_tryon_result.dart';
import 'package:mm/features/tryon/domain/usecases/toggle_tryon_favorite.dart';
import 'package:mm/features/tryon/presentation/bloc/tryon_bloc.dart';
import 'package:mm/features/recommendations/data/datasources/recommendation_remote_data_source.dart';
import 'package:mm/features/recommendations/data/datasources/recommendation_supabase_data_source.dart';
import 'package:mm/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:mm/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:mm/features/recommendations/domain/usecases/generate_recommendation.dart';
import 'package:mm/features/recommendations/domain/usecases/save_recommendation.dart';
import 'package:mm/features/recommendations/domain/usecases/get_recommendations.dart';
import 'package:mm/features/recommendations/presentation/bloc/recommendation_bloc.dart';

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
  sl.registerFactory(
    () => TryOnBloc(
      generateTryOn: sl(),
      saveTryOnResult: sl(),
      getTryOnResults: sl(),
      toggleTryOnFavorite: sl(),
    ),
  );

  //Use Cases
  sl.registerLazySingleton(() => GenerateTryOn(sl()));
  sl.registerLazySingleton(() => SaveTryOnResult(sl()));
  sl.registerLazySingleton(() => GetTryOnResults(sl()));
  sl.registerLazySingleton(() => ToggleTryOnFavorite(sl()));

  //Repository
  sl.registerLazySingleton<TryOnRepository>(
    () => TryOnRepositoryImpl(geminiDataSource: sl(), tryOnDataSource: sl()),
  );

  //Data Sources
  sl.registerLazySingleton<GeminiRemoteDataSource>(
    () => GeminiRemoteDataSourceImpl(apiKey: GeminiConfig.apiKey),
  );

  sl.registerLazySingleton<TryOnRemoteDataSource>(
    () => TryOnRemoteDataSourceImpl(supabaseClient: sl()),
  );

  //----------------------------------------------------//
  //Recommendations Feature
  //BLoC
  sl.registerFactory(
    () => RecommendationBloc(
      generateRecommendation: sl(),
      saveRecommendation: sl(),
      getRecommendations: sl(),
    ),
  );

  //Use Cases
  sl.registerLazySingleton(() => GenerateRecommendation(sl()));
  sl.registerLazySingleton(() => SaveRecommendation(sl()));
  sl.registerLazySingleton(() => GetRecommendations(sl()));

  //Repository
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(
      remoteDataSource: sl(),
      supabaseDataSource: sl(),
    ),
  );

  //Data Sources
  sl.registerLazySingleton<RecommendationRemoteDataSource>(
    () => RecommendationRemoteDataSourceImpl(apiKey: GeminiConfig.apiKey),
  );

  sl.registerLazySingleton<RecommendationSupabaseDataSource>(
    () => RecommendationSupabaseDataSourceImpl(supabaseClient: sl()),
  );
}
