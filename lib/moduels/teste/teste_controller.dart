import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'teste_controller.g.dart';

class TesteController {
  @Route.get('/')
  Future<Response> find(Request request) async {
    log('Inciando response');
    final resp = Response.ok(
      jsonEncode({'message': 'Hello World'}),
      // headers: {'content-type': 'application/json'},
    );
    log('Finalizando response');
    return resp;
  }

  Router get router => _$TesteControllerRouter(this);
}
