import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/pages/category_form.dart';
import 'package:wisebuget/features/category/presentation/widgets/categories_list.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_sheet_header.dart';

Future<void> showCategoriesModal({required BuildContext context}) {
  return showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    barrierColor: Colors.black54,
    builder: (context) => const CategoriesPage(),
  );
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    sl<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CategoryCubit>(),
      child: Material(
        child: Column(
          children: [
            CategorySheetHeader(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
              trailing: CircleIconButton(
                icon: AppIcons.add,
                onTap: () => _navigateToCategoryForm(context),
              ),
            ),
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state.status == CubitStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories =
                      state.categories
                          .where((c) => c.type == _selectedType)
                          .toList()
                        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  if (categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.empty,
                            size: 48.0,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No ${_selectedType.value} categories',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return CategoriesList(
                    categories: categories,
                    onReorder: (oldIndex, newIndex) =>
                        _handleReorder(context, categories, oldIndex, newIndex),
                    onDelete: (category) => _handleDelete(context, category),
                    onEdit: (category) =>
                        _navigateToCategoryForm(context, category: category),
                    onToggleVisibility: (category) =>
                        _handleToggleVisibility(context, category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToCategoryForm(
    BuildContext context, {
    CategoryEntity? category,
  }) async {
    final result = await showCategoryFormModal(
      context: context,
      category: category,
    );
    if (result == true && context.mounted) {
      context.read<CategoryCubit>().loadCategories();
    }
  }

  void _handleReorder(
    BuildContext context,
    List<CategoryEntity> categories,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) newIndex -= 1;

    final cubit = context.read<CategoryCubit>();
    final reordered = List<CategoryEntity>.from(categories);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    for (int i = 0; i < reordered.length; i++) {
      final category = reordered[i];
      if (category.sortOrder != i) {
        cubit.editCategory(category.copyWith(sortOrder: i));
      }
    }
  }

  void _handleDelete(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryCubit>().removeCategory(category.uuid);
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleToggleVisibility(BuildContext context, CategoryEntity category) {
    context.read<CategoryCubit>().editCategory(
      category.copyWith(visible: !category.visible),
    );
  }
}
