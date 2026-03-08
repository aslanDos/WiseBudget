import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

class DeleteCategory extends UseCase<void, DeleteCategoryParams> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) {
    return repository.deleteCategory(params.uuid);
  }
}

class DeleteCategoryParams extends Equatable {
  final String uuid;

  const DeleteCategoryParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
