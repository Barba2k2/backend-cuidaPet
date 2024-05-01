import 'package:injectable/injectable.dart';

import 'I_categories_repository.dart';

@LazySingleton(as: ICategoriesRepository)
class CategoriesRepository implements ICategoriesRepository {}
