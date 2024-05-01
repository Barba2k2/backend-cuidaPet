// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../modules/categories/controller/categories_controller.dart' as _i3;
import '../../modules/categories/data/categories_repository.dart' as _i17;
import '../../modules/categories/data/i_categories_repository.dart' as _i16;
import '../../modules/categories/service/categories_service.dart' as _i5;
import '../../modules/categories/service/i_categories_service.dart' as _i4;
import '../../modules/user/controller/auth_controller.dart' as _i15;
import '../../modules/user/controller/user_controller.dart' as _i14;
import '../../modules/user/data/i_user_repository.dart' as _i9;
import '../../modules/user/data/user_repository.dart' as _i10;
import '../../modules/user/service/I_user_service.dart' as _i12;
import '../../modules/user/service/user_service.dart' as _i13;
import '../database/database_connection.dart' as _i7;
import '../database/i_database_connection.dart' as _i6;
import '../logger/i_logger.dart' as _i11;
import 'database_conncetion_configuration.dart'
    as _i8; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i3.CategoriesController>(
      () => _i3.CategoriesController(service: get<InvalidType>()));
  gh.lazySingleton<_i4.ICategoriesService>(
      () => _i5.CategoriesService(repository: get<InvalidType>()));
  gh.lazySingleton<_i6.IDatabaseConnction>(
      () => _i7.DatabaseConnection(get<_i8.DatabaseConncetionConfiguration>()));
  gh.lazySingleton<_i9.IUserRepository>(() => _i10.UserRepository(
        connection: get<_i6.IDatabaseConnction>(),
        log: get<_i11.ILogger>(),
      ));
  gh.lazySingleton<_i12.IUserService>(() => _i13.UserService(
        userRepository: get<_i9.IUserRepository>(),
        log: get<_i11.ILogger>(),
      ));
  gh.factory<_i14.UserController>(() => _i14.UserController(
        userService: get<_i12.IUserService>(),
        log: get<_i11.ILogger>(),
      ));
  gh.factory<_i15.AuthController>(() => _i15.AuthController(
        userService: get<_i12.IUserService>(),
        log: get<_i11.ILogger>(),
      ));
  gh.lazySingleton<_i16.ICategoriesRepository>(() => _i17.CategoriesRepository(
        connection: get<_i6.IDatabaseConnction>(),
        log: get<_i11.ILogger>(),
      ));
  return get;
}
