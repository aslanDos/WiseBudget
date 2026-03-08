import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

class UpdateCategory extends UseCase<CategoryEntity, UpdateCategoryParams> {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(UpdateCategoryParams params) {
    return repository.updateCategory(params.category);
  }
}

class UpdateCategoryParams extends Equatable {
  final CategoryEntity category;

  const UpdateCategoryParams({required this.category});

  @override
  List<Object> get props => [category];
}
