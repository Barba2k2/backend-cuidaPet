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
      log.error('Error on startChat', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
