import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/constants/icons_constants.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/color_icon_selector.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_name_field.dart';
import 'package:wisebuget/features/category/presentation/widgets/category_sheet_header.dart';

Future<bool?> showCategoryFormModal({
  required BuildContext context,
  CategoryEntity? category,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => CategoryForm(category: category),
  );
}

class CategoryForm extends StatefulWidget {
  final CategoryEntity? category;

  const CategoryForm({super.key, this.category});

  bool get isEditing => category != null;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late String _name;
  late String _selectedIconCode;
  late int _selectedColorValue;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _name = widget.category?.name ?? '';
    _selectedIconCode =
        widget.category?.iconCode ??
        iconOptions[rng.nextInt(iconOptions.length)];
    _selectedColorValue =
        widget.category?.colorValue ??
        AppPalette.colors[rng.nextInt(AppPalette.colors.length)];
    _selectedType = widget.category?.type ?? TransactionType.expense;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);

    return BlocProvider.value(
      value: sl<CategoryCubit>(),
      child: BlocConsumer<CategoryCubit, CategoryState>(
        listenWhen: (previous, current) =>
            previous.status == CubitStatus.loading &&
            current.status != CubitStatus.loading,
        listener: (context, state) {
          if (state.status == CubitStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == CubitStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? context.l10n.failedToSave)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CubitStatus.loading;

          return Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CategorySheetHeader(
                  selectedType: _selectedType,
                  onTypeChanged: (type) => setState(() => _selectedType = type),
                  isEditing: widget.isEditing,
                  onDelete: () => _showDeleteDialog(context),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16.0),
                        Pressable(
                          child: ColoredIconBox(
                            icon: AppIcons.fromCode(_selectedIconCode),
                            color: selectedColor,
                            size: 56.0,
                            padding: 20.0,
                            borderRadius: 24.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        CategoryNameField(
                          name: _name,
                          onNameChanged: (name) => setState(() => _name = name),
                        ),
                        const SizedBox(height: 12.0),
                        ColorIconSelector(
                          selectedColorValue: _selectedColorValue,
                          selectedIconCode: _selectedIconCode,
                          iconOptions: iconOptions,
                          onColorChanged: (value) => setState(() => _selectedColorValue = value),
                          onIconChanged: (code) => setState(() => _selectedIconCode = code),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Button(
                    label: context.l10n.save,
                    isLoading: isLoading,
                    onPressed: isLoading || _name.trim().isEmpty
                        ? null
                        : () => _saveCategory(context),
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteCategory,
      message: context.l10n.areYouSureDeleteCategory,
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      sl<CategoryCubit>().removeCategory(widget.category!.uuid);
    }
  }

  void _saveCategory(BuildContext context) {
    final name = _name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterCategoryName)),
      );
      return;
    }

    final cubit = context.read<CategoryCubit>();

    if (widget.isEditing) {
      cubit.editCategory(
        widget.category!.copyWith(
          name: name,
          iconCode: _selectedIconCode,
          colorValue: _selectedColorValue,
          type: _selectedType,
        ),
      );
    } else {
      cubit.addCategory(
        CategoryEntity(
          uuid: const Uuid().v4(),
          name: name,
          iconCode: _selectedIconCode,
          createdDate: DateTime.now(),
          type: _selectedType,
          colorValue: _selectedColorValue,
        ),
      );
    }
  }
}
