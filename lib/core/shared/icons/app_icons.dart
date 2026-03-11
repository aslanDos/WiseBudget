import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppIcons {
  AppIcons._();

  /// Icon code to IconData mapping
  static const Map<String, IconData> _iconMap = {
    'chevronBottom': chevronBottom,
    'circle': circle,
    'chart': chart,
    'add': add,
    'close': close,
    'arrowUpLeft': arrowUpleft,
    'arrowDownRight': arrowDownRight,
    'arrowUpDown': arrowUpDown,
    'check': check,
    'briefCase': briefCase,
    'wallet': wallet,
    'settings': settings,
    'pencil': pencil,
    'gripVertical': gripVertical,
    'trash': trash,
    'calendar': calendar,
    'empty': empty,
    'crown': crown,
    'grid': grid,
    'bell': bell,
    'messageSquare': messageSquare,
    // Category icons
    'utensils': utensils,
    'car': car,
    'shoppingBag': shoppingBag,
    'gamepad': gamepad,
    'receipt': receipt,
    'gift': gift,
  };

  /// Resolves icon code to IconData, returns [empty] if not found
  static IconData fromCode(String code) => _iconMap[code] ?? empty;

  static const IconData chevronBottom = LucideIcons.chevronDown;
  static const IconData circle = LucideIcons.circle;
  static const IconData chart = LucideIcons.chartNoAxesCombined;
  static const IconData add = LucideIcons.plus;
  static const IconData close = LucideIcons.x;
  static const IconData arrowUpleft = LucideIcons.arrowUpLeft;
  static const IconData arrowDownRight = LucideIcons.arrowDownRight;
  static const IconData arrowUpDown = LucideIcons.arrowUpDown;
  static const IconData check = LucideIcons.check;
  static const IconData briefCase = LucideIcons.briefcaseBusiness;
  static const IconData wallet = LucideIcons.wallet;
  static const IconData settings = LucideIcons.settings;
  static const IconData pencil = LucideIcons.pencil;
  static const IconData gripVertical = LucideIcons.gripVertical;
  static const IconData trash = LucideIcons.trash2;
  static const IconData calendar = LucideIcons.calendarDays;
  static const IconData empty = LucideIcons.octagonMinus;
  static const IconData crown = LucideIcons.crown;
  static const IconData grid = LucideIcons.layoutGrid;
  static const IconData bell = LucideIcons.bell;
  static const IconData messageSquare = LucideIcons.messageSquare;

  // Category icons
  static const IconData utensils = LucideIcons.utensils;
  static const IconData car = LucideIcons.car;
  static const IconData shoppingBag = LucideIcons.shoppingBag;
  static const IconData gamepad = LucideIcons.gamepad2;
  static const IconData receipt = LucideIcons.receipt;
  static const IconData gift = LucideIcons.gift;

  // Visibility icons
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
}
