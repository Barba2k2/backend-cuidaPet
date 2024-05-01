import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/exceptions/databse_exceptions.dart';
import '../../../app/exceptions/user_exists_exception.dart';
import '../../../app/exceptions/user_not_found_exception.dart';
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

  @override
  Future<User> loginWithEmailPassword(
    String email,
    String password,
    bool supplierUser,
  ) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      var query = '''
        SELECT * 
        FROM usuario 
        WHERE 
          email = ? AND 
          senha = ?
      ''';

      if (supplierUser) {
        query += ' AND fornecedor_id IS NOT NULL';
      } else {
        query += ' AND fornecedor_id IS NULL';
      }

      final result = await conn.query(
        query,
        [
          email,
          CryptHelper.generateSHA256Hash(password),
        ],
      );

      if (result.isEmpty) {
        log.error('User or password invalid!!');
        throw UserNotFoundException(
          message: 'User or password invalid!!',
        );
      } else {
        final userSqlData = result.first;
        return User(
          id: userSqlData['id'] as int,
          email: userSqlData['email'],
          registerType: userSqlData['tipo_cadastro'],
          iosToken: (userSqlData['ios_token'] as Blob?)?.toString(),
          androidToken: (userSqlData['android_token'] as Blob?)?.toString(),
          refreshToken: (userSqlData['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (userSqlData['img_avatar'] as Blob?).toString(),
          supplierId: userSqlData['fornecedor_id'],
        );
      }
    } catch (e, s) {
      log.error('Error on login', e, s);
      throw DatabseExceptions(
        message: e.toString(),
      );
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginByEmailSocialKey(
    String email,
    String socialKey,
    String socialType,
  ) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query(
        'SELECT * FROM usuario WHERE email = ?',
        [email],
      );

      if (result.isEmpty) {
        throw UserNotFoundException(
          message: 'User not found',
        );
      } else {
        final dataMysql = result.first;

        if (dataMysql['social_id'] == null ||
            dataMysql['sacial_id'] != socialKey) {
          await conn.query(
            'UPDATE usuario SET social_id = ?, tipo_cadastro = ? WHERE id = ?',
            [
              socialKey,
              socialType,
              dataMysql['id'],
            ],
          );
        }

        return User(
          id: dataMysql['id'] as int,
          email: dataMysql['email'],
          registerType: dataMysql['tipo_cadastro'],
          iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
          androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataMysql['img_avatar'] as Blob?).toString(),
          supplierId: dataMysql['fornecedor_id'],
        );
      }
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateUserDeviceTokenAndRefreshToken(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final setParams = {};

      if (user.iosToken != null) {
        setParams.putIfAbsent('ios_token', () => user.iosToken);
      } else {
        setParams.putIfAbsent('android_token', () => user.androidToken);
      }

      final query = '''
        UPDATE usuario SET 
          ${setParams.keys.elementAt(0)} = ?, 
          refresh_token = ? 
        WHERE 
          id = ?
      ''';

      await conn.query(
        query,
        [
          setParams.values.elementAt(0),
          user.refreshToken!,
          user.id!,
        ],
      );
    } on MySqlException catch (e, s) {
      log.error('Error on confirm login', e, s);
      throw DatabseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateRefreshToken(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query(
        'UPDATE usuario SET refresh_token = ? WHERE id = ?',
        [
          user.refreshToken!,
          user.id,
        ],
      );
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> findById(int id) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query(
        'SELECT * FROM usuario WHERE id = ?',
        [id],
      );

      if (result.isEmpty) {
        log.error('User not found with id: $id');
        throw UserNotFoundException(message: 'User not found with id: $id');
      } else {
        final dataMysql = result.first;

        return User(
          id: dataMysql['id'] as int,
          email: dataMysql['email'],
          registerType: dataMysql['tipo_cadastro'],
          iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
          androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataMysql['img_avatar'] as Blob?).toString(),
          supplierId: dataMysql['fornecedor_id'],
        );
      }
    } finally {
      await conn?.close();
    }
  }
}
