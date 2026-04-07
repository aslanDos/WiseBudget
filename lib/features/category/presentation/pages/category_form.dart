import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

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

  static const _iconOptions = [
    'utensils',
    'shoppingBag',
    'shoppingCart',
    'receipt',
    'car',
    'bus',
    'plane',
    'bike',
    'home',
    'building',
    'briefCase',
    'wallet',
    'gamepad',
    'music',
    'heart',
    'star',
    'coffee',
    'gift',
    'book',
    'graduationCap',
    'phone',
    'laptop',
    'dumbbell',
    'stethoscope',
    'zap',
    'globe',
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _name = widget.category?.name ?? '';
    _selectedIconCode =
        widget.category?.iconCode ??
        _iconOptions[rng.nextInt(_iconOptions.length)];
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
            previous.status == CategoryStatus.loading &&
            current.status != CategoryStatus.loading,
        listener: (context, state) {
          if (state.status == CategoryStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == CategoryStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CategoryStatus.loading;

          return Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CategoryFormHeader(
                  isEditing: widget.isEditing,
                  selectedType: _selectedType,
                  onTypeChanged: (type) => setState(() => _selectedType = type),
                  onDelete: () => _confirmDelete(context),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16.0),
                        Center(
                          child: ColoredIconBox(
                            icon: AppIcons.fromCode(_selectedIconCode),
                            color: selectedColor,
                            size: 56.0,
                            padding: 20.0,
                            borderRadius: 24.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _NameField(
                          name: _name,
                          onNameChanged: (name) => setState(() => _name = name),
                        ),
                        const SizedBox(height: 12.0),
                        _FormSection(
                          title: 'Color',
                          actionLabel: 'More colors',
                          child: _ColorGrid(
                            selectedColorValue: _selectedColorValue,
                            onColorSelected: (value) =>
                                setState(() => _selectedColorValue = value),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        _FormSection(
                          title: 'Icon',
                          actionLabel: 'More icons',
                          child: _IconGrid(
                            iconOptions: _iconOptions,
                            selectedIconCode: _selectedIconCode,
                            selectedColor: selectedColor,
                            onIconSelected: (code) =>
                                setState(() => _selectedIconCode = code),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Button(
                    label: widget.isEditing ? 'Save Changes' : 'Save',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _saveCategory(context),
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
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
        content: Text(
          'Are you sure you want to delete "${widget.category!.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoryCubit>().removeCategory(
                widget.category!.uuid,
              );
              Navigator.pop(context, true);
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
    final name = _name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
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

// ── Constants ────────────────────────────────────────────────────────────────

const int _kGridColumns = 6;
const double _kGridSpacing = 10;

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CategoryFormHeader extends StatelessWidget {
  final bool isEditing;
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final VoidCallback onDelete;

  const _CategoryFormHeader({
    required this.isEditing,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onDelete,
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
            if (isEditing)
              CircleIconButton(
                icon: AppIcons.trash,
                onTap: onDelete,
                iconColor: Theme.of(context).colorScheme.error,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final String name;
  final ValueChanged<String> onNameChanged;

  const _NameField({required this.name, required this.onNameChanged});

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: Icons.text_fields_rounded,
      label: name.isEmpty ? 'Category name' : name,
      iconColor: name.isEmpty ? context.c.onSecondary : context.c.onSurface,
      backgroundColor: context.c.surfaceContainer,
      shrink: false,
      onTap: () => _showInput(context),
    );
  }

  Future<void> _showInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: name,
      hintText: 'Category name',
      maxLength: CategoryEntity.maxNameLength,
    );
    if (result != null) onNameChanged(result);
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Widget child;

  const _FormSection({
    required this.title,
    this.actionLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: context.t.titleMedium),
              if (actionLabel != null)
                TextButton.icon(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text(
                    actionLabel!,
                    style: context.t.bodySmall?.copyWith(
                      color: context.c.onSecondary,
                    ),
                  ),
                  icon: Icon(
                    AppIcons.chevronRight,
                    size: 14,
                    color: context.c.onSecondary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const _ColorGrid({
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _kGridColumns,
        mainAxisSpacing: _kGridSpacing,
        crossAxisSpacing: _kGridSpacing,
      ),
      itemCount: (AppPalette.colors.length).clamp(0, _kGridColumns * 2),
      itemBuilder: (context, index) {
        final colorValue = AppPalette.colors[index];
        final color = Color(colorValue);
        final isSelected = colorValue == selectedColorValue;

        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.5,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _IconGrid extends StatelessWidget {
  final List<String> iconOptions;
  final String selectedIconCode;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;

  const _IconGrid({
    required this.iconOptions,
    required this.selectedIconCode,
    required this.selectedColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _kGridColumns,
        mainAxisSpacing: _kGridSpacing,
        crossAxisSpacing: _kGridSpacing,
      ),
      itemCount: iconOptions.length.clamp(0, _kGridColumns * 2),
      itemBuilder: (context, index) {
        final iconCode = iconOptions[index];
        final isSelected = iconCode == selectedIconCode;

        return GestureDetector(
          onTap: () => onIconSelected(iconCode),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.fromCode(iconCode),
              size: 20,
              color: isSelected
                  ? (selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : context.c.onSecondary,
            ),
          ),
        );
      },
    );
  }
}
