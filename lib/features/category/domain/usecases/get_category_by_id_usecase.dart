import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

class GetCategoryById extends UseCase<CategoryEntity, GetCategoryByIdParams> {
  final CategoryRepository repository;

  GetCategoryById(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(GetCategoryByIdParams params) {
    return repository.getCategoryById(params.uuid);
  }
}

class GetCategoryByIdParams extends Equatable {
  final String uuid;

  const GetCategoryByIdParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
