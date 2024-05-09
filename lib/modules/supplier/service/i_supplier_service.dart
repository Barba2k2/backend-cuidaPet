import '../../../dtos/supplier_nearby_me_dto.dart';
import '../../../entities/supplier.dart';
import '../../../entities/supplier_service.dart';

abstract class ISupplierService {
  Future<List<SupplierNearbyMeDto>> findNearByMe(double lat, double lng);
  Future<Supplier?> findById(int id);
  Future<List<SupplierService>> findServicesBySupplier(int supplierId);
}
