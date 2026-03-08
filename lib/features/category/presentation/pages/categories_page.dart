import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_list_tile.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_type_toggle.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..loadCategories(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Frame(
              child: CategoryTypeToggle(
                selectedType: _selectedType,
                onChanged: (type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state.status == CategoryStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = state.categories
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _CategoriesList(
                    categories: categories,
                    onReorder: (oldIndex, newIndex) {
                      _handleReorder(context, categories, oldIndex, newIndex);
                    },
                    onDelete: (category) {
                      _handleDelete(context, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReorder(
    BuildContext context,
    List<CategoryEntity> categories,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final cubit = context.read<CategoryCubit>();
    final reorderedCategories = List<CategoryEntity>.from(categories);
    final movedCategory = reorderedCategories.removeAt(oldIndex);
    reorderedCategories.insert(newIndex, movedCategory);

    // Update sort orders
    for (int i = 0; i < reorderedCategories.length; i++) {
      final category = reorderedCategories[i];
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
}

class _CategoriesList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(CategoryEntity category) onDelete;

  const _CategoriesList({
    required this.categories,
    required this.onReorder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: categories.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final elevation = Tween<double>(begin: 0, end: 4).animate(animation);
            return Material(
              elevation: elevation.value,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryListTile(
          key: ValueKey(category.uuid),
          category: category,
          onDelete: () => onDelete(category),
        );
      },
    );
  }
}
