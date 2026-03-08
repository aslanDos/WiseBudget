import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

class CreateCategory extends UseCase<CategoryEntity, CreateCategoryParams> {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(CreateCategoryParams params) {
    return repository.createCategory(params.category);
  }
}

class CreateCategoryParams extends Equatable {
  final CategoryEntity category;

  const CreateCategoryParams({required this.category});

  @override
  List<Object> get props => [category];
}
