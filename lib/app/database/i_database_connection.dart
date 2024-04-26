import 'package:mysql1/mysql1.dart';

abstract class IDatabaseConnction {
  Future<MySqlConnection> openConnection();
}