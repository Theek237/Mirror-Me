import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_session_cubit.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/watch_closet_analytics.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/calendar/data/datasources/calendar_remote_datasource.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/domain/usecases/add_calendar_event.dart';
import '../../features/calendar/domain/usecases/watch_calendar_events.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/collections/data/datasources/collections_remote_datasource.dart';
import '../../features/collections/data/repositories/collections_repository_impl.dart';
import '../../features/collections/domain/repositories/collections_repository.dart';
import '../../features/collections/domain/usecases/create_collection.dart';
import '../../features/collections/domain/usecases/watch_collections.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/wardrobe/data/datasources/wardrobe_remote_datasource.dart';
import '../../features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import '../../features/wardrobe/domain/repositories/wardrobe_repository.dart';
import '../../features/wardrobe/domain/usecases/watch_wardrobe_items.dart';
import '../../features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import '../../features/recommendations/data/datasources/recommendations_remote_datasource.dart';
import '../../features/recommendations/data/repositories/recommendations_repository_impl.dart';
import '../../features/recommendations/domain/repositories/recommendations_repository.dart';
import '../../features/recommendations/domain/usecases/delete_favorite.dart';
import '../../features/recommendations/domain/usecases/generate_recommendations.dart';
import '../../features/recommendations/domain/usecases/save_favorite.dart';
import '../../features/recommendations/domain/usecases/save_recommendations.dart';
import '../../features/recommendations/domain/usecases/watch_favorites.dart';
import '../../features/recommendations/presentation/bloc/recommendations_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/watch_favorites_count.dart';
import '../../features/profile/domain/usecases/watch_recommendations_count.dart';
import '../../features/profile/domain/usecases/watch_tryon_count.dart';
import '../../features/profile/domain/usecases/watch_user_profile.dart';
import '../../features/profile/domain/usecases/watch_wardrobe_count.dart';
import '../../features/style_quiz/data/datasources/style_quiz_remote_datasource.dart';
import '../../features/style_quiz/data/repositories/style_quiz_repository_impl.dart';
import '../../features/style_quiz/domain/repositories/style_quiz_repository.dart';
import '../../features/style_quiz/domain/usecases/load_style_preferences.dart';
import '../../features/style_quiz/domain/usecases/save_style_preferences.dart';
import '../../features/style_quiz/presentation/bloc/style_quiz_bloc.dart';
import '../../features/share_cards/data/datasources/share_cards_remote_datasource.dart';
import '../../features/share_cards/data/repositories/share_cards_repository_impl.dart';
import '../../features/share_cards/domain/repositories/share_cards_repository.dart';
import '../../features/share_cards/domain/usecases/watch_share_cards.dart';
import '../../features/share_cards/presentation/bloc/share_cards_bloc.dart';
import '../../features/tryon/data/datasources/tryon_remote_datasource.dart';
import '../../features/tryon/data/repositories/tryon_repository_impl.dart';
import '../../features/tryon/domain/repositories/tryon_repository.dart';
import '../../features/tryon/domain/usecases/submit_tryon.dart';
import '../../features/tryon/presentation/bloc/tryon_bloc.dart';
import '../../features/tryon_history/data/datasources/tryon_history_remote_datasource.dart';
import '../../features/tryon_history/data/repositories/tryon_history_repository_impl.dart';
import '../../features/tryon_history/domain/repositories/tryon_history_repository.dart';
import '../../features/tryon_history/domain/usecases/watch_tryon_history.dart';
import '../../features/tryon_history/presentation/bloc/tryon_history_bloc.dart';
import '../../services/gemini_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  if (sl.isRegistered<FirebaseAuth>()) return;

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<CollectionsRemoteDataSource>(
    () => CollectionsRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<WardrobeRemoteDataSource>(
    () => WardrobeRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<GeminiService>(() => GeminiService());

  sl.registerLazySingleton<RecommendationsRemoteDataSource>(
    () => RecommendationsRemoteDataSource(
      sl<FirebaseFirestore>(),
      sl<GeminiService>(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<StyleQuizRemoteDataSource>(
    () => StyleQuizRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<ShareCardsRemoteDataSource>(
    () => ShareCardsRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<TryOnHistoryRemoteDataSource>(
    () => TryOnHistoryRemoteDataSource(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<TryOnRemoteDataSource>(
    () => TryOnRemoteDataSource(sl<FirebaseFirestore>(), sl<GeminiService>()),
  );

  sl.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(sl<WardrobeRemoteDataSource>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl<AnalyticsRemoteDataSource>()),
  );

  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(sl<CalendarRemoteDataSource>()),
  );

  sl.registerLazySingleton<CollectionsRepository>(
    () => CollectionsRepositoryImpl(sl<CollectionsRemoteDataSource>()),
  );

  sl.registerLazySingleton<RecommendationsRepository>(
    () => RecommendationsRepositoryImpl(sl<RecommendationsRemoteDataSource>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  sl.registerLazySingleton<StyleQuizRepository>(
    () => StyleQuizRepositoryImpl(sl<StyleQuizRemoteDataSource>()),
  );

  sl.registerLazySingleton<ShareCardsRepository>(
    () => ShareCardsRepositoryImpl(sl<ShareCardsRemoteDataSource>()),
  );

  sl.registerLazySingleton<TryOnHistoryRepository>(
    () => TryOnHistoryRepositoryImpl(sl<TryOnHistoryRemoteDataSource>()),
  );

  sl.registerLazySingleton<TryOnRepository>(
    () => TryOnRepositoryImpl(sl<TryOnRemoteDataSource>()),
  );

  sl.registerLazySingleton<WatchWardrobeItems>(
    () => WatchWardrobeItems(sl<WardrobeRepository>()),
  );

  sl.registerLazySingleton<WatchAuthState>(
    () => WatchAuthState(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignIn>(() => SignIn(sl<AuthRepository>()));
  sl.registerLazySingleton<SignUp>(() => SignUp(sl<AuthRepository>()));
  sl.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendPasswordReset>(
    () => SendPasswordReset(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOut>(() => SignOut(sl<AuthRepository>()));

  sl.registerLazySingleton<WatchClosetAnalytics>(
    () => WatchClosetAnalytics(sl<AnalyticsRepository>()),
  );

  sl.registerLazySingleton<WatchCalendarEvents>(
    () => WatchCalendarEvents(sl<CalendarRepository>()),
  );
  sl.registerLazySingleton<AddCalendarEvent>(
    () => AddCalendarEvent(sl<CalendarRepository>()),
  );

  sl.registerLazySingleton<WatchCollections>(
    () => WatchCollections(sl<CollectionsRepository>()),
  );
  sl.registerLazySingleton<CreateCollection>(
    () => CreateCollection(sl<CollectionsRepository>()),
  );

  sl.registerLazySingleton<WatchFavorites>(
    () => WatchFavorites(sl<RecommendationsRepository>()),
  );
  sl.registerLazySingleton<GenerateRecommendations>(
    () => GenerateRecommendations(sl<RecommendationsRepository>()),
  );
  sl.registerLazySingleton<SaveRecommendations>(
    () => SaveRecommendations(sl<RecommendationsRepository>()),
  );
  sl.registerLazySingleton<SaveFavorite>(
    () => SaveFavorite(sl<RecommendationsRepository>()),
  );
  sl.registerLazySingleton<DeleteFavorite>(
    () => DeleteFavorite(sl<RecommendationsRepository>()),
  );

  sl.registerLazySingleton<WatchUserProfile>(
    () => WatchUserProfile(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<WatchWardrobeCount>(
    () => WatchWardrobeCount(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<WatchTryOnCount>(
    () => WatchTryOnCount(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<WatchFavoritesCount>(
    () => WatchFavoritesCount(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<WatchRecommendationsCount>(
    () => WatchRecommendationsCount(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<LoadStylePreferences>(
    () => LoadStylePreferences(sl<StyleQuizRepository>()),
  );
  sl.registerLazySingleton<SaveStylePreferences>(
    () => SaveStylePreferences(sl<StyleQuizRepository>()),
  );

  sl.registerLazySingleton<WatchShareCards>(
    () => WatchShareCards(sl<ShareCardsRepository>()),
  );

  sl.registerLazySingleton<WatchTryOnHistory>(
    () => WatchTryOnHistory(sl<TryOnHistoryRepository>()),
  );

  sl.registerLazySingleton<SubmitTryOn>(
    () => SubmitTryOn(sl<TryOnRepository>()),
  );

  sl.registerFactory<WardrobeBloc>(
    () => WardrobeBloc(watchWardrobeItems: sl<WatchWardrobeItems>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signIn: sl<SignIn>(),
      signUp: sl<SignUp>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      sendPasswordReset: sl<SendPasswordReset>(),
      signOut: sl<SignOut>(),
    ),
  );

  sl.registerFactory<AuthSessionCubit>(
    () => AuthSessionCubit(watchAuthState: sl<WatchAuthState>()),
  );

  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(watchClosetAnalytics: sl<WatchClosetAnalytics>()),
  );

  sl.registerFactory<CalendarBloc>(
    () => CalendarBloc(
      watchCalendarEvents: sl<WatchCalendarEvents>(),
      addCalendarEvent: sl<AddCalendarEvent>(),
    ),
  );

  sl.registerFactory<CollectionsBloc>(
    () => CollectionsBloc(
      watchCollections: sl<WatchCollections>(),
      createCollection: sl<CreateCollection>(),
    ),
  );

  sl.registerFactory<RecommendationsBloc>(
    () => RecommendationsBloc(
      watchFavorites: sl<WatchFavorites>(),
      generateRecommendations: sl<GenerateRecommendations>(),
      saveRecommendations: sl<SaveRecommendations>(),
      saveFavorite: sl<SaveFavorite>(),
      deleteFavorite: sl<DeleteFavorite>(),
    ),
  );

  sl.registerFactory<StyleQuizBloc>(
    () => StyleQuizBloc(
      loadStylePreferences: sl<LoadStylePreferences>(),
      saveStylePreferences: sl<SaveStylePreferences>(),
    ),
  );

  sl.registerFactory<ShareCardsBloc>(
    () => ShareCardsBloc(watchShareCards: sl<WatchShareCards>()),
  );

  sl.registerFactory<TryOnHistoryBloc>(
    () => TryOnHistoryBloc(watchTryOnHistory: sl<WatchTryOnHistory>()),
  );

  sl.registerFactory<TryOnBloc>(
    () => TryOnBloc(submitTryOn: sl<SubmitTryOn>()),
  );
}
