import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:mm/features/auth/domain/repositiories/auth_repository.dart';

class GetCurrentuserUsecase {
  final AuthRepository repository;
  GetCurrentuserUsecase({required this.repository});

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
