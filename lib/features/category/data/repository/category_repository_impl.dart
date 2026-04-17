import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource.dart';
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

      final defaultCategories = [
        // Expense categories
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Food & Drinks',
          sortOrder: 0,
          iconCode: 'utensils',
          type: TransactionType.expense.label,
          colorValue: 0xFFEF5350,
        ),
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Transport',
          sortOrder: 1,
          iconCode: 'car',
          type: TransactionType.expense.label,
          colorValue: 0xFFEC407A,
        ),
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Shopping',
          sortOrder: 2,
          iconCode: 'shoppingBag',
          type: TransactionType.expense.label,
          colorValue: 0xFFAB47BC,
        ),
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Entertainment',
          sortOrder: 3,
          iconCode: 'gamepad',
          type: TransactionType.expense.label,
          colorValue: 0xFF7E57C2,
        ),
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Bills',
          sortOrder: 4,
          iconCode: 'receipt',
          type: TransactionType.expense.label,
          colorValue: 0xFF5C6BC0,
        ),
        // Income categories
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Salary',
          sortOrder: 0,
          iconCode: 'briefCase',
          type: TransactionType.income.label,
          colorValue: 0xFF42A5F5,
        ),
        CategoryModel(
          uuid: const Uuid().v4(),
          name: 'Gift',
          sortOrder: 1,
          iconCode: 'gift',
          type: TransactionType.income.label,
          colorValue: 0xFF29B6F6,
        ),
      ];

      for (final category in defaultCategories) {
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
