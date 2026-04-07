import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/pages/category_form.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_card.dart';

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
            _CategoriesHeader(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
              onAdd: () => _navigateToCategoryForm(context),
            ),
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state.status == CategoryStatus.loading) {
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

                  return _CategoriesList(
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

class _CategoriesHeader extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final VoidCallback onAdd;

  const _CategoriesHeader({
    required this.selectedType,
    required this.onTypeChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.c.onSurface.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleIconButton(
              icon: AppIcons.close,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TypeToggle<TransactionType>(
                    items: TransactionType.values
                        .where((t) => t != TransactionType.transfer)
                        .map(
                          (t) => TypeToggleItem(
                            value: t,
                            label: t.label,
                            icon: t.icon,
                            selectedBackgroundColor: t.actionBackgroundColor(
                              context,
                            ),
                            selectedForegroundColor: t.actionColor(context),
                          ),
                        )
                        .toList(),
                    selected: selectedType,
                    onChanged: onTypeChanged,
                  ),
                ),
              ),
            ),
            CircleIconButton(icon: AppIcons.add, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(CategoryEntity category) onDelete;
  final void Function(CategoryEntity category) onEdit;
  final void Function(CategoryEntity category) onToggleVisibility;

  const _CategoriesList({
    required this.categories,
    required this.onReorder,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: categories.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Material(
          elevation: Tween<double>(begin: 0, end: 4).animate(animation).value,
          borderRadius: BorderRadius.circular(12.0),
          child: child,
        ),
        child: child,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          key: ValueKey(category.uuid),
          category: category,
          onTap: () => onEdit(category),
          onDelete: () => onDelete(category),
          onToggleVisibility: () => onToggleVisibility(category),
        );
      },
    );
  }
}
