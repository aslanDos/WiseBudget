import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/usecases/category_usecases.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

final _log = Logger('CategoryCubit');

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final SeedDefaultCategories _seedDefaultCategories;

  CategoryCubit({
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
    required SeedDefaultCategories seedDefaultCategories,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        _seedDefaultCategories = seedDefaultCategories,
        super(const CategoryState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading));

    final result = await _getCategories(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: failure.message,
      )),
      (categories) => emit(state.copyWith(
        status: CategoryStatus.success,
        categories: categories,
      )),
    );
  }

  Future<void> addCategory(CategoryEntity category) async {
    final result = await _createCategory(CreateCategoryParams(category: category));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: failure.message,
      )),
      (created) => emit(state.copyWith(
        status: CategoryStatus.success,
        categories: [...state.categories, created],
      )),
    );
  }

  Future<void> editCategory(CategoryEntity category) async {
    final result = await _updateCategory(UpdateCategoryParams(category: category));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedList = state.categories.map((c) {
          return c.uuid == updated.uuid ? updated : c;
        }).toList();
        emit(state.copyWith(
          status: CategoryStatus.success,
          categories: updatedList,
        ));
      },
    );
  }

  Future<void> removeCategory(String uuid) async {
    final result = await _deleteCategory(DeleteCategoryParams(uuid: uuid));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedList = state.categories.where((c) => c.uuid != uuid).toList();
        emit(state.copyWith(
          status: CategoryStatus.success,
          categories: updatedList,
        ));
      },
    );
  }

  Future<void> seedDefaultCategories() async {
    _log.fine('Requesting default categories seed');
    final result = await _seedDefaultCategories(const NoParams());
    result.fold(
      (failure) => _log.warning('Seed default categories failed: ${failure.message}'),
      (_) => _log.fine('Seed default categories completed'),
    );
  }
}
