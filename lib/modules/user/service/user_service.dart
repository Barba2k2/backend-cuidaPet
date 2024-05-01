import 'package:injectable/injectable.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../../../app/exceptions/service_exception.dart';
import '../../../app/exceptions/user_not_found_exception.dart';
import '../../../app/helpers/jwt_helper.dart';
import '../../../app/logger/i_logger.dart';
import '../../../entities/user.dart';
import '../data/i_user_repository.dart';
import '../view_models/refresh_token_view_model.dart';
import '../view_models/update_url_avatar_view_model.dart';
import '../view_models/user_confirm_input_model.dart';
import '../view_models/user_refresh_token_input_model.dart';
import '../view_models/user_save_input_model.dart';
import 'I_user_service.dart';

@LazySingleton(as: IUserService)
class UserService implements IUserService {
  IUserRepository userRepository;
  ILogger log;

  UserService({
    required this.userRepository,
    required this.log,
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

  @override
  Future<User> loginWithEmailPassword(
    String email,
    String password,
    bool supplierUser,
  ) =>
      userRepository.loginWithEmailPassword(
        email,
        password,
        supplierUser,
      );

  @override
  Future<User> loginWithSocial(
    String email,
    String avatar,
    String socialType,
    String socialKey,
  ) async {
    try {
      return await userRepository.loginByEmailSocialKey(
          email, socialKey, socialType);
    } on UserNotFoundException catch (e) {
      log.error('User not found, creating a new user', e);

      final user = User(
        email: email,
        imageAvatar: avatar,
        registerType: socialType,
        socialKey: socialKey,
        password: DateTime.now().toString(),
      );
      return await userRepository.createUser(user);
    }
  }

  @override
  Future<String> confirmLogin(UserConfirmInputModel inputModel) async {
    final refreshToken = JwtHelper.refreshToken(inputModel.accessToken);

    final user = User(
      id: inputModel.userId,
      refreshToken: refreshToken,
      iosToken: inputModel.iosDeviceToken,
      androidToken: inputModel.androidDeviceToken,
    );

    await userRepository.updateUserDeviceTokenAndRefreshToken(user);

    return refreshToken;
  }

  @override
  Future<RefreshTokenViewModel> refreshToken(
    UserRefreshTokenInputModel model,
  ) async {
    _validateRefreshToken(model);

    final newAccessToken = JwtHelper.generateJwt(model.user, model.supplier);
    final newRefreshToken = JwtHelper.refreshToken(
      newAccessToken.replaceAll('Bearer ', ''),
    );

    final user = User(
      id: model.user,
      refreshToken: newRefreshToken,
    );

    await userRepository.updateRefreshToken(user);

    return RefreshTokenViewModel(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }

  void _validateRefreshToken(UserRefreshTokenInputModel model) {
    try {
      final refreshToken = model.refreshToken.split(' ');

      if (refreshToken.length != 2 || refreshToken.first != 'Bearer') {
        log.error('Invalid refresh token');
        throw ServiceException(message: 'Invalid refresh token');
      }

      final refreshTokenClaim = JwtHelper.getClaims(refreshToken.last);
      refreshTokenClaim.validate(issuer: model.accessToken);
    } on ServiceException {
      rethrow;
    } on JwtException catch (e) {
      log.error('Invalid refresh token', e);
      throw ServiceException(message: 'Invalid refresh token');
    } catch (e) {
      throw ServiceException(message: 'Error on validate refresh token');
    }
  }
  
  @override
  Future<User> findById(int id) => userRepository.findById(id);

  @override
  Future<User> updateAvatar(UpdateUrlAvatarViewModel viewModel) async {
    await userRepository.updateUrlAvatar(viewModel.userId, viewModel.urlAvatar);

    return userRepository.findById(viewModel.userId);
  }
}
