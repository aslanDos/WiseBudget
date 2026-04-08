import 'package:flutter/material.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_card.dart';

class CategoriesList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(CategoryEntity category) onDelete;
  final void Function(CategoryEntity category) onEdit;
  final void Function(CategoryEntity category) onToggleVisibility;

  const CategoriesList({
    super.key,
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
