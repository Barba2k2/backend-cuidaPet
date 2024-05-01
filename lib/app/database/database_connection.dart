import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../config/databse_conncetion_configuration.dart';
import 'i_database_connection.dart';

@LazySingleton(as: IDatabaseConnction)
class DatabaseConnection implements IDatabaseConnction {
  final DatabseConncetionConfiguration _configuration;

  DatabaseConnection(this._configuration);

  @override
  Future<MySqlConnection> openConnection() {
    return MySqlConnection.connect(
      ConnectionSettings(
        host: _configuration.host,
        port: _configuration.port,
        user: _configuration.user,
        password: _configuration.password,
        db: _configuration.databaseName,
      ),
    );
  }
}
