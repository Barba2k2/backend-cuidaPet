import 'package:cuidapet_api/app/database/i_database_connection.dart';
import 'package:cuidapet_api/app/exceptions/database_exceptions.dart';
import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_supplier_repository.dart';

@LazySingleton(as: ISupplierRepository)
class SupplierRepository implements ISupplierRepository {
  final IDatabaseConnection connection;
  final ILogger log;

  SupplierRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<List<SupplierNearbyMeDto>> findNearbyPosition(
    double lat,
    double lng,
    int distance,
  ) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      // 6371 => Earth Radius in Km
      final query = '''
        SELECT f.id, f.nome, f.logo, f.categorias_fornecedor_id,
          (6371 * 
            acos(
              cos(radians($lat)) *
              cos(radians(ST_X(f.latlng))) *
              cos(radians($lng) - radians(ST_Y(f.latlng))) +
              sin(radians($lat)) *
              sin(radians(ST_X(f.latlng)))
            )) AS distancia
        FROM fornecedor f
        HAVING distancia <= $distance;
      ''';

      final result = await conn.query(query);

      return result
          .map(
            (f) => SupplierNearbyMeDto(
              id: f['id'],
              name: f['nome'],
              logo: (f['logo'] as Blob?)?.toString(),
              distance: f['distancia'],
              categoryId: f['categorias_fornecedor_id'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Error on find suppliers near by me', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
