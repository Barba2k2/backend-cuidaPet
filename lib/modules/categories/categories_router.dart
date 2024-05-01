import 'package:get_it/get_it.dart';
import 'package:shelf_router/src/router.dart';

import '../../app/routers/i_router.dart';
import 'controller/categories_controller.dart';

class CategoriesRouter implements IRouter {
  @override
  void configure(Router router) {
    final categoireController = GetIt.I.get<CategoriesController>();

    router.mount('/categories', categoireController.router);
  }
}
