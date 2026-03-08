import 'package:flutter/material.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final String? route;

  const ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
    this.route,
  });

  static final List<ToolItem> items = [
    const ToolItem(
      icon: AppIcons.crown,
      title: 'Premium',
      subtitle: 'Unlock all features',
      iconColor: Color(0xFFFFB800),
      backgroundColor: Color(0xFFFFF8E1),
    ),
    ToolItem(
      icon: AppIcons.grid,
      title: 'Categories',
      subtitle: 'Manage categories',
      iconColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFFEEF2FF),
      route: AppRoutes.manageCategories,
    ),
    const ToolItem(
      icon: AppIcons.bell,
      title: 'Notifications',
      subtitle: 'Manage alerts',
      iconColor: Color(0xFFEF4444),
      backgroundColor: Color(0xFFFEE2E2),
    ),
    const ToolItem(
      icon: AppIcons.messageSquare,
      title: 'Feedback',
      subtitle: 'Share your thoughts',
      iconColor: Color(0xFF22C55E),
      backgroundColor: Color(0xFFDCFCE7),
    ),
  ];
}
