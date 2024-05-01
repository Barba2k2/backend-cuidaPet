import 'package:injectable/injectable.dart';

import 'I_categories_service.dart';

@LazySingleton(as: ICategoriesService)
class CategoriesService implements ICategoriesService {}
