import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

/// Shows a multi-select modal for categories
Future<List<String>?> showCategoryMultiSelect({
  required BuildContext context,
  required List<CategoryEntity> categories,
  required List<String> selectedUuids,
  String title = 'Select Categories',
}) {
  return showModal<List<String>>(
    context: context,
    builder: (context) => _CategoryMultiSelectSheet(
      categories: categories,
      selectedUuids: selectedUuids,
      title: title,
    ),
  );
}

class _CategoryMultiSelectSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final List<String> selectedUuids;
  final String title;

  const _CategoryMultiSelectSheet({
    required this.categories,
    required this.selectedUuids,
    required this.title,
  });

  @override
  State<_CategoryMultiSelectSheet> createState() =>
      _CategoryMultiSelectSheetState();
}

class _CategoryMultiSelectSheetState extends State<_CategoryMultiSelectSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedUuids);
  }

  void _toggleCategory(String uuid) {
    setState(() {
      if (_selected.contains(uuid)) {
        _selected.remove(uuid);
      } else {
        _selected.add(uuid);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selected = widget.categories.map((c) => c.uuid).toSet();
    });
  }

  void _clearAll() {
    setState(() {
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ModalSheet.scrollable(
      title: Text(widget.title),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _selected.isEmpty ? null : _clearAll,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected.toList()),
                child: Text('Done (${_selected.length})'),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Select all option
          ListTile(
            leading: Icon(
              Icons.select_all_rounded,
              color: colors.primary,
            ),
            title: const Text('Select All'),
            onTap: _selectAll,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),

          // Category list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = _selected.contains(category.uuid);
              final color = AppPalette.fromValue(
                category.colorValue,
                defaultColor: colors.primary,
              );

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(0x26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.fromCode(category.iconCode),
                    color: color,
                    size: 22,
                  ),
                ),
                title: Text(category.name),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleCategory(category.uuid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () => _toggleCategory(category.uuid),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              );
            },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Chip widget for displaying selected categories
class CategoryChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  final List<String> selectedUuids;
  final VoidCallback? onTap;
  final bool showAddButton;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedUuids,
    this.onTap,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final selectedCategories = categories
        .where((c) => selectedUuids.contains(c.uuid))
        .toList();

    if (selectedCategories.isEmpty && !showAddButton) {
      return Text(
        'All categories',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in selectedCategories)
          _CategoryChip(category: category),
        if (showAddButton)
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text(selectedCategories.isEmpty ? 'Select' : 'Add'),
            onPressed: onTap,
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = AppPalette.fromValue(
      category.colorValue,
      defaultColor: colors.primary,
    );

    return Chip(
      avatar: Icon(
        AppIcons.fromCode(category.iconCode),
        size: 18,
        color: color,
      ),
      label: Text(category.name),
      backgroundColor: color.withAlpha(0x1A),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
