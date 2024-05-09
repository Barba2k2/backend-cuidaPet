import '../../../app/helpers/request_mapping.dart';

class CreateSupplierViewModel extends RequestMapping {
  late String supplierNmae;
  late String email;
  late String password;
  late int category;

  CreateSupplierViewModel(String dataRequest) : super(dataRequest);

  @override
  void map() {
    supplierNmae = data['supplier_name'];
    email = data['email'];
    password = data['password'];
    category = data['category_id'];
  }
}
