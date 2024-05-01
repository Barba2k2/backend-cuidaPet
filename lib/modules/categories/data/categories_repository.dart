import "package:injectable/injectable.dart";
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/exceptions/databse_exceptions.dart';
import '../../../app/logger/i_logger.dart';
import '../../../entities/category.dart';
import 'i_categories_repository.dart';

@LazySingleton(as: ICategoriesRepository)
class CategoriesRepository implements ICategoriesRepository {
  IDatabaseConnction connection;
  ILogger log;

  CategoriesRepository({
    required this.connection,
    required this.log,
  });

  @override
  Future<List<Category>> findAll() async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result = await conn.query('SELECT * FROM categorias_fornecedor');

      if (result.isNotEmpty) {
        return result
            .map(
              (e) => Category(
                id: e['id'],
                name: e['nome_categoria'],
                type: e['tipo_categoria'],
              ),
            )
            .toList();
      }

      return [];
    } on MySqlException catch (e, s) {
      log.error('Error on find supplier categories', e, s);
      throw DatabseExceptions();
    } finally {
      await conn?.close();
    }
  }
}
