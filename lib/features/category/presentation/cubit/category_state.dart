import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryState extends Equatable {
  final CubitStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  const CategoryState({
    this.status = CubitStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  CategoryState copyWith({
    CubitStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
