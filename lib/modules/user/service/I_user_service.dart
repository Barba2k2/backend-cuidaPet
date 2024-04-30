import '../../../entities/user.dart';
import '../view_models/user_save_input_model.dart';

abstract class IUserService {
  Future<User> createUser(UserSaveInputModel user);
  Future<User> loginWithEmailPassword(
    String email,
    String password,
    bool supplierUser,
  );
  Future<User> loginWithSocial(
    String email,
    String avatar,
    String socialType,
    String socialKey,
  );
}