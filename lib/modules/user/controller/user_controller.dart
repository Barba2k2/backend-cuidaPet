// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../app/exceptions/user_not_found_exception.dart';
import '../../../app/logger/i_logger.dart';
import '../service/I_user_service.dart';

part 'user_controller.g.dart';

@Injectable()
class UserController {
  IUserService userService;
  ILogger log;

  UserController({
    required this.userService,
    required this.log,
  });

  @Route.get('/')
  Future<Response> findByToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final userData = await userService.findById(user);

      return Response.ok(
        jsonEncode(
          {
            'email': userData.email,
            'register_type': userData.registerType,
            'img_avatar': userData.imageAvatar,
          },
        ),
      );
    } on UserNotFoundException {
      return Response(204, body: jsonEncode(''));
    } catch (e, s) {
      log.error('Error on finding user', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Error on finding user!'}));
    }
  }

  Router get router => _$UserControllerRouter(this);
}
