import '../../../dtos/supplier_nearby_me_dto.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart';

abstract class ISupplierRepository {
  Future<List<SupplierNearbyMeDto>> findNearbyPosition(
    double lat,
    double lng,
    int distance,
  );
  Future<Supplier?> findById(int id);
  Future<List<SupplierService>> findServicesBySupplierId(int supplierId);
}
