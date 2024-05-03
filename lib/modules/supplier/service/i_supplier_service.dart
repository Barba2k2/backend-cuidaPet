import '../../../dtos/supplier_nearby_me_dto.dart';

abstract class ISupplierService {
  Future<List<SupplierNearbyMeDto>> findNearByMe(double lat, double lng);
}
