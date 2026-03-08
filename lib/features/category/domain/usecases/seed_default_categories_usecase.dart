import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

class SeedDefaultCategories extends UseCase<void, NoParams> {
  final CategoryRepository repository;

  SeedDefaultCategories(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.seedDefaultCategories();
  }
}
