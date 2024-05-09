import 'package:injectable/injectable.dart';

import '../../../dtos/supplier_nearby_me_dto.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart' as entity;
import '../data/i_supplier_repository.dart';
import './i_supplier_service.dart';

@LazySingleton(as: ISupplierService)
class SupplierService implements ISupplierService {
  final ISupplierRepository repository;
  static const DISTANCE = 5;

  SupplierService({
    required this.repository,
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
  Future<bool> checkUserEmailExists(String email) => repository.checkUserEmailExists(email);
}
