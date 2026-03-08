import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

abstract class CategoryRepository {
  /// Get all categories sorted by sortOrder
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Get category by uuid
  Future<Either<Failure, CategoryEntity>> getCategoryById(String uuid);

  /// Create a new category
  Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity category);

  /// Update an existing category
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);

  /// Delete category by uuid
  Future<Either<Failure, void>> deleteCategory(String uuid);

  /// Seed default categories if none exist
  Future<Either<Failure, void>> seedDefaultCategories();
}
