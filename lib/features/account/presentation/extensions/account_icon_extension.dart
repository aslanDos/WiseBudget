import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

extension AccountIconX on AccountEntity {
  IconData get icon => AppIcons.fromCode(iconCode);
}
