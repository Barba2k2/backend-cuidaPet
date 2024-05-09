import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:injectable/injectable.dart';

import '../../../dtos/supplier_nearby_me_dto.dart';
import '../../../entities/category.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart' as entity;
import '../../user/service/i_user_service.dart';
import '../../user/view_models/user_save_input_model.dart';
import '../data/i_supplier_repository.dart';
import '../view_models/create_supplier_view_model.dart';
import './i_supplier_service.dart';

@LazySingleton(as: ISupplierService)
class SupplierService implements ISupplierService {
  final ISupplierRepository repository;
  final IUserService userService;

  static const DISTANCE = 5;

  SupplierService({
    required this.repository,
    required this.userService,
  });

  @override
  Future<List<SupplierNearbyMeDto>> findNearByMe(double lat, double lng) =>
      repository.findNearbyPosition(
        lat,
        lng,
        DISTANCE,
      );

  @override
  Future<Supplier?> findById(int id) => repository.findById(id);

  @override
  Future<List<entity.SupplierService>> findServicesBySupplier(int supplierId) =>
      repository.findServicesBySupplierId(supplierId);

  @override
  Future<bool> checkUserEmailExists(String email) =>
      repository.checkUserEmailExists(email);

  Future<void> createUserSupplier(CreateSupplierViewModel model) async {
    final supplierEntity = Supplier(
      name: model.supplierNmae,
      category: Category(id: model.category),
    );

    final supplierId = await repository.saveSupplier(supplierEntity);

    final userInputModel = UserSaveInputModel(
      email: model.email,
      password: model.password,
      supplierId: supplierId,
    );

    await userService.createUser(userInputModel);
  }

  @override
  Future<Supplier> update(SupplierUpdateInputModel model) async {
    var supplier = Supplier(
      id: model.supplierId,
      name: model.name,
      address: model.address,
      lat: model.lat,
      lng: model.lng,
      logo: model.logo,
      phone: model.phone,
      category: Category(id: model.categoryId),
    );

    return await repository.update(supplier);
  }
}
