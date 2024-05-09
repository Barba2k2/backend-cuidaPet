import '../../../app/helpers/request_mapping.dart';

class ScheduleSaveInputModel extends RequestMapping {
  int userId;
  late DateTime scheduleDate;
  late int supplierId;
  late String name;
  late String petName;
  late List<int> services;

  ScheduleSaveInputModel({
    required this.userId,
    required String dataRequest,
  }) : super(dataRequest);

  @override
  void map() {
    // 2024-04-10T10:00:00
    scheduleDate = DateTime.parse(data['schedule_data']);
    supplierId = data['supplier_id'];
    services = List.castFrom<dynamic, int>(data['services']);
    name = data['name'];
    petName = data['pet_name'];
  }
}
