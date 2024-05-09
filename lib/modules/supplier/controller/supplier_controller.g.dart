// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$SupplierControllerRouter(SupplierController service) {
  final router = Router();
  router.add(
    'GET',
    r'/',
    service.findNearbyMe,
  );
  router.add(
    'GET',
    r'/<id|[0-9]+>',
    service.findById,
  );
  router.add(
    'GET',
    r'/<supplierId|[0-9]+>/services',
    service.findServicesBySupplierId,
  );
  router.add(
    'GET',
    r'/user',
    service.checkUserExists,
  );
  return router;
}
