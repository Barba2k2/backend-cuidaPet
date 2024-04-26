// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../modules/user/controller/auth_controller.dart' as _i3;
import '../database/database_connection.dart' as _i5;
import '../database/i_database_connection.dart' as _i4;
import 'databse_conncetion_configuration.dart'
    as _i6; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(
  _i1.GetIt get, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    get,
    environment,
    environmentFilter,
  );
  gh.factory<_i3.AuthController>(() => _i3.AuthController());
  gh.lazySingleton<_i4.IDatabaseConnction>(
      () => _i5.DatabaseConnection(get<_i6.DatabseConncetionConfiguration>()));
  return get;
}
