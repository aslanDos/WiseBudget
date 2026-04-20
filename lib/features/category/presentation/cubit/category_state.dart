import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/cubit/list_cubit_state.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryState extends ListCubitState<CategoryEntity> {
  const CategoryState({
    super.status,
    List<CategoryEntity> categories = const [],
    super.errorMessage,
  }) : super(items: categories);

  List<CategoryEntity> get categories => items;

  CategoryState copyWith({
    CubitStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
  }) => CategoryState(
    status: status ?? this.status,
    categories: categories ?? items,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
