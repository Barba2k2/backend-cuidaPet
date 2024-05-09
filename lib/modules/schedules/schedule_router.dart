import 'package:get_it/get_it.dart';
import 'package:shelf_router/src/router.dart';

import '../../app/routers/i_router.dart';
import 'controller/schedule_controller.dart';

class ScheduleRouter implements IRouter {
  @override
  void configure(Router router) {
    final scheduleController = GetIt.I.get<ScheduleController>();

    router.mount('/schedules/', scheduleController.router);
  }
}
