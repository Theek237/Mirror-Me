import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:mm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mm/features/auth/data/reoisitories/auth_repository_impl.dart';
import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';
import 'package:mm/features/auth/presentation/bloc/auth%20bloc/auth_bloc.dart';
import 'package:mm/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:mm/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:mm/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe%20bloc/wardrobe_bloc.dart';

//Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //Auth Feature
  //BLoC
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  //Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()), 
  );

  //Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      // googleSignIn: sl(),
      firestore: sl(),
    )
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
  sl.registerFactory(() => WardrobeBloc(repository: sl()),);

  //Repository
  sl.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(remoteDataSource: sl()),
  );

  //Data Source
  sl.registerLazySingleton<WardrobeRemoteDataSource>(
    () => WardrobeRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

}