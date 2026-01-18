import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase({required this.repository});

  Future<void> call() async {
    return await repository.logout();
  }
}
