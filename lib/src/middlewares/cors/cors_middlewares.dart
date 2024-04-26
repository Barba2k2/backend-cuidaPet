import 'dart:io';

import 'package:shelf/src/handler.dart';
import 'package:shelf/src/response.dart';
import 'package:shelf/src/request.dart';

import '../middlewares.dart';

class CorsMiddlewares implements Middlewares {
  final Map<String, String> headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        '${HttpHeaders.contentTypeHeader}, ${HttpHeaders.authorizationHeader}',
  };

  // @override
  // Handler innerHandler;

  @override
  Future<Response> execute(Request request) async {
    if(request.method == 'OPTIONS') {
      return Response(HttpStatus.ok, headers: headers);
    }

    final response = await innerHandler(request);
    return response.change(headers: headers);
  }

  @override
  Handler handler(Handler innerHandler) {
    throw UnimplementedError();
  }
}
