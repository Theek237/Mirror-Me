// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc(
    this.authRepository,
  ) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      
      //App Start Check
      on<AuthCheckRequested>((event,emit) async{
        final user = await authRepository.getCurrentUser();
        if(user != null){
          emit(AuthAuthenticated(user: user));
        } else{
          emit(AuthUnauthenticated());
        }
      });

      //Login Logic
      on<AuthLoginRequested>((event, emit) async {
        emit(AuthLoading());
        final result = await authRepository.loginWithEmail(event.email, event.password);
        result.fold(
          (failure)=>emit(AuthError(message: failure.message)),
          (user)=>emit(AuthAuthenticated(user: user))
        );
      });

      //Register Logic
      on<AuthRegisterRequested>((event, emit) async{
        emit(AuthLoading());
        final result = await authRepository.registerWithEmail(event.email, event.password, event.name);
        result.fold(
          (failure)=>emit(AuthError(message: failure.message)),
          (user)=>emit(AuthAuthenticated(user: user))
        );
      },);

      //Google Login Logic
      on<AuthGoogleLoginRequested>((event, emit) async{
        emit(AuthLoading());
        final result = await authRepository.loginWithGoogle();
        result.fold(
          (failure)=>emit(AuthError(message: failure.message)),
          (user)=>emit(AuthAuthenticated(user: user))
        );
      });

      //Logout Logic
      on<AuthLogoutRequested>((event, emit) async{
        emit(AuthLoading());
        await authRepository.logout();
        emit(AuthUnauthenticated());
      });
      });
  }
}
