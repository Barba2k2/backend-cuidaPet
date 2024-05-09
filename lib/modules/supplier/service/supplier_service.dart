import 'package:cuidapet_api/entities/supplier.dart';
import 'package:injectable/injectable.dart';

import '../../../dtos/supplier_nearby_me_dto.dart';
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
}
