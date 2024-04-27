import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/exceptions/databse_exceptions.dart';
import '../../../app/exceptions/user_exists_exception.dart';
import '../../../app/helpers/crypt_helper.dart';
import '../../../app/logger/i_logger.dart';
import '../../../entities/user.dart';
import './i_user_repository.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  final IDatabaseConnction connection;
  final ILogger log;

  UserRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<User> createUser(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
        insert usuario(email, tipo_cadastro, img_avatar, senha, fornecedor_id, social_id)
        values (?, ?, ?, ?, ?, ?)
      ''';

      final result = await conn.query(
        query,
        <Object?>[
          user.email,
          user.registerType,
          user.imageAvatar,
          CryptHelper.generateSHA256Hash(user.password ?? ''),
          user.supplierId,
          user.socialKey,
        ],
      );

      final userId = result.insertId;
      return user.copyWith(
        id: userId,
        password: null,
      );
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        log.error('Email already in use', e, s);
        throw UserExistsException();
      }

      log.error('Error on creating user', e, s);

      throw DatabseExceptions(
        message: 'Error on creating user',
        exception: e,
      );

    } finally {
      await conn?.close();
    }
  }
}
