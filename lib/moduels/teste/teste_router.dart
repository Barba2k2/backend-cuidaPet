import 'package:backend/moduels/teste/teste_controller.dart';
import 'package:shelf_router/src/router.dart';

import '../../src/routers/i_router.dart';

class TesteRouter implements IRouter {
  @override
  void configure(Router router) {
    router.mount('/hello/', TesteController().router);
  }
}
