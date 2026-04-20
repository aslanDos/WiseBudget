import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/utils/list_utils.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/pages/category_form.dart';
import 'package:wisebuget/features/category/presentation/widgets/categories_list.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_sheet_header.dart';

Future<void> showCategoriesModal({required BuildContext context}) {
  return showCupertinoModalBottomSheet(
    context: context,
    expand: false,
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
              onDelete: () => _openCategoryForm(context),
              isEditing: true,
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
                            context.l10n.noCategoriesOfType(_selectedType.l10nLabel(context.l10n)),
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
                        _openCategoryForm(context, category: category),
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

  Future<void> _openCategoryForm(
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
    final reordered = applyReorder(categories, oldIndex, newIndex);
    final cubit = context.read<CategoryCubit>();
    for (int i = 0; i < reordered.length; i++) {
      final category = reordered[i];
      if (category.sortOrder != i) cubit.editCategory(category.copyWith(sortOrder: i));
    }
  }

  Future<void> _handleDelete(BuildContext context, CategoryEntity category) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteCategory,
      message: context.l10n.areYouSureDeleteNamed(category.name),
      confirmText: context.l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CategoryCubit>().removeCategory(category.uuid);
    }
  }

  void _handleToggleVisibility(BuildContext context, CategoryEntity category) {
    context.read<CategoryCubit>().editCategory(
      category.copyWith(visible: !category.visible),
    );
  }
}
