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
    'home': home,
    'heart': heart,
    'music': music,
    'coffee': coffee,
    'book': book,
    'phone': phone,
    'plane': plane,
    'bus': bus,
    'dumbbell': dumbbell,
    'stethoscope': stethoscope,
    'graduationCap': graduationCap,
    'building': building,
    'shoppingCart': shoppingCart,
    'bike': bike,
    'laptop': laptop,
    'zap': zap,
    'star': star,
    'globe': globe,
  };

  /// Resolves icon code to IconData, returns [empty] if not found
  static IconData fromCode(String code) => _iconMap[code] ?? empty;

  static const IconData chevronBottom = LucideIcons.chevronDown;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
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
  static const IconData chevronUpDown = LucideIcons.chevronsUpDown;
  static const IconData feather = LucideIcons.feather;
  static const IconData ban = LucideIcons.ban;

  // Category icons
  static const IconData utensils = LucideIcons.utensils;
  static const IconData car = LucideIcons.car;
  static const IconData shoppingBag = LucideIcons.shoppingBag;
  static const IconData gamepad = LucideIcons.gamepad2;
  static const IconData receipt = LucideIcons.receipt;
  static const IconData gift = LucideIcons.gift;
  static const IconData home = LucideIcons.house;
  static const IconData heart = LucideIcons.heart;
  static const IconData music = LucideIcons.music;
  static const IconData coffee = LucideIcons.coffee;
  static const IconData book = LucideIcons.bookOpen;
  static const IconData phone = LucideIcons.phone;
  static const IconData plane = LucideIcons.plane;
  static const IconData bus = LucideIcons.bus;
  static const IconData dumbbell = LucideIcons.dumbbell;
  static const IconData stethoscope = LucideIcons.stethoscope;
  static const IconData graduationCap = LucideIcons.graduationCap;
  static const IconData building = LucideIcons.building2;
  static const IconData shoppingCart = LucideIcons.shoppingCart;
  static const IconData bike = LucideIcons.bike;
  static const IconData laptop = LucideIcons.laptop;
  static const IconData zap = LucideIcons.zap;
  static const IconData star = LucideIcons.star;
  static const IconData globe = LucideIcons.globe;

  // Visibility icons
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
}
