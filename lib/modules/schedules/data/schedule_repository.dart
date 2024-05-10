import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/exceptions/database_exceptions.dart';
import '../../../entities/schedule.dart';
import '../../../entities/schedule_supplier_service.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart';
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

  @override
  Future<void> changeStatus(String status, int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      await conn.query(
        '''
          UPDATE agendamento
          SET status = ?
          WHERE id = ?
        ''',
        [
          status,
          scheduleId,
        ],
      );
    } on MySqlException catch (e, s) {
      log.error('Error on change schedule status', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Schedule>> findAllSchedulesByUser(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT 
          a.id,
          a.data_agendamento,
          a.status,
          a.nome,
          a.nome_pet,
          f.id AS fornec_id,
          f.nome AS fornec_nome,
          f.logo
        FROM 
          agendamento AS a
        INNER JOIN 
          fornecedor f 
        ON 
          f.id = a.fornecedor_id
        WHERE 
          a.usuario_id = ?
        ORDER BY
          a.data_agendamento DESC
      ''';

      final result = await conn.query(
        query,
        [userId],
      );

      final scheduleResultFuture = result
          .map(
            (s) async => Schedule(
              id: s['id'],
              scheduleDate: s['data_agendamento'],
              status: s['status'],
              name: s['nome'],
              petName: s['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: s['fornec_id'],
                name: s['fornec_nome'],
                logo: (s['logo'] as Blob?).toString(),
              ),
              services: await findAllServicesBySchedule(s['id']),
            ),
          )
          .toList();

      return Future.wait(scheduleResultFuture);
    } on MySqlException catch (e, s) {
      log.error('Error when seeking services from a user', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Schedule>> findAllSchedulesByUserSupplier(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT 
          a.id,
          a.data_agendamento,
          a.status,
          a.nome,
          a.nome_pet,
          f.id AS fornec_id,
          f.nome AS fornec_nome,
          f.logo
        FROM 
          agendamento AS a
        INNER JOIN 
          fornecedor f
        INNER JOIN
          usuario u
        ON
          u.fornecedor_id = f.id
        WHERE 
          u.id = ?
        ORDER BY
          a.data_agendamento DESC
      ''';

      final result = await conn.query(
        query,
        [userId],
      );

      final scheduleResultFuture = result
          .map(
            (s) async => Schedule(
              id: s['id'],
              scheduleDate: s['data_agendamento'],
              status: s['status'],
              name: s['nome'],
              petName: s['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: s['fornec_id'],
                name: s['fornec_nome'],
                logo: (s['logo'] as Blob?).toString(),
              ),
              services: await findAllServicesBySchedule(s['id']),
            ),
          )
          .toList();

      return Future.wait(scheduleResultFuture);
    } on MySqlException catch (e, s) {
      log.error('Error when seeking services from a user', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  Future<List<ScheduleSupplierService>> findAllServicesBySchedule(
    int scheduleId,
  ) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query(
        '''
          SELECT
            fs.id,
            fs.nome_servico,
            fs.valor_servico,
            fs.fornecedor_id
          FROM 
            agendamento_servicos AS ags
          INNER JOIN
            fornecedor_servicos AS fs
          ON
            fs.id = ags.fornecedor_servicos_id
          WHERE
            ags.agendamento_id = ?
        ''',
        [scheduleId],
      );

      return result
          .map(
            (s) => ScheduleSupplierService(
              service: SupplierService(
                id: s['id'],
                name: s['nome_servico'],
                price: s['valor_servico'],
                supplierId: s['fornecedor_id'],
              ),
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Error when searching for appointment services', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
