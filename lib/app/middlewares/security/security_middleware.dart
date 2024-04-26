import 'dart:convert';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/src/request.dart';
import 'package:shelf/src/response.dart';

import '../../helpers/jwt_helper.dart';
import '../../logger/i_logger.dart';
import '../middlewares.dart';
import 'security_skip_url.dart';

class SecurityMiddleware extends Middlewares {
  final ILogger log;
  final skipUrl = <SecuritySkipUrl>[
    SecuritySkipUrl(
      url: '/auth',
      method: 'POST',
    ),
  ];

  SecurityMiddleware(this.log);

  @override
  Future<Response> execute(Request request) async {
    try {
      if (skipUrl.contains(
        SecuritySkipUrl(
          url: '/${request.url.path}',
          method: request.method,
        ),
      )) {
        return innerHandler(request);
      }

      final authHeader = request.headers['Authorization'];

      if (authHeader == null || authHeader.isEmpty) {
        throw JwtException.invalidToken;
      }

      final authHeaderContent = authHeader.split(' ');

      if (authHeaderContent[0] != 'Bearer') {
        throw JwtException.invalidToken;
      }

      final authorizationToken = authHeaderContent[1];
      final claims = JwtHelper.getClaims(authorizationToken);

      if (request.url.path != 'auth/refresh') {
        claims.validate();
      }

      final claimsMap = claims.toJson();

      final userId = claimsMap['sub'];
      final supllierId = claimsMap['supllier'];

      if (userId == null) {
        throw JwtException.invalidToken;
      }

      final securityHeaders = {
        'user': userId,
        'access_token': authorizationToken,
        'supllier': supllierId,
      };

      return innerHandler(
        request.change(headers: securityHeaders),
      );
    } on JwtException catch (e, s) {
      log.error('Error to validate JWT token', e, s);
      return Response.forbidden(jsonEncode({}));
    } catch (e, s) {
      log.error('Internal Server Error', e, s);
      return Response.forbidden(jsonEncode({}));
    }
  }
}