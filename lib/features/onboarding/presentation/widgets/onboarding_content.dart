import 'package:flutter/material.dart';

class OnboardingContent extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isActive;

  const OnboardingContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          AnimatedScale(
            scale: widget.isActive ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 56.0,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 48.0),

          // Animated title
          AnimatedOpacity(
            opacity: widget.isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              widget.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),

          // Animated description
          AnimatedOpacity(
            opacity: widget.isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              widget.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
