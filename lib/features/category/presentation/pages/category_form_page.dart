import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/color_picker.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_type_toggle.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoryEntity? category;

  const CategoryFormPage({super.key, this.category});

  bool get isEditing => category != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedIconCode;
  late int _selectedColorValue;
  late TransactionType _selectedType;

  static const _iconOptions = [
    'utensils',
    'car',
    'shoppingBag',
    'gamepad',
    'receipt',
    'gift',
    'wallet',
    'briefCase',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIconCode = widget.category?.iconCode ?? 'utensils';
    _selectedColorValue =
        widget.category?.colorValue ?? AppPalette.defaultCategoryColor;
    _selectedType = widget.category?.type ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => sl<CategoryCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isEditing ? 'Edit Category' : 'New Category'),
              centerTitle: true,
              actions: [
                if (widget.isEditing)
                  IconButton(
                    icon: Icon(AppIcons.trash, color: colorScheme.error),
                    onPressed: () => _confirmDelete(context),
                  ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Type selector
                  Text('Type', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8.0),
                  CategoryTypeToggle(
                    selectedType: _selectedType,
                    onChanged: (type) => setState(() => _selectedType = type),
                  ),
                  const SizedBox(height: 24.0),

                  // Icon selector
                  Text('Icon', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: _iconOptions.map((iconCode) {
                      final isSelected = iconCode == _selectedIconCode;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIconCode = iconCode),
                        child: Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12.0),
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.primary, width: 2)
                                : null,
                          ),
                          child: Icon(
                            AppIcons.fromCode(iconCode),
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24.0),

                  // Color selector
                  Text('Color', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8.0),
                  ColorPicker(
                    selectedColorValue: _selectedColorValue,
                    onColorSelected: (colorValue) =>
                        setState(() => _selectedColorValue = colorValue),
                  ),
                  const SizedBox(height: 24.0),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g., Food, Transport, Shopping',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter category name';
                      }
                      if (value.length > CategoryEntity.maxNameLength) {
                        return 'Name is too long (max ${CategoryEntity.maxNameLength} chars)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),

                  // Save button
                  BlocConsumer<CategoryCubit, CategoryState>(
                    listener: (context, state) {
                      if (state.status == CategoryStatus.success) {
                        context.pop(true);
                      } else if (state.status == CategoryStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(state.errorMessage ?? 'Failed to save'),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state.status == CategoryStatus.loading;
                      return FilledButton(
                        onPressed:
                            isLoading ? null : () => _saveCategory(context),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Save Changes'
                                    : 'Create Category',
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${widget.category!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoryCubit>().removeCategory(widget.category!.uuid);
              context.pop(true);
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

  void _saveCategory(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CategoryCubit>();

    if (widget.isEditing) {
      final updated = widget.category!.copyWith(
        name: _nameController.text.trim(),
        iconCode: _selectedIconCode,
        colorValue: _selectedColorValue,
        type: _selectedType,
      );
      cubit.editCategory(updated);
    } else {
      final newCategory = CategoryEntity(
        uuid: const Uuid().v4(),
        name: _nameController.text.trim(),
        iconCode: _selectedIconCode,
        createdDate: DateTime.now(),
        type: _selectedType,
        colorValue: _selectedColorValue,
      );
      cubit.addCategory(newCategory);
    }
  }
}
