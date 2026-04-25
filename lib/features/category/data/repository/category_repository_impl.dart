import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource.dart';
import 'package:wisebuget/features/category/data/default_categories.dart';
import 'package:wisebuget/features/category/data/model/category_model.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';

final _log = Logger('CategoryRepository');

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get categories: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String uuid) async {
    try {
      final model = await localDataSource.getCategoryByUuid(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Category not found: $uuid'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final created = await localDataSource.createCategory(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to create category: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final updated = await localDataSource.updateCategory(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String uuid) async {
    try {
      await localDataSource.deleteCategory(uuid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      if (categories.isNotEmpty) {
        _log.fine('Categories already exist, skipping seed');
        return const Right(null);
      }

      _log.info('No categories found, creating default categories');

      for (final definition in defaultCategoryDefinitions) {
        final category = CategoryModel(
          uuid: const Uuid().v4(),
          name: definition.name,
          sortOrder: definition.sortOrder,
          iconCode: definition.iconCode,
          type: definition.type.label,
          colorValue: definition.colorValue,
        );
        await localDataSource.createCategory(category);
      }

      _log.info('Default categories created successfully');
      return const Right(null);
    } catch (e) {
      _log.severe('Failed to seed default categories', e);
      return Left(DatabaseFailure('Failed to seed default categories: $e'));
    }
  }
}
