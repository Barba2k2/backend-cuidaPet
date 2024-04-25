import 'package:dotenv/dotenv.dart' show load, env;
import 'package:get_it/get_it.dart';

import '../logger/i_logger.dart';
import '../logger/logger.dart';

import 'databse_conncetion_configuration.dart';

class ApplicationConfig {
  Future<void> loadConfigApplication() async {
    await _loadEnv();
    _loadDatabaseConfig();
    _configLogger();
  }

  Future<void> _loadEnv() async => load();

  void _loadDatabaseConfig() {
    final databseConfig = DatabseConncetionConfiguration(
      host: env['DATABASE_HOST'] ?? env['databaseHost']!,
      user: env['DATABASE_USER'] ?? env['databaseUser']!,
      port: int.tryParse(env['DATABASE_PORT'] ?? env['databasePort']!) ?? 0,
      password: env['DATABASE_PASSWORD'] ?? env['databasePassword']!,
      databaseName: env['DATABASE_NAME'] ?? env['databaseName']!,
    );
    GetIt.I.registerSingleton(databseConfig);
  }

  void _configLogger() =>
      GetIt.I.registerLazySingleton<ILogger>(() => Logger());
}
