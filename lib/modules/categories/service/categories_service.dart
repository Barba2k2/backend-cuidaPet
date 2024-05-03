import 'package:injectable/injectable.dart';

import '../../../entities/category.dart';
import '../data/I_categories_repository.dart';

import './i_categories_service.dart';

@LazySingleton(as: ICategoriesService)
class CategoriesService implements ICategoriesService {
  ICategoriesRepository repository;

  CategoriesService({
    required this.repository,
  });

  @override
  Future<List<Category>> findAll() => repository.findAll();
}
