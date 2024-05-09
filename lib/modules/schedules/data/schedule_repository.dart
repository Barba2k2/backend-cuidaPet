import 'package:cuidapet_api/app/exceptions/database_exceptions.dart';
import 'package:cuidapet_api/entities/schedule.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/logger/i_logger.dart';
import './i_schedule_repository.dart';

@LazySingleton(as: IScheduleRepository)
class ScheduleRepository implements IScheduleRepository {
  final IDatabaseConnection connection;
  final ILogger log;

  ScheduleRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<void> save(Schedule schedule) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      await conn.transaction((_) async {
        final result = await conn!.query(
          '''
          INSERT INTO 
            agendamento(
              data_agendamento, 
              usuario_id, 
              fornecedor_id, 
              status, 
              nome, 
              nome_pet
            )
          VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ''',
          [
            schedule.scheduleDate.toIso8601String(),
            schedule.userId,
            schedule.supplier.id,
            schedule.status,
            schedule.name,
            schedule.petName,
          ],
        );

        final scheduleId = result.insertId;

        if (scheduleId != null) {
          await conn.queryMulti(
            '''
            INSERT INTO 
              agendamento_servicos
            VALUES 
              (?, ?)
            ''',
            schedule.services
                .map(
                  (s) => [
                    scheduleId,
                    s.service.id,
                  ],
                )
                .toList(),
          );
        }
      });
    } on MySqlException catch (e, s) {
      log.error('Error on schedule service', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
