import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountNameField extends StatelessWidget {
  final String name;
  final ValueChanged<String> onNameChanged;

  const AccountNameField({
    super.key,
    required this.name,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: Icons.text_fields_rounded,
      label: name.isEmpty ? 'Account name' : name,
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
      hintText: 'Account name',
      maxLength: AccountEntity.maxNameLength,
    );
    if (result != null) onNameChanged(result);
  }
}
