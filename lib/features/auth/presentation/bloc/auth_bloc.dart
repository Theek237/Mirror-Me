// import 'package:equatable/equatable.dart';
// import 'package:mm/features/auth/domain/entities/user_entity.dart';
// import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';


// //Events
// // abstract class AuthEvent extends Equatable {
// //   const AuthEvent();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class AuthCheckRequested extends AuthEvent{}

// // class AuthLoginRequested extends AuthEvent{
// //   final String email;
// //   final String password;
// //   const AuthLoginRequested({required this.email, required this.password});
// // }

// // class AuthRegisterRequested extends AuthEvent{
// //   final String email;
// //   final String password;
// //   final String name;
// //   const AuthRegisterRequested({required this.email, required this.password, required this.name});
// // }

// // class AuthGoogleLoginRequested extends AuthEvent{}

// // class AuthLogoutRequested extends AuthEvent{}


// //States
// // abstract class AuthState extends Equatable{
// //   const AuthState();

// //   @override
// //   List<Object?> get props => [];
// // }

// // class AuthInitial extends AuthState{}
// // class AuthLoading extends AuthState{}
// // class AuthAuthenticated extends AuthState{
// //   final UserEntity user;
// //   const AuthAuthenticated({required this.user});
// //   @override
// //   List<Object?> get props => [user];
// // }
// // class AuthUnauthenticated extends AuthState{}
// // class AuthError extends AuthState{
// //   final String message;
// //   const AuthError({required this.message});
// //   @override
// //   List<Object?> get props => [message];
// // }

// //BLoC
// // class AuthBloc extends Bloc<AuthEvent, AuthState>{
// //   final AuthRepository authRepository;
// //   AuthBloc({required this.authRepository}): super(AuthInitial()){

// //     //App Start Check
// //     on<AuthCheckRequested>((event,emit) async{
// //       final user = await authRepository.getCurrentUser();
// //       if(user != null){
// //         emit(AuthAuthenticated(user: user));
// //       } else{
// //         emit(AuthUnauthenticated());
// //       }
// //     });

// //     //Login Logic
// //     on<AuthLoginRequested>((event, emit) async {
// //       emit(AuthLoading());
// //       final result = await authRepository.loginWithEmail(event.email, event.password);
// //       result.fold(
// //         (failure)=>emit(AuthError(message: failure.message)),
// //         (user)=>emit(AuthAuthenticated(user: user))
// //       );
// //     });

// //     //Register Logic
// //     on<AuthRegisterRequested>((event, emit) async{
// //       emit(AuthLoading());
// //       final result = await authRepository.registerWithEmail(event.email, event.password, event.name);
// //       result.fold(
// //         (failure)=>emit(AuthError(message: failure.message)),
// //         (user)=>emit(AuthAuthenticated(user: user))
// //       );
// //     },);

// //     //Google Login Logic
// //     on<AuthGoogleLoginRequested>((event, emit) async{
// //       emit(AuthLoading());
// //       final result = await authRepository.loginWithGoogle();
// //       result.fold(
// //         (failure)=>emit(AuthError(message: failure.message)),
// //         (user)=>emit(AuthAuthenticated(user: user))
// //       );
// //     });

// //     //Logout Logic
// //     on<AuthLogoutRequested>((event, emit) async{
// //       emit(AuthLoading());
// //       await authRepository.logout();
// //       emit(AuthUnauthenticated());
// //     });
// //   }
// // }


