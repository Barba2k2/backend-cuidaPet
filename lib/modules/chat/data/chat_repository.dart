import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/entities/device_token.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/exceptions/database_exceptions.dart';
import '../../../app/logger/i_logger.dart';

import 'i_chat_repository.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  IDatabaseConnection connection;
  ILogger log;

  ChatRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<int> startChat(int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query(
        '''
          INSERT INTO
            chats (agendamento_id, status, data_criacao)
          VALUES
            (?, ?, ?)
        ''',
        [
          scheduleId,
          'A',
          DateTime.now().toIso8601String(),
        ],
      );

      return result.insertId!;
    } on MySqlException catch (e, s) {
      log.error('Error on start chatting', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Chat?> findChatById(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          c.id,
          c.data_criacao,
          c.status,
          a.nome AS agendamento_nome,
          a.nome_pet AS agendamento_nome_pet,
          a.fornecedor_id,
          f.nome AS fornec_nome,
          f.logo,
          a.usuario_id,
          u.android_token AS user_android_token,
          u.ios_token AS user_ios_token,
          uf.android_token AS fornec_android_token,
          uf.ios_token AS fornec_ios_token
        FROM 
          chats AS c
        INNER JOIN
          agendamento a 
        ON
          a.id = c.agendamento_id
        INNER JOIN
          fornecedor f
        ON
          f.id = a.fornecedor_id
        INNER JOIN
          usuario u 
        -- Client user data
        ON
          u.id = a.usuario_id
        -- Supplier user data
        INNER JOIN
          usuario uf
        ON
          uf.fornecedor_id = f.id
        WHERE 
          c.id = ?
      ''';

      final result = await conn.query(
        query,
        [chatId],
      );

      if (result.isNotEmpty) {
        final resultSql = result.first;

        return Chat(
          id: resultSql['id'],
          status: resultSql['status'],
          name: resultSql['agendamento_nome'],
          petName: resultSql['nome_pet'],
          supplier: Supplier(
            id: resultSql['fornecedor_id'],
            name: resultSql['fornec_nome'],
          ),
          user: resultSql['usuario_id'],
          userDeviceToken: DeviceToken(
            android: (resultSql['user_android_token'] as Blob?)?.toString(),
            ios: (resultSql['user_ios_token'] as Blob?)?.toString(),
          ),
          supplierDeviceToken: DeviceToken(
            android: (resultSql['fornec_android_token'] as Blob?)?.toString(),
            ios: (resultSql['fornec_ios_token'] as Blob?)?.toString(),
          ),
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Error on find chat data', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatByUser(int user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome AS fornec_nome,
          f.logo
        FROM
          chats AS c
        INNER JOIN
          agendamento a
        ON
          a.id = c.agendamento_id
        INNER JOIN
          fornecedor f
        ON
          f.id = a.fornecedor_id
        WHERE
          a.usuario_id = ?
        AND
          c.status = 'A'
        ORDER BY
          c.data_criacao
      ''';

      final result = await conn.query(
        query,
        [user],
      );

      return result
          .map(
            (c) => Chat(
              id: c['id'],
              user: c['usuario_id'],
              supplier: Supplier(
                id: c['fornecedor_id'],
                name: c['fornec_nome'],
                logo: (c['logo'] as Blob?)?.toString(),
              ),
              name: c['nome'],
              petName: c['nome_pet'],
              status: c['status'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Error on finding chats of user', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsBySupplier(int supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome AS fornec_nome,
          f.logo
        FROM
          chats AS c
        INNER JOIN
          agendamento a
        ON
          a.id = c.agendamento_id
        INNER JOIN
          fornecedor f
        ON
          f.id = a.fornecedor_id
        WHERE
          a.fornecedor_id = ?
        AND
          c.status = 'A'
        ORDER BY
          c.data_criacao
      ''';

      final result = await conn.query(
        query,
        [supplier],
      );

      return result
          .map(
            (c) => Chat(
              id: c['id'],
              user: c['usuario_id'],
              supplier: Supplier(
                id: c['fornecedor_id'],
                name: c['fornec_nome'],
                logo: (c['logo'] as Blob?)?.toString(),
              ),
              name: c['nome'],
              petName: c['nome_pet'],
              status: c['status'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Error on finding chats of supplier', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
  
  @override
  Future<void> endChat(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      await conn.query(
        '''
          UPDATE chats SET STATUS = 'F' WHERE id = ?
        ''',
        [
          chatId,
        ],
      );
    } on MySqlException catch (e, s) {
      log.error('Error on finishing chat', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
