import 'package:injectable/injectable.dart';

import '../../../entities/schedule.dart';
import '../../../entities/schedule_supplier_service.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart';
import '../data/i_schedule_repository.dart';
import '../view_models/schedule_save_input_model.dart';
import './i_schedule_service.dart';

@Injectable(as: IScheduleService)
class ScheduleService implements IScheduleService {
  final IScheduleRepository repository;

  ScheduleService({
    required this.repository,
  });

  @override
  Future<void> scheduleService(ScheduleSaveInputModel model) async {
    final schedule = Schedule(
      scheduleDate: model.scheduleDate,
      name: model.name,
      petName: model.petName,
      supplier: Supplier(id: model.supplierId),
      status: 'P',
      userId: model.userId,
      services: model.services
          .map(
            (e) => ScheduleSupplierService(
              service: SupplierService(id: e),
            ),
          )
          .toList(),
    );

    await repository.save(schedule);
  }

  @override
  Future<void> changeStatus(String status, int scheduleId) =>
      repository.changeStatus(
        status,
        scheduleId,
      );
}
