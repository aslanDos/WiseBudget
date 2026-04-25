import 'package:wisebuget/core/constants/app_enums.dart';

class DefaultCategoryDefinition {
  final String name;
  final int sortOrder;
  final String iconCode;
  final TransactionType type;
  final int colorValue;

  const DefaultCategoryDefinition({
    required this.name,
    required this.sortOrder,
    required this.iconCode,
    required this.type,
    required this.colorValue,
  });
}

const defaultCategoryDefinitions = [
  DefaultCategoryDefinition(
    name: 'Food & Drinks',
    sortOrder: 0,
    iconCode: 'utensils',
    type: TransactionType.expense,
    colorValue: 0xFFEF5350,
  ),
  DefaultCategoryDefinition(
    name: 'Transport',
    sortOrder: 1,
    iconCode: 'car',
    type: TransactionType.expense,
    colorValue: 0xFFEC407A,
  ),
  DefaultCategoryDefinition(
    name: 'Groceries',
    sortOrder: 2,
    iconCode: 'shoppingCart',
    type: TransactionType.expense,
    colorValue: 0xFFAB47BC,
  ),
  DefaultCategoryDefinition(
    name: 'Shopping',
    sortOrder: 3,
    iconCode: 'shoppingBag',
    type: TransactionType.expense,
    colorValue: 0xFF7E57C2,
  ),
  DefaultCategoryDefinition(
    name: 'Home',
    sortOrder: 4,
    iconCode: 'home',
    type: TransactionType.expense,
    colorValue: 0xFF5C6BC0,
  ),
  DefaultCategoryDefinition(
    name: 'Bills',
    sortOrder: 5,
    iconCode: 'receipt',
    type: TransactionType.expense,
    colorValue: 0xFF42A5F5,
  ),
  DefaultCategoryDefinition(
    name: 'Health',
    sortOrder: 6,
    iconCode: 'heartPulse',
    type: TransactionType.expense,
    colorValue: 0xFF26A69A,
  ),
  DefaultCategoryDefinition(
    name: 'Education',
    sortOrder: 7,
    iconCode: 'graduationCap',
    type: TransactionType.expense,
    colorValue: 0xFF66BB6A,
  ),
  DefaultCategoryDefinition(
    name: 'Entertainment',
    sortOrder: 8,
    iconCode: 'gamepad',
    type: TransactionType.expense,
    colorValue: 0xFFFFA726,
  ),
  DefaultCategoryDefinition(
    name: 'Travel',
    sortOrder: 9,
    iconCode: 'plane',
    type: TransactionType.expense,
    colorValue: 0xFFFF7043,
  ),
  DefaultCategoryDefinition(
    name: 'Salary',
    sortOrder: 0,
    iconCode: 'briefCase',
    type: TransactionType.income,
    colorValue: 0xFF42A5F5,
  ),
  DefaultCategoryDefinition(
    name: 'Freelance',
    sortOrder: 1,
    iconCode: 'laptop',
    type: TransactionType.income,
    colorValue: 0xFF29B6F6,
  ),
  DefaultCategoryDefinition(
    name: 'Business',
    sortOrder: 2,
    iconCode: 'building',
    type: TransactionType.income,
    colorValue: 0xFF26A69A,
  ),
  DefaultCategoryDefinition(
    name: 'Investments',
    sortOrder: 3,
    iconCode: 'trendingUp',
    type: TransactionType.income,
    colorValue: 0xFF66BB6A,
  ),
  DefaultCategoryDefinition(
    name: 'Gift',
    sortOrder: 4,
    iconCode: 'gift',
    type: TransactionType.income,
    colorValue: 0xFFFFCA28,
  ),
];
