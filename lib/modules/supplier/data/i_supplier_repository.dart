import '../../../dtos/supplier_nearby_me_dto.dart';

abstract class ISupplierRepository {
  Future<List<SupplierNearbyMeDto>> findNearbyPosition(double lat, double lng, int distance);
}