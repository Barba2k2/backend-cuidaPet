import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/exceptions/database_exceptions.dart';
import '../../../app/logger/i_logger.dart';
import '../../../dtos/supplier_nearby_me_dto.dart';
import '../../../entities/category.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart';
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

  @override
  Future<Supplier?> findById(int id) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT 
            f.id, 
            f.nome, 
            f.logo, 
            f.endereco, 
            f.telefone, 
            ST_X(f.latlng) as lat,
            ST_X(f.latlng) as lng, 
            f.categorias_fornecedor_id,
            c.nome_categoria,
            c.tipo_categoria
        FROM fornecedor AS f
        INNER JOIN categorias_fornecedor AS c 
        ON (f.categorias_fornecedor_id = c.id)
        WHERE f.id = ?
      ''';

      final result = await conn.query(query, [id]);

      if (result.isNotEmpty) {
        final dataSql = result.first;
        return Supplier(
          id: dataSql['id'],
          name: dataSql['nome'],
          logo: (dataSql['logo'] as Blob?)?.toString(),
          address: dataSql['endereco'],
          phone: dataSql['telefone'],
          lat: dataSql['lat'],
          lng: dataSql['lng'],
          category: Category(
            id: dataSql['categorias_fornecedor_id'],
            name: dataSql['nome_categoria'],
            type: dataSql['tipo_categoria'],
          ),
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Error on find supplier', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<SupplierService>> findServicesBySupplierId(int supplierId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final query = '''
        SELECT
          id,
          fornecedor_id,
          nome_servico,
          valor_servico
        FROM fornecedor_servicos
        WHERE fornecedor_id = ?
      ''';

      final result = await conn.query(
        query,
        [
          supplierId,
        ],
      );

      if (result.isEmpty) {
        return [];
      }

      return result
          .map(
            (s) => SupplierService(
              id: s['id'],
              supplierId: s['fornecedor_id'],
              name: s['nome_servico'],
              price: s['valor_servico'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Error on find services of supplier', e, s);
      throw DatabaseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
