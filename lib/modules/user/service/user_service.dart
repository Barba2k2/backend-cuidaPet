import 'package:injectable/injectable.dart';

import '../../../entities/user.dart';
import '../data/i_user_repository.dart';
import '../view_models/user_save_input_model.dart';
import 'I_user_service.dart';

@LazySingleton(as: IUserService)
class UserService implements IUserService {
  IUserRepository userRepository;

  UserService({
    required this.userRepository,
  });
  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntitie = User(
      email: user.email,
      password: user.password,
      registerType: 'App',
      supplierId: user.supplierId,
    );

    return userRepository.createUser(userEntitie);
  }
}
