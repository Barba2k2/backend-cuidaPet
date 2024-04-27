import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../app/exceptions/user_exists_exception.dart';
import '../../../app/logger/i_logger.dart';
import '../service/I_user_service.dart';
import '../view_models/user_save_input_model.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  IUserService userService;
  ILogger log;

  AuthController({
    required this.userService,
    required this.log,
  });

  @Route.post('/register')
  Future<Response> saveUser(Request request) async {
    try {
      final userModel = UserSaveInputModel(await request.readAsString());

      await userService.createUser(userModel);

      return Response.ok(
        jsonEncode(
          {'message': 'User created successfully'},
        ),
      );
    } on UserExistsException {
      return Response(
        400,
        body: jsonEncode(
          {'message': 'User already exists on database'},
        ),
      );
    } catch (e) {
      log.error('Error on register user', e);
      return Response.internalServerError();
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
