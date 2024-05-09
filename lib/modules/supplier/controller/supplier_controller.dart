import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../app/logger/i_logger.dart';
import '../../../entities/supplier.dart';
import '../service/i_supplier_service.dart';
import '../view_models/create_supplier_view_model.dart';

part 'supplier_controller.g.dart';

@Injectable()
class SupplierController {
  final ISupplierService service;
  final ILogger log;

  SupplierController({
    required this.service,
    required this.log,
  });

  @Route.get('/')
  Future<Response> findNearbyMe(Request request) async {
    try {
      final lat = double.tryParse(request.url.queryParameters['lat'] ?? '');
      final lng = double.tryParse(request.url.queryParameters['lng'] ?? '');

      if (lat == null || lng == null) {
        return Response(
          400,
          body: jsonEncode(
            {
              'message': 'Lat and Lng are required!',
            },
          ),
        );
      }

      final suppliers = await service.findNearByMe(lat, lng);

      final result = suppliers
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'logo': s.logo,
              'distance': s.distance,
              'category': s.categoryId,
            },
          )
          .toList();

      return Response.ok(jsonEncode(result));
    } catch (e, s) {
      log.error('Error on find suppliers nearby me', e, s);
      return Response.internalServerError(
        body: jsonEncode(
          {
            'message': 'Error on find suppliers nearby me',
          },
        ),
      );
    }
  }

  @Route.get('/<id|[0-9]+>')
  Future<Response> findById(Request request, String id) async {
    final supplier = await service.findById(int.parse(id));

    if (supplier == null) {
      return Response.ok(jsonEncode({}));
    }

    return Response.ok(_supplierMapper(supplier));
  }

  String _supplierMapper(Supplier supplier) {
    return jsonEncode(
      {
        'id': supplier.id,
        'name': supplier.name,
        'logo': supplier.logo,
        'phone': supplier.phone,
        'address': supplier.address,
        'lat': supplier.lat,
        'lng': supplier.lng,
        'category': {
          'id': supplier.category?.id,
          'name': supplier.category?.name,
          'type': supplier.category?.type,
        },
      },
    );
  }

  @Route.get('/<supplierId|[0-9]+>/services')
  Future<Response> findServicesBySupplierId(
    Request request,
    String supplierId,
  ) async {
    try {
      final supplierServices = await service.findServicesBySupplier(
        int.parse(supplierId),
      );

      final result = supplierServices
          .map((s) => {
                'id': s.id,
                'supplier_id': s.supplierId,
                'name': s.name,
                'price': s.price,
              })
          .toList();

      return Response.ok(jsonEncode(result));
    } catch (e, s) {
      log.error('Error on find services', e, s);
      return Response.internalServerError(
        body: jsonEncode(
          {
            'message': 'Error on find services',
          },
        ),
      );
    }
  }

  @Route.get('/user')
  Future<Response> checkUserExists(Request request) async {
    final email = request.url.queryParameters['email'];
    if (email == null) {
      return Response(
        400,
        body: jsonEncode(
          {
            'message': 'Email is required',
          },
        ),
      );
    }

    final isEmailExists = await service.checkUserEmailExists(email);

    return isEmailExists ? Response(200) : Response(404);
  }

  @Route.post('/user')
  Future<Response> createUser(Request request) async {
    try {
      final model = CreateSupplierViewModel(await request.readAsString());
      await service.createUserSupplier(model);

      return Response.ok(jsonEncode(''));
    } catch (e, s) {
      log.error('Error on create a new supplier and new user', e, s);
      return Response.internalServerError(
        body: jsonEncode(
          {
            'message': 'Error on create a new supplier and new user',
          },
        ),
      );
    }
  }

  @Route.put('/')
  Future<Response> update(Request request) async {
    try {
      final supplier = int.tryParse(request.headers['supplier'] ?? '');

      if (supplier == null) {
        return Response(
          400,
          body: jsonEncode(
            {
              'message': "Supplier code can't be null",
            },
          ),
        );
      }

      final model = SupplierUpdateInputModel(
        supplierId: supplier,
        dataRequest: await request.readAsString(),
      );

      final supplierResponse = await service.update(model);

      return Response.ok(
        _supplierMapper(supplierResponse),
      );
    } on Exception catch (e, s) {
      log.error('Error on update supplier', e, s);
      return Response.internalServerError();
    }
  }

  Router get router => _$SupplierControllerRouter(this);
}
